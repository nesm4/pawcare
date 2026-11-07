/*
Nesma MEKKI
Lina KHADHRI
SPA
*/

CREATE TABLE employe (
    matricule varchar(8) PRIMARY KEY,
    nom varchar(15) NOT NULL,
    prenom varchar(15) NOT NULL,
    adresse varchar(100),
    numTelEmploye char(10),
    dateNaissanceE date,
    numSecu char(15),
    dateArrivee date,
    login varchar(20) UNIQUE,
    mdp varchar(50)
);

CREATE TABLE refuge (
    idRefuge varchar(10) PRIMARY KEY,
    nom varchar(50) NOT NULL,
    adresse varchar(50),
    ville varchar(30),
    codePostal char(5),
    numTelRefuge char(10),
    capacite integer NOT NULL CHECK (capacite >= 0),
    gerant varchar(8) NOT NULL REFERENCES employe(matricule)
);

CREATE TABLE fourriere(
    idFourriere varchar(10) PRIMARY KEY,
    nom varchar(20) NOT NULL,
    adresse varchar(50),
    numTelFourriere char(10)
);

CREATE TABLE adoptant(
    idAdoptant varchar(10) PRIMARY KEY,
    nom varchar(20) NOT NULL,
    prenom varchar(20) NOT NULL,
    ville varchar(30),
    codePostal char(5),
    numTelAdoptant char(10)
);

CREATE TABLE animal(
    numId varchar(10) PRIMARY KEY,
    espece varchar(30) NOT NULL,
    nom varchar(20),
    dateNaissanceA date,
    sexe char(1) CHECK (sexe IN ('M','F')),
    idAdoptant varchar(10) REFERENCES adoptant(idAdoptant),
    idFourriere varchar(10) NOT NULL REFERENCES fourriere(idFourriere)
);

CREATE TABLE soin(
    idSoin varchar(10) PRIMARY KEY,
    nomSoin varchar(40) NOT NULL,
    periodeRappel interval
);

CREATE TABLE soinsRecus(
    idSoinsRecus varchar(10) PRIMARY KEY,
    dateSoin date NOT NULL,
    soignant varchar(8) REFERENCES employe(matricule),
    idSoin varchar(10) REFERENCES soin(idSoin),
    numId varchar(10) REFERENCES animal(numId)
);

CREATE TABLE confie(
    idRefuge varchar(10) REFERENCES refuge(idRefuge),
    numId varchar(10) REFERENCES animal(numId),
    idFourriere varchar(10) REFERENCES fourriere(idFourriere),
    dateArriveeSPA date NOT NULL,
    PRIMARY KEY (idRefuge,numId,idFourriere)
);

CREATE TABLE fonction(
    idFonction varchar(10) PRIMARY KEY,
    nomFonction varchar(50) NOT NULL
);

CREATE TABLE occupe(
    idRefuge varchar(10) REFERENCES refuge(idRefuge),
    matricule varchar(8) REFERENCES employe(matricule),
    idFonction varchar(10) REFERENCES fonction(idFonction),
    PRIMARY KEY (idRefuge,matricule,idFonction)
);

CREATE TABLE accueille(
    idRefugeOrigine varchar(10) REFERENCES refuge(idRefuge),
    idRefugeArrivee varchar(10) CHECK (idRefugeOrigine <> idRefugeArrivee) REFERENCES refuge(idRefuge),
    numId varchar(10) REFERENCES animal(numId),
    dateDepart date NOT NULL,
    dateArrivee date NOT NULL CHECK (dateArrivee >= dateDepart),
    PRIMARY KEY (idRefugeOrigine,idRefugeArrivee,numId)
);

CREATE TABLE signeDist(
    idSigne varchar(10) PRIMARY KEY,
    description text
);

CREATE TABLE animal_signe(
    numId varchar(10) REFERENCES animal(numId),
    idSigne varchar(10) REFERENCES signeDist(idSigne),
    PRIMARY KEY (numId, idSigne)
);


