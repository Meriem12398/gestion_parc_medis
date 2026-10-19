CREATE DATABASE medis_parc_dw_v2;
GO
/* =========================
   DIMENSIONS
   ========================= */
USE medis_parc_dw_v2;
GO
/* DimDate */
CREATE TABLE DimDate (
    DateKey INT PRIMARY KEY,              -- format YYYYMMDD
    FullDate DATE NOT NULL,
    Jour INT NOT NULL,
    Mois INT NOT NULL,
    NomMois NVARCHAR(20) NOT NULL,
    Trimestre INT NOT NULL,
    Annee INT NOT NULL,
    JourSemaine INT NOT NULL,
    NomJour NVARCHAR(20) NOT NULL
);
GO

/* DimUtilisateur */
CREATE TABLE DimUtilisateur (
    UtilisateurKey INT IDENTITY(1,1) PRIMARY KEY,
    Matricule INT NOT NULL,
    Nom NVARCHAR(100) NULL,
    Prenom NVARCHAR(100) NULL,
    Departement NVARCHAR(100) NULL,
    Role NVARCHAR(50) NULL,
    TypePermis NVARCHAR(50) NULL,
    Disponibilite BIT NULL
);
GO

/* DimVehicule */
CREATE TABLE DimVehicule (
    VehiculeKey INT IDENTITY(1,1) PRIMARY KEY,
    IdVehicule INT NOT NULL,
    Immatriculation NVARCHAR(50) NULL,
    Marque NVARCHAR(100) NULL,
    Modele NVARCHAR(100) NULL,
    TypeCarburant NVARCHAR(50) NULL,
    Etat NVARCHAR(50) NULL,
    Disponibilite BIT NULL,
    DateAchat DATE NULL
);
GO

/* DimStatutDemande */
CREATE TABLE DimStatutDemande (
    StatutDemandeKey INT IDENTITY(1,1) PRIMARY KEY,
    LibelleStatutDemande NVARCHAR(100) NOT NULL
);
GO

/* DimStatutMission */
CREATE TABLE DimStatutMission (
    StatutMissionKey INT IDENTITY(1,1) PRIMARY KEY,
    LibelleStatutMission NVARCHAR(100) NOT NULL
);
GO

/* DimPriorite */
CREATE TABLE DimPriorite (
    PrioriteKey INT IDENTITY(1,1) PRIMARY KEY,
    LibellePriorite NVARCHAR(50) NOT NULL
);
GO

/* DimTypeDemande */
CREATE TABLE DimTypeDemande (
    TypeDemandeKey INT IDENTITY(1,1) PRIMARY KEY,
    LibelleTypeDemande NVARCHAR(100) NOT NULL
);
GO

/* DimLocalisation */
CREATE TABLE DimLocalisation (
    LocalisationKey INT IDENTITY(1,1) PRIMARY KEY,
    Adresse NVARCHAR(255) NULL,
    Latitude DECIMAL(10,6) NULL,
    Longitude DECIMAL(10,6) NULL
);
GO
/* =========================
   FACT TABLES
   ========================= */

/* FactDemande
   Grain: 1 ligne = 1 demande
*/
CREATE TABLE FactDemande (
    FactDemandeKey INT IDENTITY(1,1) PRIMARY KEY,
    IdDemande INT NOT NULL,

    DateCreationKey INT NOT NULL,
    DateSouhaiteKey INT NULL,
    UtilisateurKey INT NOT NULL,
    StatutDemandeKey INT NOT NULL,
    PrioriteKey INT NOT NULL,
    TypeDemandeKey INT NOT NULL,

    NbDemandes INT NOT NULL DEFAULT 1,

    CONSTRAINT FK_FactDemande_DateCreation
        FOREIGN KEY (DateCreationKey) REFERENCES DimDate(DateKey),

    CONSTRAINT FK_FactDemande_DateSouhaite
        FOREIGN KEY (DateSouhaiteKey) REFERENCES DimDate(DateKey),

    CONSTRAINT FK_FactDemande_Utilisateur
        FOREIGN KEY (UtilisateurKey) REFERENCES DimUtilisateur(UtilisateurKey),

    CONSTRAINT FK_FactDemande_StatutDemande
        FOREIGN KEY (StatutDemandeKey) REFERENCES DimStatutDemande(StatutDemandeKey),

    CONSTRAINT FK_FactDemande_Priorite
        FOREIGN KEY (PrioriteKey) REFERENCES DimPriorite(PrioriteKey),

    CONSTRAINT FK_FactDemande_TypeDemande
        FOREIGN KEY (TypeDemandeKey) REFERENCES DimTypeDemande(TypeDemandeKey)
);
GO

