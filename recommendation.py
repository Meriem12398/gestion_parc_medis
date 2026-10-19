import pyodbc
import pandas as pd

# -----------------------------
# Connexion SQL Server
# -----------------------------
server = 'DESKTOP-EA6K2R8\\SQLEXPRESS'
database = 'medis_parc'

conn = pyodbc.connect(
    f'DRIVER={{SQL Server}};SERVER={server};DATABASE={database};Trusted_Connection=yes;'
)

cursor = conn.cursor()

# -----------------------------
# 1) Récupérer toutes les demandes sans recommandation
# -----------------------------
query_demandes = """
SELECT d.iddemande, d.date_souhaite
FROM Demande d
LEFT JOIN RecommendationAffectation r
    ON d.iddemande = r.iddemande
WHERE r.iddemande IS NULL
  AND d.statut = 'VALIDEE'
  AND d.date_souhaite IS NOT NULL
ORDER BY d.iddemande DESC
"""

df_demandes = pd.read_sql(query_demandes, conn)

if df_demandes.empty:
    print("Aucune nouvelle demande à traiter.")
    conn.close()
    exit()

print(f"{len(df_demandes)} demande(s) à traiter.\n")

# -----------------------------
# Réservation temporaire dans ce run
# -----------------------------
used_chauffeurs = set()
used_vehicules = set()

# -----------------------------
# 2) Boucle sur chaque demande
# -----------------------------
for _, demande in df_demandes.iterrows():
    iddemande = int(demande["iddemande"])
    date_demande = demande["date_souhaite"]

    print(f"--- Traitement demande {iddemande} | date: {date_demande} ---")

    # -----------------------------
    # Query chauffeurs disponibles sans conflit
    # -----------------------------
    query_chauffeurs = f"""
    SELECT
        u.matricule,
        u.nom,
        u.prenom,
        COUNT(m_all.idmission) AS nb_missions
    FROM Utilisateur u
    LEFT JOIN Mission m_all
        ON u.matricule = m_all.chauffeur_matricule
    WHERE u.role = 'CHAUFFEUR'
      AND u.disponibilite = 1
      AND u.matricule NOT IN (
          SELECT m.chauffeur_matricule
          FROM Mission m
          WHERE m.chauffeur_matricule IS NOT NULL
            AND '{date_demande}' BETWEEN m.date_debut AND m.date_fin
            AND m.statut_mission <> 'TERMINEE'
      )
    GROUP BY u.matricule, u.nom, u.prenom
    ORDER BY nb_missions ASC;
    """

    # -----------------------------
    # Query véhicules disponibles sans conflit
    # -----------------------------
    query_vehicules = f"""
SELECT
    v.idvehicule,
    v.immatriculation,
    v.marque,
    v.modele,
    v.kilometrage,
    v.etat,
    COUNT(m_all.idmission) AS nb_missions
FROM Vehicule v
LEFT JOIN Mission m_all
    ON v.idvehicule = m_all.idvehicule
WHERE v.etat = 'Disponible'
  AND v.idvehicule NOT IN (
      SELECT m.idvehicule
      FROM Mission m
      WHERE m.idvehicule IS NOT NULL
        AND '{date_demande}' BETWEEN m.date_debut AND m.date_fin
        AND m.statut_mission <> 'TERMINEE'
  )
GROUP BY
    v.idvehicule,
    v.immatriculation,
    v.marque,
    v.modele,
    v.kilometrage,
    v.etat
ORDER BY nb_missions ASC, kilometrage ASC;
"""

    df_chauffeurs = pd.read_sql(query_chauffeurs, conn)
    df_vehicules = pd.read_sql(query_vehicules, conn)

    # -----------------------------
    # Filtrer ceux déjà utilisés dans ce run
    # -----------------------------
    if not df_chauffeurs.empty:
        df_chauffeurs = df_chauffeurs[~df_chauffeurs["matricule"].isin(used_chauffeurs)]

    if not df_vehicules.empty:
        df_vehicules = df_vehicules[~df_vehicules["idvehicule"].isin(used_vehicules)]

    if df_chauffeurs.empty:
        print(f"  -> Aucun chauffeur disponible pour demande {iddemande}")
        continue

    if df_vehicules.empty:
        print(f"  -> Aucun véhicule disponible pour demande {iddemande}")
        continue

    # Premier disponible après exclusion
    best_chauffeur = df_chauffeurs.iloc[0]
    best_vehicule = df_vehicules.iloc[0]

    # -----------------------------
    # Insert recommendation
    # -----------------------------
    insert_query = """
    INSERT INTO RecommendationAffectation (iddemande, chauffeur_matricule, idvehicule)
    VALUES (?, ?, ?)
    """

    cursor.execute(
        insert_query,
        iddemande,
        int(best_chauffeur["matricule"]),
        int(best_vehicule["idvehicule"])
    )
    conn.commit()

    # Marquer comme utilisés dans ce run
    used_chauffeurs.add(int(best_chauffeur["matricule"]))
    used_vehicules.add(int(best_vehicule["idvehicule"]))

    print(
        f"  -> Recommendation enregistrée | "
        f"Chauffeur: {best_chauffeur['prenom']} {best_chauffeur['nom']} | "
        f"Véhicule: {best_vehicule['immatriculation']}"
    )

print("\nTraitement terminé.")
conn.close()