-- Employés
INSERT INTO employe (matricule, nom, prenom, adresse, numTelEmploye, dateNaissanceE, numSecu, dateArrivee, login, mdp) VALUES
('E001','Khadhri','Lina','8 rue du Puits Mottet, Villiers','0618724598','2005-10-28','123456789012345','2020-06-01','staycat','azerty1234'),
('E002','Mekki','Nesma','16 avenue des Martyrs, Chelles','0767982329','2006-01-12','987654321098765','2021-01-15','nesmiette','yuumil0ver'),
('E003','Grande','Ariana',NULL,NULL,'1994-06-25',NULL,'2023-09-01','arianagrande','wicked25'),
('E004','Lazreg','Massoud','47 rue du 18 juin, Gagny','0621945004','2005-06-06','193189765423125','2020-07-12','massoud93rpz','mdp4'),
('E005','Erivo','Cynthia',NULL,'0612345678',NULL,'87649154764985','2024-05-05','cynthiaerivo','elphabathropp'),
('E006','Pierre','Lilliane','89 rue de la Fosse aux Bergers, Villemomble',NULL,'2005-09-16',NULL,'2025-04-03','liilliane','carambolage'),
('E007','Bailey','Jonathan',NULL,'0687265148','1988-04-25','456284732105429','2024-05-01','fiyer0','dancingthroughlife'),
('E008','Slater','Ethan','16 avenue des Sycomores, Rosny-Sous-Bois','0487916452','1992-06-02','548799651420052','2021-02-18','spongebob','il0veariana'),
('E009','Yeoh','Michelle','79 avenue du Nord, Neuilly-Plaisance','0688947512','1962-08-06','187956248711047','2025-10-08','morrible','hurricane'),
('E010','Goldblum','Jeff','48 avenue Saint-Germain, Paris','0544669988','1952-10-22','998877456211035','2023-01-25','wizardofoz','yellowbrickroad'),
('E011','Carpenter','Sabrina','12 rue du Soleil, Noisy-le-Grand','0678123456','1999-05-11','125478963214785','2024-02-15','emailsick','nonsense'),
('E012','Bieber','Justin','3 rue des Artistes, Paris','0654231897','1994-03-01','748596213547895','2023-06-20','jbiebz','peaches2021'),
('E013','Lin','Laufey','14 avenue des Champs, Versailles','0765984123','1999-04-23','159753456852147','2022-08-12','meimei','nomorejunia'),
('E014','Eilish','Billie','78 boulevard Voltaire, Bondy','0613434034','2001-12-18','951753456852159','2024-09-25','billie','badguy'),
('E015','Styles','Harry','20 rue du Rivage, Meaux','0689741235','1994-02-01','357951456852159','2021-04-04','harrystyles','asitis'),
('E016','Zendaya','Maree','92 avenue de Paris, Saint-Maur','0645789123','1996-09-01','789456123654987','2020-03-10','zendaya','euphoria'),
('E017','Knowles','Beyonce','4 rue du Moulin, Créteil','0632147895','1981-09-04','654789321456987','2023-11-01','queenb','renaissance'),
('E018','Malik','Zayn','18 rue Mozart, Orsay','0625478963','1993-01-12','357159486213597','2025-02-20','zaynmalik','pillowtalk'),
('E019','Grande','Frankie','10 rue des Lilas, Levallois','0651984723','1983-01-24','789456123987654','2024-07-10','frankie','arianasbro'),
('E020','Hudgens','Vanessa','45 avenue des Peupliers, Puteaux','0667895123','1988-12-14','951456789321654','2022-10-22','vannyhud','highschool'),
('E021','Owran','Mohamad','7bis rue des deux Communes, Rosny-sous-Bois','0778560737','2006-08-11','123456789987654','2019-05-15','pouleverglas','nesmaqueen');


-- Refuge
INSERT INTO refuge (idRefuge, nom, adresse, ville, codePostal, numTelRefuge, capacite, gerant) VALUES
('R001','SPA Champs-sur-Marne','10 boulevard Descartes','Champs-sur-Marne','77420','0478654321',50,'E001'),
('R002','SPA Paris IX','25 rue Lafayette','Paris','75009','0156324789',80,'E002'),
('R003','SPA Montreuil','10 avenue Foch','Montreuil','93100',NULL,55,'E009'),
('R004','SPA Paris V','4 rue des Arenes','Paris','75005','0156457912',48,'E002'),
('R005','SPA Orsay','10 rue de Paris','Orsay','91400','0478656621',82,'E005'),
('R006','SPA Puteaux','25 rue Lafayette','Puteaux','92800','0156324789',60,'E010');