/* FactMission
   Grain: 1 ligne = 1 mission
*/
CREATE TABLE FactMission (
    FactMissionKey INT IDENTITY(1,1) PRIMARY KEY,
    IdMission INT NOT NULL,

    DateDebutKey INT NOT NULL,
    DateFinKey INT NULL,
    ChauffeurKey INT NOT NULL,
    VehiculeKey INT NOT NULL,
    StatutMissionKey INT NOT NULL,

    NbMissions INT NOT NULL DEFAULT 1,
    DureeMissionHeures DECIMAL(10,2) NULL,
    NbDemandesLiees INT NULL,

    CONSTRAINT FK_FactMission_DateDebut
        FOREIGN KEY (DateDebutKey) REFERENCES DimDate(DateKey),

    CONSTRAINT FK_FactMission_DateFin
        FOREIGN KEY (DateFinKey) REFERENCES DimDate(DateKey),

    CONSTRAINT FK_FactMission_Chauffeur
        FOREIGN KEY (ChauffeurKey) REFERENCES DimUtilisateur(UtilisateurKey),

    CONSTRAINT FK_FactMission_Vehicule
        FOREIGN KEY (VehiculeKey) REFERENCES DimVehicule(VehiculeKey),

    CONSTRAINT FK_FactMission_StatutMission
        FOREIGN KEY (StatutMissionKey) REFERENCES DimStatutMission(StatutMissionKey)
);
GO

/* FactIncident
   Grain: 1 ligne = 1 incident
*/
CREATE TABLE FactIncident (
    FactIncidentKey INT IDENTITY(1,1) PRIMARY KEY,
    IdIncident INT NOT NULL,

    DateIncidentKey INT NOT NULL,
    LocalisationKey INT NULL,

    NbIncidents INT NOT NULL DEFAULT 1,

    CONSTRAINT FK_FactIncident_Date
        FOREIGN KEY (DateIncidentKey) REFERENCES DimDate(DateKey),

    CONSTRAINT FK_FactIncident_Localisation
        FOREIGN KEY (LocalisationKey) REFERENCES DimLocalisation(LocalisationKey)
);
GO

/* FactIntervention
   Grain: 1 ligne = 1 intervention
*/
CREATE TABLE FactIntervention (
    FactInterventionKey INT IDENTITY(1,1) PRIMARY KEY,
    IdIntervention INT NOT NULL,

    DateInterventionKey INT NOT NULL,
    NbInterventions INT NOT NULL DEFAULT 1,
    Cout DECIMAL(18,2) NULL,
    TypeIntervention NVARCHAR(100) NULL,

    CONSTRAINT FK_FactIntervention_Date
        FOREIGN KEY (DateInterventionKey) REFERENCES DimDate(DateKey)
);
GO

/* FactVidange
   Grain: 1 ligne = 1 vidange
*/
CREATE TABLE FactVidange (
    FactVidangeKey INT IDENTITY(1,1) PRIMARY KEY,
    IdVidange INT NOT NULL,

    DateVidangeKey INT NOT NULL,
    VehiculeKey INT NOT NULL,

    NbVidanges INT NOT NULL DEFAULT 1,
    Kilometrage INT NULL,

    CONSTRAINT FK_FactVidange_Date
        FOREIGN KEY (DateVidangeKey) REFERENCES DimDate(DateKey),

    CONSTRAINT FK_FactVidange_Vehicule
        FOREIGN KEY (VehiculeKey) REFERENCES DimVehicule(VehiculeKey)
);
GO

/*table DimDate*/
DECLARE @StartDate DATE = '2020-01-01';
DECLARE @EndDate DATE = '2035-12-31';

WHILE @StartDate <= @EndDate
BEGIN
    INSERT INTO DimDate (
        DateKey,
        FullDate,
        Jour,
        Mois,
        NomMois,
        Trimestre,
        Annee,
        JourSemaine,
        NomJour
    )
    VALUES (
        CONVERT(INT, FORMAT(@StartDate, 'yyyyMMdd')),
        @StartDate,
        DAY(@StartDate),
        MONTH(@StartDate),
        DATENAME(MONTH, @StartDate),
        DATEPART(QUARTER, @StartDate),
        YEAR(@StartDate),
        DATEPART(WEEKDAY, @StartDate),
        DATENAME(WEEKDAY, @StartDate)
    );

    SET @StartDate = DATEADD(DAY, 1, @StartDate);
END;

/*select*/
SELECT TOP 100 * FROM DimDate;

INSERT INTO medis_parc_dw_v2.dbo.DimUtilisateur (
    Matricule,
    Nom,
    Prenom,
    Departement,
    Role,
    TypePermis,
    Disponibilite
)
SELECT DISTINCT
    matricule,
    nom,
    prenom,
    departement,
    role,
    type_permis,
    disponibilite
FROM medis_parc.dbo.Utilisateur;


USE medis_parc_dw_v2;
GO
SELECT m.idmission, m.idvehicule
FROM medis_parc.dbo.Mission m
LEFT JOIN medis_parc_dw_v2.dbo.DimVehicule v
    ON m.idvehicule = v.IdVehicule
WHERE v.VehiculeKey IS NULL;

USE medis_parc_dw_v2;
GO

DELETE FROM DimVehicule;

USE medis_parc_dw_v2;
GO

INSERT INTO DimVehicule (
    IdVehicule,
    Immatriculation,
    Marque,
    Modele,
    TypeCarburant,
    Etat,
    Disponibilite,
    DateAchat
)
SELECT DISTINCT
    idvehicule,
    immatriculation,
    marque,
    modele,
    type_carburant,
    etat,
    disponibilite,
    date_achat
FROM medis_parc.dbo.Vehicule;



USE medis_parc_dw_v2;
GO
DELETE FROM FactMission;


USE medis_parc_dw_v2;
GO

INSERT INTO FactMission (
    IdMission,
    DateDebutKey,
    DateFinKey,
    ChauffeurKey,
    VehiculeKey,
    StatutMissionKey,
    DureeMissionHeures,
    NbDemandesLiees
)
SELECT
    m.idmission,

    CONVERT(INT, FORMAT(m.date_debut, 'yyyyMMdd')),
    CONVERT(INT, FORMAT(m.date_fin, 'yyyyMMdd')),

    u.UtilisateurKey,
    v.VehiculeKey,
    s.StatutMissionKey,

    DATEDIFF(HOUR, m.date_debut, ISNULL(m.date_fin, m.date_debut)),

    COUNT(md.iddemande)

FROM medis_parc.dbo.Mission m

LEFT JOIN DimUtilisateur u
    ON m.chauffeur_matricule = u.Matricule

LEFT JOIN DimVehicule v
    ON m.idvehicule = v.IdVehicule

LEFT JOIN DimStatutMission s
    ON m.statut_mission = s.LibelleStatutMission

LEFT JOIN medis_parc.dbo.mission_demande md
    ON m.idmission = md.idmission

GROUP BY
    m.idmission,
    m.date_debut,
    m.date_fin,
    u.UtilisateurKey,
    v.VehiculeKey,
    s.StatutMissionKey;


	SELECT TOP 10 * FROM FactMission;
SELECT COUNT(*) FROM FactMission;

USE medis_parc_dw_v2;
GO

INSERT INTO FactIncident (
    IdIncident,
    DateIncidentKey,
    LocalisationKey
)
SELECT
    i.idincident,

    CONVERT(INT, FORMAT(i.date_incident, 'yyyyMMdd')),

    l.LocalisationKey

FROM medis_parc.dbo.Incident i

LEFT JOIN DimLocalisation l
    ON i.adresse = l.Adresse
   AND i.latitude = l.Latitude
   AND i.longitude = l.Longitude;

   SELECT TOP 10 * FROM FactIncident;
SELECT COUNT(*) FROM FactIncident;


USE medis_parc_dw_v2;
GO

INSERT INTO FactIntervention (
    IdIntervention,
    DateInterventionKey,
    Cout,
    TypeIntervention
)
SELECT
    i.idintervention,
    CONVERT(INT, FORMAT(i.date_intervention, 'yyyyMMdd')),
    i.cout,
    i.type_intervention
FROM medis_parc.dbo.Intervention i;

SELECT TOP 10 * FROM FactIntervention;
SELECT COUNT(*) FROM FactIntervention;

USE medis_parc_dw_v2;
GO

SELECT COLUMN_NAME, DATA_TYPE
FROM medis_parc.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Vidange';

USE medis_parc_dw_v2;
GO

INSERT INTO FactVidange (
    IdVidange,
    DateVidangeKey,
    VehiculeKey,
    Kilometrage
)
SELECT
    v.idvidange,

    CONVERT(INT, FORMAT(v.date_vidange, 'yyyyMMdd')),

    dv.VehiculeKey,

    v.kilometrage_vidange

FROM medis_parc.dbo.Vidange v

LEFT JOIN DimVehicule dv
    ON v.vehicule_id = dv.IdVehicule;

	SELECT TOP 10 * FROM FactVidange;
SELECT COUNT(*) FROM FactVidange;



USE medis_parc_dw_v2;
GO

DELETE FROM FactMission;
GO

INSERT INTO FactMission (
    IdMission,
    DateDebutKey,
    DateFinKey,
    ChauffeurKey,
    VehiculeKey,
    StatutMissionKey,
    DureeMissionHeures,
    NbDemandesLiees
)
SELECT
    m.idmission,
    CONVERT(INT, FORMAT(m.date_debut, 'yyyyMMdd')),
    CONVERT(INT, FORMAT(m.date_fin, 'yyyyMMdd')),
    u.UtilisateurKey,
    v.VehiculeKey,
    s.StatutMissionKey,
    DATEDIFF(HOUR, m.date_debut, ISNULL(m.date_fin, m.date_debut)),
    ISNULL(md.NbDemandesLiees, 0)
FROM medis_parc.dbo.Mission m

LEFT JOIN DimUtilisateur u
    ON m.chauffeur_matricule = u.Matricule

LEFT JOIN DimVehicule v
    ON m.idvehicule = v.IdVehicule

LEFT JOIN DimStatutMission s
    ON m.statut_mission = s.LibelleStatutMission

LEFT JOIN (
    SELECT
        idmission,
        COUNT(*) AS NbDemandesLiees
    FROM medis_parc.dbo.mission_demande
    GROUP BY idmission
) md
    ON m.idmission = md.idmission;


	SELECT COUNT(*) FROM medis_parc.dbo.Mission;
SELECT COUNT(*) FROM FactMission;



USE medis_parc_dw_v2;
GO
SELECT Matricule, COUNT(*) AS nb
FROM DimUtilisateur
GROUP BY Matricule
HAVING COUNT(*) > 1;

SELECT IdVehicule, COUNT(*) AS nb
FROM DimVehicule
GROUP BY IdVehicule
HAVING COUNT(*) > 1;

SELECT LibelleStatutMission, COUNT(*) AS nb
FROM DimStatutMission
GROUP BY LibelleStatutMission
HAVING COUNT(*) > 1;


USE medis_parc_dw_v2;
GO
SELECT Matricule, COUNT(*)
FROM DimUtilisateur
GROUP BY Matricule
HAVING COUNT(*) > 1;