-- Fourrière
INSERT INTO fourriere (idFourriere, nom, adresse, numTelFourriere) VALUES
('F001','Fourriere Neuilly','8 rue Garibaldi','0123456789'),
('F002','Fourriere Paris','19 rue de la Paix','0198765432'),
('F003','Fourriere Montreuil','8 avenue Jean Jaurès','0155482379'),
('F004','Fourriere Torcy','10 boulevard du Centre','0188965236'),
('F005','Fourriere Lyon 2','8 rue Garibaldi','0123456789'),
('F006','Fourriere Chelles','16 boulevard Foch',NULL);


-- Adoptants
INSERT INTO adoptant (idAdoptant, nom, prenom, ville, codePostal, numTelAdoptant) VALUES
('A001','Eilish','Billie','Bondy','93130','0613434034'),
('A002','Kim','Chaewon','Paris','75012','0622334455'),
('A003','Derradji','Maïssa','Torcy','77200','0629603402'),
('A004','Mekki','Nesma','Chelles','77500','0767982329'),
('A005','Cherki','Rayan','Bondy','93140','0614768542'),
('A006','Nabil','Andrieu','Corbeil-Essones','91100','0789673910'),
('A007','Bode','Marissa','Montfermeil','93370','0688225469'),
('A008','Croche','Sarah','Villejuif','94800','0844521352'),
('A009','Yang','Bowen','Montreuil','93100','0679795624'),
('A010','Benamara','Hayam','Bonneuil','94380','0618132500');


-- Animaux (AN001–AN034)
INSERT INTO animal (numId, espece, nom, dateNaissanceA, sexe, idAdoptant, idFourriere) VALUES
('AN001','Chien','Newton','2018-11-15','M','A003','F001'),
('AN002','Chat','Yuumi','2025-03-07','M','A004','F001'),
('AN003','Lapin',NULL,'2023-03-01','M',NULL,'F002'),
('AN004','Chien','Nala',NULL,'F',NULL,'F002'),
('AN005','Chien','Baltik','2020-11-05','M',NULL,'F001'),
('AN006','Chat','Luna','2022-01-20','F','A001','F002'),
('AN007','Chien','Oscar','2019-07-13','M',NULL,'F003'),
('AN008','Chat','Misty','2023-02-28','F',NULL,'F004'),
('AN009','Lapin','Flocon','2021-09-10','M',NULL,'F005'),
('AN010','Chien','Ruby','2020-05-03','F','A002','F006'),
('AN011','Chat','Pixel','2022-06-17','M',NULL,'F001'),
('AN012','Chien','Mango','2018-03-09','M',NULL,'F002'),
('AN013','Souris','Neru','2023-04-01','F',NULL,'F003'),
('AN014','Chat','Salem','2019-10-31','M','A003','F004'),
('AN015','Chien','Jasper','2021-01-12','M',NULL,'F005'),
('AN016','Lapin','Noisette',NULL,'F','A010','F006'),
('AN017','Chat','Moka','2020-08-22','F','A001','F001'),
('AN018','Chien','Rocky','2017-12-30','M',NULL,'F002'),
('AN019','Chat','Neko','2024-02-05','M',NULL,'F003'),
('AN020','Lapin','Carotte','2022-09-19','F','A004','F004'),
('AN021','Chien','Shadow','2019-04-14','M','A010','F005'),
('AN022','Chat','Plume','2021-11-08','F',NULL,'F006'),
('AN023','Chien','Gizmo','2023-07-01','M','A005','F001'),
('AN024','Chat','Iris','2020-02-29','F',NULL,'F002'),
('AN025','Poule','Pistache','2023-01-10','M',NULL,'F003'),
('AN026','Chien','Tango','2018-09-05','M','A006','F004'),
('AN027','Chat','Litchi','2022-03-03','F',NULL,'F005'),
('AN028','Chien','Sirius','2021-06-21','M',NULL,'F006'),
('AN029','Chat','Miette','2019-01-19','F','A002','F001'),
('AN030','Chien','Lucky','2020-10-10','M',NULL,'F002'),
('AN031','Hamster','Nuage',NULL,'M',NULL,'F003'),
('AN032','Chat','Kiwi','2023-05-25','F','A008','F004'),
('AN033','Chien','Hector','2017-03-30','M','A007','F005'),
('AN034','Chat','Nina','2021-09-09','F',NULL,'F006');