SELECT IdVehicule, COUNT(*)
FROM DimVehicule
GROUP BY IdVehicule
HAVING COUNT(*) > 1;

SELECT LibelleStatutMission, COUNT(*)
FROM DimStatutMission
GROUP BY LibelleStatutMission
HAVING COUNT(*) > 1;






INSERT INTO DimStatutMission (LibelleStatutMission)
SELECT DISTINCT statut_mission
FROM medis_parc.dbo.Mission
WHERE statut_mission IS NOT NULL;
INSERT INTO DimVehicule (
    IdVehicule,
    Immatriculation,
    Marque,
    Modele,
    TypeCarburant,
    Etat,
    Disponibilite,
    DateAchat
)
SELECT DISTINCT
    idvehicule,
    immatriculation,
    marque,
    modele,
    type_carburant,
    etat,
    disponibilite,
    date_achat
FROM medis_parc.dbo.Vehicule;
INSERT INTO DimUtilisateur (
    Matricule,
    Nom,
    Prenom,
    Departement,
    Role,
    TypePermis,
    Disponibilite
)
SELECT DISTINCT
    matricule,
    nom,
    prenom,
    departement,
    role,
    type_permis,
    disponibilite
FROM medis_parc.dbo.Utilisateur;


DELETE FROM DimUtilisateur;
DELETE FROM DimVehicule;
DELETE FROM DimStatutMission;


DELETE FROM FactMission;
DELETE FROM FactDemande;
DELETE FROM FactVidange;
DELETE FROM FactMission;
DELETE FROM FactDemande;
DELETE FROM FactVidange;

USE medis_parc_dw_v2;
GO
SELECT COUNT(*) FROM FactDemande;
SELECT COUNT(*) FROM FactVidange;
SELECT COUNT(*) FROM FactMission;
SELECT COUNT(*) FROM medis_parc.dbo.Mission;

INSERT INTO FactMission (
    IdMission,
    DateDebutKey,
    DateFinKey,
    ChauffeurKey,
    VehiculeKey,
    StatutMissionKey,
    DureeMissionHeures,
    NbDemandesLiees
)
SELECT
    m.idmission,
    CONVERT(INT, FORMAT(m.date_debut, 'yyyyMMdd')),
    CONVERT(INT, FORMAT(m.date_fin, 'yyyyMMdd')),
    u.UtilisateurKey,
    v.VehiculeKey,
    s.StatutMissionKey,
    DATEDIFF(HOUR, m.date_debut, ISNULL(m.date_fin, m.date_debut)),
    ISNULL(md.NbDemandesLiees, 0)
FROM medis_parc.dbo.Mission m
LEFT JOIN DimUtilisateur u
    ON m.chauffeur_matricule = u.Matricule
LEFT JOIN DimVehicule v
    ON m.idvehicule = v.IdVehicule
LEFT JOIN DimStatutMission s
    ON m.statut_mission = s.LibelleStatutMission
LEFT JOIN (
    SELECT idmission, COUNT(*) AS NbDemandesLiees
    FROM medis_parc.dbo.mission_demande
    GROUP BY idmission
) md
    ON m.idmission = md.idmission;
INSERT INTO FactVidange (
    IdVidange,
    DateVidangeKey,
    VehiculeKey,
    Kilometrage
)
SELECT
    v.idvidange,
    CONVERT(INT, FORMAT(v.date_vidange, 'yyyyMMdd')),
    dv.VehiculeKey,
    v.kilometrage_vidange
FROM medis_parc.dbo.Vidange v
LEFT JOIN DimVehicule dv
    ON v.vehicule_id = dv.IdVehicule;
INSERT INTO FactDemande (
    IdDemande,
    DateCreationKey,
    DateSouhaiteKey,
    UtilisateurKey,
    StatutDemandeKey,
    PrioriteKey,
    TypeDemandeKey
)
SELECT
    d.iddemande,
    CONVERT(INT, FORMAT(d.date_creation, 'yyyyMMdd')),
    CONVERT(INT, FORMAT(d.date_souhaite, 'yyyyMMdd')),
    u.UtilisateurKey,
    s.StatutDemandeKey,
    p.PrioriteKey,
    t.TypeDemandeKey
FROM medis_parc.dbo.Demande d
LEFT JOIN DimUtilisateur u
    ON d.matricule = u.Matricule
LEFT JOIN DimStatutDemande s
    ON d.statut = s.LibelleStatutDemande
LEFT JOIN DimPriorite p
    ON d.priorite = p.LibellePriorite
LEFT JOIN DimTypeDemande t
    ON d.type_demande = t.LibelleTypeDemande;


	USE medis_parc_dw_v2;
GO
SELECT IdMission, COUNT(*) 
FROM FactMission
GROUP BY IdMission
HAVING COUNT(*) > 1;









	USE medis_parc_dw_v2;
GO
SELECT IdDemande, COUNT(*) 
FROM FactDemande
GROUP BY IdDemande
HAVING COUNT(*) > 1;




	USE medis_parc_dw_v2;
GO
SELECT * FROM FactMission
WHERE VehiculeKey IS NULL
   OR ChauffeurKey IS NULL
   OR StatutMissionKey IS NULL;









   	USE medis_parc_dw_v2;