-- Soins (catalogue)
INSERT INTO soin (idSoin, nomSoin, periodeRappel) VALUES
('S001','Vaccin rage','1 year'),
('S002','Sterilisation',NULL),
('S003','Vermifuge','6 months'),
('S004','Vaccin typhus','1 year'),
('S005','Vaccin leucémie féline','1 year'),
('S006','Vaccin toux du chenil','1 year'),
('S007','Détartrage',NULL),
('S008','Traitement antipuce','3 months'),
('S012','Radiographie',NULL),
('S013','Examen de routine',NULL),
('S014','Traitement gale','6 months'),
('S015','Vermifuge renforcé','6 months'),
('S016','Vaccin panleucopénie','1 year'),
('S017','Consultation vétérinaire',NULL),
('S018','Soins post-opératoires',NULL),
('S019','Nettoyage des oreilles','6 months'),
('S020','Coupe des griffes','6 months'),
('S021','Analyse de sang','1 year'),
('S022','Examens digestifs',NULL),
('S023','Traitement antiparasitaire','3 months');


-- Confie (arrivées SPA)
INSERT INTO confie (idRefuge, numId, idFourriere, dateArriveeSPA) VALUES
('R001','AN001','F001','2024-02-10'),
('R001','AN002','F001','2025-04-09'),
('R002','AN003','F002','2024-05-01'),
('R002','AN004','F002','2025-01-15'),
('R003','AN005','F001','2024-03-20'),
('R003','AN006','F002','2023-12-12'),
('R004','AN007','F003','2024-06-05'),
('R004','AN008','F004','2024-07-11'),
('R005','AN009','F005','2023-11-28'),
('R005','AN010','F006','2024-01-04'),
('R006','AN011','F001','2025-02-18'),
('R006','AN012','F002','2023-10-03'),
('R001','AN013','F003','2024-05-24'),
('R001','AN014','F004','2024-04-16'),
('R002','AN015','F005','2025-03-22'),
('R002','AN016','F006','2024-11-09'),
('R003','AN017','F001','2024-12-30'),
('R003','AN018','F002','2025-01-10'),
('R004','AN019','F003','2024-02-19'),
('R004','AN020','F004','2024-03-14'),
('R005','AN021','F005','2023-12-05'),
('R005','AN022','F006','2024-07-02'),
('R006','AN023','F001','2025-02-25');


-- Soins reçus (avec stérilisation S002 pour chaque animal)
INSERT INTO soinsRecus (idSoinsRecus, dateSoin, soignant, idSoin, numId) VALUES
('SR001','2024-02-10','E001','S002','AN001'),
('SR002','2024-03-01','E011','S001','AN001'),
('SR003','2025-04-10','E002','S002','AN002'),
('SR004','2024-05-01','E003','S002','AN003'),
('SR005','2024-06-15','E013','S004','AN003'),
('SR006','2024-07-11','E011','S002','AN004'),
('SR007','2024-03-20','E015','S002','AN005'),
('SR008','2024-03-22','E012','S002','AN006'),
('SR009','2025-01-15','E013','S002','AN007'),
('SR010','2024-09-18','E014','S002','AN008'),
('SR011','2024-10-11','E002','S002','AN009'),
('SR012','2025-02-02','E019','S002','AN010'),
('SR013','2024-04-14','E020','S002','AN011'),
('SR014','2024-11-19','E002','S002','AN012'),
('SR015','2024-03-03','E005','S002','AN013'),
('SR016','2024-07-07','E017','S002','AN014'),
('SR017','2024-06-28','E020','S002','AN015'),
('SR018','2025-03-25','E011','S002','AN016'),
('SR019','2024-05-02','E014','S002','AN017'),
('SR020','2024-12-03','E015','S002','AN018'),
('SR021','2024-08-17','E017','S002','AN019'),
('SR022','2025-01-09','E019','S002','AN020'),
('SR023','2024-09-10','E020','S002','AN021'),
('SR024','2024-10-22','E002','S002','AN022'),
('SR025','2025-02-05','E013','S002','AN023'),
('SR026','2024-12-14','E015','S002','AN024'),
('SR027','2025-03-16','E017','S002','AN025'),
('SR028','2024-06-06','E018','S002','AN026'),
('SR029','2024-08-25','E020','S002','AN027'),
('SR030','2025-01-28','E012','S002','AN028'),
('SR031','2024-04-17','E014','S002','AN029'),
('SR032','2024-07-20','E016','S002','AN030'),
('SR033','2024-09-30','E017','S002','AN031'),
('SR034','2025-02-12','E019','S002','AN032'),
('SR035','2024-11-15','E011','S002','AN033'),
('SR036','2025-03-10','E013','S002','AN034'),
('SR037','2024-04-20','E012','S003','AN002'),
('SR038','2024-05-10','E015','S008','AN009'),
('SR039','2024-11-05','E018','S005','AN017'),
('SR040','2025-01-15','E019','S001','AN023');


-- Fonctions
INSERT INTO fonction (idFonction, nomFonction) VALUES
('FCT1','Veterinaire'),
('FCT2','Soigneur'),
('FCT3','Gerant'),
('FCT4','Hotesse'),
('FCT5','Assistant'),
('FCT6','Responsable'),
('FCT7','Agent entretien'),
('FCT8','Coordinateur');


-- Occupe (affectations)
INSERT INTO occupe (idRefuge, matricule, idFonction) VALUES
('R001','E001','FCT3'),
('R001','E021','FCT2'),
('R001','E011','FCT1'),
('R001','E004','FCT2'),
('R001','E015','FCT4'),
('R002','E002','FCT3'),
('R002','E012','FCT1'),
('R002','E005','FCT2'),
('R002','E016','FCT6'),
('R003','E009','FCT3'),
('R003','E013','FCT1'),
('R003','E014','FCT2'),
('R003','E019','FCT4'),
('R004','E010','FCT3'),
('R004','E018','FCT1'),
('R004','E006','FCT2'),
('R004','E020','FCT5'),
('R005','E005','FCT3'),
('R005','E017','FCT1'),
('R005','E003','FCT2'),
('R005','E008','FCT7'), 
('R006','E007','FCT3'),
('R006','E019','FCT1'),
('R006','E009','FCT8'),
('R001','E011','FCT5'), 
('R002','E012','FCT8'), 
('R004','E020','FCT6');


-- Accueille (transferts)
INSERT INTO accueille (idRefugeOrigine, idRefugeArrivee, numId, dateDepart, dateArrivee) VALUES
('R001','R002','AN001','2024-06-01','2024-06-03'),
('R002','R005','AN001','2024-09-10','2024-09-12'),
('R002','R001','AN003','2025-03-10','2025-03-12'),
('R001','R004','AN003','2025-05-05','2025-05-07'),
('R003','R004','AN005','2024-07-15','2024-07-17'),
('R004','R005','AN007','2024-08-10','2024-08-11'),
('R005','R006','AN007','2025-02-05','2025-02-06'),
('R005','R006','AN009','2024-09-01','2024-09-03'),
('R006','R003','AN009','2025-01-20','2025-01-22'),
('R003','R001','AN009','2025-04-10','2025-04-12'),
('R001','R005','AN013','2024-06-18','2024-06-20'),
('R003','R006','AN017','2025-04-12','2025-04-14'),
('R006','R002','AN017','2025-06-10','2025-06-12'),
('R005','R004','AN021','2024-12-02','2024-12-04'),
('R004','R005','AN021','2025-03-15','2025-03-17'),
('R006','R005','AN023','2025-02-28','2025-03-02');