GO
   SELECT Matricule, COUNT(*) 
FROM DimUtilisateur
GROUP BY Matricule
HAVING COUNT(*) > 1;

SELECT IdVehicule, COUNT(*) 
FROM DimVehicule
GROUP BY IdVehicule
HAVING COUNT(*) > 1;










   	USE medis_parc_dw_v2;
GO

SELECT Matricule, COUNT(*)
FROM DimUtilisateur
GROUP BY Matricule
HAVING COUNT(*) > 1;

SELECT IdVehicule, COUNT(*)
FROM DimVehicule
GROUP BY IdVehicule
HAVING COUNT(*) > 1;


INSERT INTO DimVehicule (
    IdVehicule, Immatriculation, Marque, Modele, TypeCarburant, Etat, Disponibilite, DateAchat
)
SELECT DISTINCT
    idvehicule, immatriculation, marque, modele, type_carburant, etat, disponibilite, date_achat
FROM medis_parc.dbo.Vehicule;


INSERT INTO DimUtilisateur (
    Matricule, Nom, Prenom, Departement, Role, TypePermis, Disponibilite
)
SELECT DISTINCT
    matricule, nom, prenom, departement, role, type_permis, disponibilite
FROM medis_parc.dbo.Utilisateur;
DELETE FROM DimUtilisateur;
DELETE FROM DimVehicule;
DELETE FROM FactIncident;
DELETE FROM FactIntervention;
DELETE FROM DimUtilisateur;
DELETE FROM DimVehicule;










USE medis_parc_dw_v2;
GO

/* =========================
   FACT DEMANDE
   ========================= */
INSERT INTO FactDemande (
    IdDemande,
    DateCreationKey,
    DateSouhaiteKey,
    UtilisateurKey,
    StatutDemandeKey,
    PrioriteKey,
    TypeDemandeKey
)
SELECT
    d.iddemande,
    CONVERT(INT, FORMAT(d.date_creation, 'yyyyMMdd')),
    CONVERT(INT, FORMAT(d.date_souhaite, 'yyyyMMdd')),
    u.UtilisateurKey,
    s.StatutDemandeKey,
    p.PrioriteKey,
    t.TypeDemandeKey
FROM medis_parc.dbo.Demande d
LEFT JOIN DimUtilisateur u
    ON d.matricule = u.Matricule
LEFT JOIN DimStatutDemande s
    ON d.statut = s.LibelleStatutDemande
LEFT JOIN DimPriorite p
    ON d.priorite = p.LibellePriorite
LEFT JOIN DimTypeDemande t
    ON d.type_demande = t.LibelleTypeDemande;
GO

/* =========================
   FACT VIDANGE
   ========================= */
INSERT INTO FactVidange (
    IdVidange,
    DateVidangeKey,
    VehiculeKey,
    Kilometrage
)
SELECT
    v.idvidange,
    CONVERT(INT, FORMAT(v.date_vidange, 'yyyyMMdd')),
    dv.VehiculeKey,
    v.kilometrage_vidange
FROM medis_parc.dbo.Vidange v
LEFT JOIN DimVehicule dv
    ON v.vehicule_id = dv.IdVehicule;
GO

/* =========================
   FACT MISSION
   ========================= */
INSERT INTO FactMission (
    IdMission,
    DateDebutKey,
    DateFinKey,
    ChauffeurKey,
    VehiculeKey,
    StatutMissionKey,
    DureeMissionHeures,
    NbDemandesLiees
)
SELECT
    m.idmission,
    CONVERT(INT, FORMAT(m.date_debut, 'yyyyMMdd')),
    CONVERT(INT, FORMAT(m.date_fin, 'yyyyMMdd')),
    u.UtilisateurKey,
    v.VehiculeKey,
    s.StatutMissionKey,
    DATEDIFF(HOUR, m.date_debut, ISNULL(m.date_fin, m.date_debut)),
    ISNULL(md.NbDemandesLiees, 0)
FROM medis_parc.dbo.Mission m
LEFT JOIN DimUtilisateur u
    ON m.chauffeur_matricule = u.Matricule
LEFT JOIN DimVehicule v
    ON m.idvehicule = v.IdVehicule
LEFT JOIN DimStatutMission s
    ON m.statut_mission = s.LibelleStatutMission
LEFT JOIN (
    SELECT
        idmission,
        COUNT(*) AS NbDemandesLiees
    FROM medis_parc.dbo.mission_demande
    GROUP BY idmission
) md
    ON m.idmission = md.idmission;
GO









USE medis_parc_dw_v2;
GO

DELETE FROM FactMission;
DELETE FROM FactVidange;
DELETE FROM FactDemande;


SELECT 'Demande_Source' AS TableName, COUNT(*) FROM medis_parc.dbo.Demande
UNION ALL
SELECT 'Demande_DW', COUNT(*) FROM FactDemande

UNION ALL
SELECT 'Mission_Source', COUNT(*) FROM medis_parc.dbo.Mission
UNION ALL
SELECT 'Mission_DW', COUNT(*) FROM FactMission

UNION ALL
SELECT 'Incident_Source', COUNT(*) FROM medis_parc.dbo.Incident
UNION ALL
SELECT 'Incident_DW', COUNT(*) FROM FactIncident