-- Signes distinctifs
INSERT INTO signeDist (idSigne, description) VALUES
('SG01','Sourcils de couleurs différentes'),
('SG02','Tache blanche sur le dos'),
('SG03','Oreille gauche entaillée'),
('SG04','Cicatrice sur la patte arrière droite'),
('SG05','Tache noire autour de l’oeil gauche'),
('SG06','Queue écourtée naturellement'),
('SG07','Pelage bicolore noir et roux'),
('SG08','Museau plus clair que le reste du pelage'),
('SG09','Griffe cassée sur la patte avant gauche'),
('SG10','Oeil droit de couleur bleue, gauche marron');

-- Liaison animal_signe
INSERT INTO animal_signe (numId, idSigne) VALUES
('AN001','SG02'),
('AN002','SG01'),
('AN003','SG03'),
('AN004','SG07'),
('AN005','SG08'),
('AN007','SG05'),
('AN009','SG10'),
('AN010','SG08'),
('AN010','SG03'),
('AN012','SG04'),
('AN012','SG06'),
('AN014','SG05'),
('AN015','SG10'),
('AN015','SG09'),
('AN017','SG07'),
('AN020','SG08'),
('AN020','SG05'),
('AN021','SG09'),
('AN024','SG01'),
('AN026','SG08'),
('AN028','SG10'),
('AN030','SG08'),
('AN030','SG09'),
('AN032','SG02'),
('AN034','SG04');




-- Liste des animaux à vacciner :
CREATE VIEW animauxaVacciner AS 

(   SELECT a.numId, a.nom AS nomAnimal, a.espece, c.idRefuge, s.idSoin, s.nomSoin, sr.dateSoin AS dateDernierVaccin, (sr.dateSoin + s.periodeRappel) AS dateProchainRappel
    FROM soinsRecus AS sr
    JOIN soin AS s ON s.idSoin = sr.idSoin
    JOIN animal AS a ON a.numId = sr.numId
    JOIN confie AS c ON c.numId = a.numId
    WHERE s.nomSoin LIKE 'Vaccin%'
    AND s.periodeRappel IS NOT NULL
    AND sr.dateSoin = CURRENT_DATE
);
-- Top 5 des refuges avec le + de transferts sortants
CREATE VIEW RefugesTransfertsSortants AS

(   SELECT r.idRefuge, r.nom, COUNT(*) AS nb_transferts_sortants
    FROM accueille AS a
    JOIN refuge AS r ON r.idRefuge = a.idRefugeOrigine
    WHERE a.dateDepart >= (CURRENT_DATE - INTERVAL '1 year')
    GROUP BY r.idRefuge, r.nom
    ORDER BY nb_transferts_sortants DESC
    LIMIT 5
); (SELECT MAX(sr2.dateSoin) FROM soinsRecus sr2 WHERE sr2.numId = sr.numId AND sr2.idSoin = sr.idSoin)
    AND sr.dateSoin + s.periodeRappel <= CURRENT_DATE
);
-- Top 5 des refuges avec le + de transferts sortants
CREATE VIEW RefugesTransfertsSortants AS

(   SELECT r.idRefuge, r.nom, COUNT(*) AS nb_transferts_sortants
    FROM accueille AS a
    JOIN refuge AS r ON r.idRefuge = a.idRefugeOrigine
    WHERE a.dateDepart >= (CURRENT_DATE - INTERVAL '1 year')
    GROUP BY r.idRefuge, r.nom
    ORDER BY nb_transferts_sortants DESC
    LIMIT 5
);

/* Cas speciaux

-- Concernant la table employe:

--1) les employés qui sont gérents de plusieurs refuges
SELECT gerant, COUNT(*) AS nb_refuges
FROM refuge
GROUP BY gerant
HAVING COUNT(*) > 1;
-- renvoie par exemple l'employée E002 gère 2 refuges 

--2) les employés travaillant dans plusieurs refuges
SELECT matricule, COUNT(DISTINCT numRefuge) AS nb_refuges
FROM occupe
GROUP BY matricule
HAVING COUNT(DISTINCT numRefuge) > 1;
-- renvoie par exemple E019 travaille dans 2 refuges

--3) les employés ayant plusieurs fonctions dans le même refuge
SELECT matricule, numRefuge, COUNT(*) AS nb_fonctions
FROM occupe
GROUP BY matricule, numRefuge
HAVING COUNT(*) > 1;
-- renvoie par exemple E011 a 2 fonctions dans le refuge R001

--4) les employés sans fonction
SELECT e.matricule, e.nom, e.prenom
FROM employe e
WHERE e.matricule NOT IN (SELECT matricule FROM occupe);
-- renvoie par exemple E020 n'a aucune fonction attribuée 
--(= incohérent mais possible dans les limites du sujet)

-- Concernant la table refuge:

--1) refuges sans animaux confiés
SELECT r.numRefuge, r.nomRefuge
FROM refuge r
WHERE r.numRefuge NOT IN (SELECT numRefuge FROM confie);
-- renvoie par exemple R006 n'a actuellement aucun animal confié

-- Concernant la table aniaml:

--1) les animaux transférés plusieurs fois
SELECT numAnimal, COUNT(*) AS nb_transferts
FROM accueille
GROUP BY numAnimal
HAVING COUNT(*) > 1;
--renvoie par exemple AN001 a été transféré 3 fois

--2) les animaux avec plusieurs signes distinctifs
SELECT numAnimal, COUNT(*) AS nb_signes
FROM animal_signe
GROUP BY numAnimal
HAVING COUNT(*) > 1;
-- renvoie par exemple AN002 a 2 signes disticntifs

-- Concernant la table adoptant:

--1) personnes ayant adoptés plusieurs animaux
SELECT idAdoptant, COUNT(*) AS nb_adoptions
FROM animal
WHERE idAdoptant IS NOT NULL
GROUP BY idAdoptant
HAVING COUNT(*) > 1;
-- renvoie par exemple l'adoptant A001 a adopté 2 animaux

--2) les adoptants qui sont aussi des employés
SELECT a.idAdoptant, a.nomAdoptant, a.prenomAdoptant
FROM adoptant a
JOIN employe e 
  ON a.nomAdoptant = e.nom AND a.prenomAdoptant = e.prenom;
-- renvoie par exemple A001 et A004 sont à la fois employés et adoptants

-- Concernant la table soin:

--1)les animaux sans soin reçu
SELECT a.numAnimal, a.nomAnimal
FROM animal a
WHERE a.numAnimal NOT IN (SELECT numAnimal FROM soinRecu);
-- renvoie par exemple l'animal AN014 nommé Simba 
--n'a reçu aucun soin (limite de la base de données)

--2)les soins faits par un non-vétérinaire
SELECT s.numAnimal, s.soignant
FROM soinRecu s
WHERE s.soignant NOT IN (
    SELECT o.matricule
    FROM occupe o
    WHERE o.numFonction = 'FCT1'
);
--renvoie par exemple E010 a pratiqué un soin 
--sans être vétérionaire (limite de la base de données)


-- Concernant la table transfert:

--1) les animaux transférés le même jour (arrivée = départ)
SELECT numAnimal, numRefuge, dateArrivee, dateDepart
FROM accueille
WHERE dateArrivee = dateDepart;
--renvoie par exemple AN005 n'a passé qu'une journée dans le refuge R002

-- Cas transversaux

--1) les adoptants ayant adopté plusieurs animaux de refuges différents
SELECT a.idAdoptant, COUNT(DISTINCT c.numRefuge) AS nb_refuges
FROM animal an
JOIN adoptant a ON an.idAdoptant = a.idAdoptant
JOIN confie c ON an.numAnimal = c.numAnimal
GROUP BY a.idAdoptant
HAVING COUNT(DISTINCT c.numRefuge) > 1;

--2) les animaux transférés dans leur propre refuge d'origine
SELECT a.numAnimal, a.numRefuge
FROM accueille a
JOIN confie c ON a.numAnimal = c.numAnimal
WHERE a.numRefuge = c.numRefuge;
*/