UNION ALL
SELECT 'Intervention_Source', COUNT(*) FROM medis_parc.dbo.Intervention
UNION ALL
SELECT 'Intervention_DW', COUNT(*) FROM FactIntervention

UNION ALL
SELECT 'Vidange_Source', COUNT(*) FROM medis_parc.dbo.Vidange
UNION ALL
SELECT 'Vidange_DW', COUNT(*) FROM FactVidange;










SELECT COUNT(*) FROM medis_parc.dbo.Incident;
SELECT COUNT(*) FROM FactIncident;

SELECT COUNT(*) FROM medis_parc.dbo.Intervention;
SELECT COUNT(*) FROM FactIntervention;

INSERT INTO FactIntervention (
    IdIntervention,
    DateInterventionKey,
    Cout,
    TypeIntervention
)
SELECT DISTINCT
    i.idintervention,
    CONVERT(INT, FORMAT(i.date_intervention, 'yyyyMMdd')),
    i.cout,
    i.type_intervention
FROM medis_parc.dbo.Intervention i;














INSERT INTO FactIncident (
    IdIncident,
    DateIncidentKey,
    LocalisationKey
)
SELECT DISTINCT
    i.idincident,
    CONVERT(INT, FORMAT(i.date_incident, 'yyyyMMdd')),
    l.LocalisationKey
FROM medis_parc.dbo.Incident i
LEFT JOIN DimLocalisation l
    ON i.adresse = l.Adresse
   AND i.latitude = l.Latitude
   AND i.longitude = l.Longitude;


DELETE FROM FactIncident;
DELETE FROM FactIntervention;



SELECT COUNT(*) FROM medis_parc.dbo.Mission;
SELECT COUNT(*) FROM FactMission;


INSERT INTO FactMission (
    IdMission,
    DateDebutKey,
    DateFinKey,
    ChauffeurKey,
    VehiculeKey,
    StatutMissionKey,
    DureeMissionHeures,
    NbDemandesLiees
)
SELECT
    m.idmission,
    CONVERT(INT, FORMAT(m.date_debut, 'yyyyMMdd')),
    CONVERT(INT, FORMAT(m.date_fin, 'yyyyMMdd')),
    u.UtilisateurKey,
    v.VehiculeKey,
    s.StatutMissionKey,
    DATEDIFF(HOUR, m.date_debut, ISNULL(m.date_fin, m.date_debut)),
    ISNULL(md.NbDemandesLiees, 0)
FROM medis_parc.dbo.Mission m
LEFT JOIN DimUtilisateur u
    ON m.chauffeur_matricule = u.Matricule
LEFT JOIN DimVehicule v
    ON m.idvehicule = v.IdVehicule
LEFT JOIN DimStatutMission s
    ON m.statut_mission = s.LibelleStatutMission
LEFT JOIN (
    SELECT idmission, COUNT(*) AS NbDemandesLiees
    FROM medis_parc.dbo.mission_demande
    GROUP BY idmission
) md
    ON m.idmission = md.idmission;




















DELETE FROM FactMission;

SELECT COUNT(*)
FROM medis_parc.dbo.Mission m
LEFT JOIN DimUtilisateur u
    ON m.chauffeur_matricule = u.Matricule
WHERE u.UtilisateurKey IS NULL;



SELECT COUNT(*)
FROM medis_parc.dbo.Mission m
LEFT JOIN DimVehicule v
    ON m.idvehicule = v.IdVehicule
WHERE v.VehiculeKey IS NULL;


SELECT COUNT(*)
FROM medis_parc.dbo.Mission m
LEFT JOIN DimStatutMission s
    ON m.statut_mission = s.LibelleStatutMission
WHERE s.StatutMissionKey IS NULL;



























SELECT COUNT(*) AS Nb_Demande_Source FROM medis_parc.dbo.Demande;
SELECT COUNT(*) AS Nb_Demande_DW FROM FactDemande;

SELECT COUNT(*) AS Nb_Mission_Source FROM medis_parc.dbo.Mission;
SELECT COUNT(*) AS Nb_Mission_DW FROM FactMission;

SELECT COUNT(*) AS Nb_Incident_Source FROM medis_parc.dbo.Incident;
SELECT COUNT(*) AS Nb_Incident_DW FROM FactIncident;

SELECT COUNT(*) AS Nb_Intervention_Source FROM medis_parc.dbo.Intervention;
SELECT COUNT(*) AS Nb_Intervention_DW FROM FactIntervention;

SELECT COUNT(*) AS Nb_Vidange_Source FROM medis_parc.dbo.Vidange;
SELECT COUNT(*) AS Nb_Vidange_DW FROM FactVidange;



SELECT COUNT(*) FROM medis_parc.dbo.Demande;
SELECT COUNT(*) FROM FactDemande;

INSERT INTO FactDemande (
    IdDemande,
    DateCreationKey,
    DateSouhaiteKey,
    UtilisateurKey,
    StatutDemandeKey,
    PrioriteKey,
    TypeDemandeKey
)
SELECT
    d.iddemande,
    CONVERT(INT, FORMAT(d.date_creation, 'yyyyMMdd')),
    CONVERT(INT, FORMAT(d.date_souhaite, 'yyyyMMdd')),
    u.UtilisateurKey,
    s.StatutDemandeKey,
    p.PrioriteKey,
    t.TypeDemandeKey
FROM medis_parc.dbo.Demande d
LEFT JOIN DimUtilisateur u
    ON d.matricule = u.Matricule
LEFT JOIN DimStatutDemande s
    ON d.statut = s.LibelleStatutDemande
LEFT JOIN DimPriorite p
    ON d.priorite = p.LibellePriorite
LEFT JOIN DimTypeDemande t
    ON d.type_demande = t.LibelleTypeDemande;

INSERT INTO DimTypeDemande (LibelleTypeDemande)
SELECT DISTINCT type_demande
FROM medis_parc.dbo.Demande
WHERE type_demande IS NOT NULL;


INSERT INTO DimPriorite (LibellePriorite)
SELECT DISTINCT priorite
FROM medis_parc.dbo.Demande
WHERE priorite IS NOT NULL;



INSERT INTO DimStatutDemande (LibelleStatutDemande)
SELECT DISTINCT statut
FROM medis_parc.dbo.Demande
WHERE statut IS NOT NULL;
INSERT INTO DimUtilisateur (
    Matricule,
    Nom,
    Prenom,
    Departement,
    Role,
    TypePermis,
    Disponibilite
)
SELECT DISTINCT
    matricule,
    nom,
    prenom,
    departement,
    role,
    type_permis,
    disponibilite
FROM medis_parc.dbo.Utilisateur;

DELETE FROM DimUtilisateur;
DELETE FROM DimStatutDemande;
DELETE FROM DimPriorite;
DELETE FROM DimTypeDemande;

DELETE FROM FactDemande;
DELETE FROM FactMission;
	SELECT Matricule, COUNT(*) AS nb
FROM DimUtilisateur
GROUP BY Matricule
HAVING COUNT(*) > 1;

SELECT LibelleStatutDemande, COUNT(*) AS nb
FROM DimStatutDemande
GROUP BY LibelleStatutDemande
HAVING COUNT(*) > 1;

SELECT LibellePriorite, COUNT(*) AS nb
FROM DimPriorite
GROUP BY LibellePriorite
HAVING COUNT(*) > 1;

SELECT LibelleTypeDemande, COUNT(*) AS nb
FROM DimTypeDemande
GROUP BY LibelleTypeDemande
HAVING COUNT(*) > 1;




USE medis_parc_dw_v2;
GO
-- لازم يرجّع 0 rows
SELECT LibelleStatutDemande, COUNT(*) FROM DimStatutDemande GROUP BY LibelleStatutDemande HAVING COUNT(*) > 1;
SELECT LibellePriorite, COUNT(*) FROM DimPriorite GROUP BY LibellePriorite HAVING COUNT(*) > 1;
SELECT LibelleTypeDemande, COUNT(*) FROM DimTypeDemande GROUP BY LibelleTypeDemande HAVING COUNT(*) > 1;
SELECT LibelleStatutMission, COUNT(*) FROM DimStatutMission GROUP BY LibelleStatutMission HAVING COUNT(*) > 1;

INSERT INTO DimStatutMission (LibelleStatutMission)
SELECT DISTINCT statut_mission
FROM medis_parc.dbo.Mission
WHERE statut_mission IS NOT NULL;

INSERT INTO DimTypeDemande (LibelleTypeDemande)
SELECT DISTINCT type_demande
FROM medis_parc.dbo.Demande
WHERE type_demande IS NOT NULL;

INSERT INTO DimPriorite (LibellePriorite)
SELECT DISTINCT priorite
FROM medis_parc.dbo.Demande
WHERE priorite IS NOT NULL;



INSERT INTO DimStatutDemande (LibelleStatutDemande)
SELECT DISTINCT statut
FROM medis_parc.dbo.Demande
WHERE statut IS NOT NULL;



DELETE FROM DimStatutDemande;
DELETE FROM DimPriorite;
DELETE FROM DimTypeDemande;
DELETE FROM DimStatutMission;

DELETE FROM FactMission;
DELETE FROM FactDemande;
DELETE FROM FactVidange;



SELECT Matricule, COUNT(*) AS nb
FROM DimUtilisateur
GROUP BY Matricule
HAVING COUNT(*) > 1;

SELECT IdVehicule, COUNT(*) AS nb
FROM DimVehicule
GROUP BY IdVehicule
HAVING COUNT(*) > 1;

SELECT LibelleStatutMission, COUNT(*) AS nb
FROM DimStatutMission
GROUP BY LibelleStatutMission
HAVING COUNT(*) > 1;




















SELECT Matricule, COUNT(*) AS nb
FROM DimUtilisateur
GROUP BY Matricule
HAVING COUNT(*) > 1;

SELECT LibelleStatutDemande, COUNT(*) AS nb
FROM DimStatutDemande
GROUP BY LibelleStatutDemande
HAVING COUNT(*) > 1;

SELECT LibellePriorite, COUNT(*) AS nb
FROM DimPriorite
GROUP BY LibellePriorite
HAVING COUNT(*) > 1;

SELECT LibelleTypeDemande, COUNT(*) AS nb
FROM DimTypeDemande
GROUP BY LibelleTypeDemande
HAVING COUNT(*) > 1;






















/* =========================
   COUNTS SOURCE vs DW
   ========================= */
SELECT 'Demande_Source' AS TableName, COUNT(*) AS Nb FROM medis_parc.dbo.Demande
UNION ALL
SELECT 'Demande_DW', COUNT(*) FROM FactDemande
UNION ALL
SELECT 'Mission_Source', COUNT(*) FROM medis_parc.dbo.Mission
UNION ALL
SELECT 'Mission_DW', COUNT(*) FROM FactMission
UNION ALL
SELECT 'Incident_Source', COUNT(*) FROM medis_parc.dbo.Incident
UNION ALL
SELECT 'Incident_DW', COUNT(*) FROM FactIncident
UNION ALL
SELECT 'Intervention_Source', COUNT(*) FROM medis_parc.dbo.Intervention
UNION ALL
SELECT 'Intervention_DW', COUNT(*) FROM FactIntervention
UNION ALL
SELECT 'Vidange_Source', COUNT(*) FROM medis_parc.dbo.Vidange
UNION ALL
SELECT 'Vidange_DW', COUNT(*) FROM FactVidange;
GO

/* =========================
   DUPLICATES IN FACTS
   ========================= */
SELECT IdDemande, COUNT(*) AS nb
FROM FactDemande
GROUP BY IdDemande
HAVING COUNT(*) > 1;

SELECT IdMission, COUNT(*) AS nb
FROM FactMission
GROUP BY IdMission
HAVING COUNT(*) > 1;

SELECT IdVidange, COUNT(*) AS nb
FROM FactVidange
GROUP BY IdVidange
HAVING COUNT(*) > 1;
GO

/* =========================
   NULL FOREIGN KEYS
   ========================= */
SELECT *
FROM FactDemande
WHERE UtilisateurKey IS NULL
   OR StatutDemandeKey IS NULL
   OR PrioriteKey IS NULL
   OR TypeDemandeKey IS NULL;

SELECT *
FROM FactMission
WHERE ChauffeurKey IS NULL
   OR VehiculeKey IS NULL
   OR StatutMissionKey IS NULL;

SELECT *
FROM FactVidange
WHERE VehiculeKey IS NULL;
GO












USE medis_parc_dw_v2;
GO




SELECT COUNT(*) AS Nb_Demande_Source FROM medis_parc.dbo.Demande;
SELECT COUNT(*) AS Nb_Demande_DW FROM FactDemande;

SELECT COUNT(*) AS Nb_Mission_Source FROM medis_parc.dbo.Mission;
SELECT COUNT(*) AS Nb_Mission_DW FROM FactMission;

SELECT COUNT(*) AS Nb_Vidange_Source FROM medis_parc.dbo.Vidange;
SELECT COUNT(*) AS Nb_Vidange_DW FROM FactVidange;

INSERT INTO FactMission (
    IdMission,
    DateDebutKey,
    DateFinKey,
    ChauffeurKey,
    VehiculeKey,
    StatutMissionKey,
    DureeMissionHeures,
    NbDemandesLiees
)
SELECT
    m.idmission,
    CONVERT(INT, FORMAT(m.date_debut, 'yyyyMMdd')),
    CONVERT(INT, FORMAT(m.date_fin, 'yyyyMMdd')),
    u.UtilisateurKey,
    v.VehiculeKey,
    s.StatutMissionKey,
    DATEDIFF(HOUR, m.date_debut, ISNULL(m.date_fin, m.date_debut)),
    ISNULL(md.NbDemandesLiees, 0)
FROM medis_parc.dbo.Mission m
LEFT JOIN DimUtilisateur u
    ON m.chauffeur_matricule = u.Matricule
LEFT JOIN DimVehicule v
    ON m.idvehicule = v.IdVehicule
LEFT JOIN DimStatutMission s
    ON m.statut_mission = s.LibelleStatutMission
LEFT JOIN (
    SELECT
        idmission,
        COUNT(*) AS NbDemandesLiees
    FROM medis_parc.dbo.mission_demande
    GROUP BY idmission
) md
    ON m.idmission = md.idmission;
GO


INSERT INTO FactVidange (
    IdVidange,
    DateVidangeKey,
    VehiculeKey,
    Kilometrage
)
SELECT
    v.idvidange,
    CONVERT(INT, FORMAT(v.date_vidange, 'yyyyMMdd')),
    dv.VehiculeKey,
    v.kilometrage_vidange
FROM medis_parc.dbo.Vidange v
LEFT JOIN DimVehicule dv
    ON v.vehicule_id = dv.IdVehicule;
GO




INSERT INTO FactDemande (
    IdDemande,
    DateCreationKey,
    DateSouhaiteKey,
    UtilisateurKey,
    StatutDemandeKey,
    PrioriteKey,
    TypeDemandeKey
)
SELECT
    d.iddemande,
    CONVERT(INT, FORMAT(d.date_creation, 'yyyyMMdd')),
    CONVERT(INT, FORMAT(d.date_souhaite, 'yyyyMMdd')),
    u.UtilisateurKey,
    s.StatutDemandeKey,
    p.PrioriteKey,
    t.TypeDemandeKey
FROM medis_parc.dbo.Demande d
LEFT JOIN DimUtilisateur u
    ON d.matricule = u.Matricule
LEFT JOIN DimStatutDemande s
    ON d.statut = s.LibelleStatutDemande
LEFT JOIN DimPriorite p
    ON d.priorite = p.LibellePriorite
LEFT JOIN DimTypeDemande t
    ON d.type_demande = t.LibelleTypeDemande;
GO





