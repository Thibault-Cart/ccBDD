/* ----------------------------------------------------------------------------
Script : 62-31 - BDD-PL/SQL - Exa-AffectationProjets-CreerEnv.sql    Auteur : Ch. Stettler
Objet  : Création et remplissage des tables pour l'examen du 16/01/2024 - AffectationProjets
---------------------------------------------------------------------------- */

DROP TABLE exa_affectation;
DROP TABLE exa_employe;
DROP TABLE exa_projet;
DROP TABLE exa_categorie;
DROP VIEW vw_exa_projets;
DROP SEQUENCE sq_exa_categorie_no;
DROP SEQUENCE sq_exa_projet_no;
DROP SEQUENCE sq_exa_employe_no;

CREATE TABLE exa_categorie (
   cat_no          NUMBER(5)    CONSTRAINT pk_exa_categorie PRIMARY KEY,
   cat_nom         VARCHAR2(20) CONSTRAINT uk_cat_nom UNIQUE
);

CREATE TABLE exa_projet (
   pro_no          NUMBER(5)    CONSTRAINT pk_exa_projet PRIMARY KEY,
   pro_nom         VARCHAR2(20) CONSTRAINT uk_pro_nom UNIQUE,
   pro_descr       VARCHAR2(50),
   pro_priorite    NUMBER(5)    CONSTRAINT uk_pro_priorite UNIQUE,
   pro_cat_no      NUMBER(5)    CONSTRAINT fk_exa_categorie_projet REFERENCES exa_categorie(cat_no) CONSTRAINT nn_pro_cat_no NOT NULL
);

CREATE TABLE exa_employe (
   emp_no          NUMBER(5)    CONSTRAINT pk_exa_employe PRIMARY KEY,
   emp_nom_prenom  VARCHAR2(20),
   emp_fonction    VARCHAR2(30)
);

CREATE TABLE exa_affectation (
   aff_pro_no      NUMBER(5)    CONSTRAINT fk_exa_affect_projet  REFERENCES exa_projet(pro_no),
   aff_emp_no      NUMBER(5)    CONSTRAINT fk_exa_affect_employe REFERENCES exa_employe(emp_no),
   CONSTRAINT pk_exa_affectation PRIMARY KEY (aff_pro_no, aff_emp_no)
);

CREATE SEQUENCE sq_exa_categorie_no;
CREATE SEQUENCE sq_exa_projet_no START WITH 11;
CREATE SEQUENCE sq_exa_employe_no START WITH 101;
CREATE OR REPLACE TRIGGER exa_NumeroNewCategorie BEFORE INSERT ON exa_categorie FOR EACH ROW BEGIN :NEW.cat_no:=sq_exa_categorie_no.nextval; END;
/
CREATE OR REPLACE TRIGGER exa_NumeroNewProjet BEFORE INSERT ON exa_projet FOR EACH ROW BEGIN :NEW.pro_no:=sq_exa_projet_no.nextval; END;
/
CREATE OR REPLACE TRIGGER exa_NumeroNewEmploye BEFORE INSERT ON exa_employe FOR EACH ROW BEGIN :NEW.emp_no:=sq_exa_employe_no.nextval; END;
/
CREATE OR REPLACE VIEW vw_exa_projets (PROJET, DESCRIPTION, CATEGORIE, PRIORITE, EMPLOYES) AS 
   SELECT pro_nom, pro_descr, cat_nom, pro_priorite, (SELECT LISTAGG(emp_nom_prenom, ' & ') WITHIN GROUP (ORDER BY emp_nom_prenom) FROM exa_employe JOIN exa_affectation ON aff_emp_no=emp_no WHERE aff_pro_no=pro_no) FROM exa_projet JOIN exa_categorie ON cat_no=pro_cat_no ORDER BY pro_priorite;

INSERT INTO exa_categorie VALUES (NULL, 'BDD');
INSERT INTO exa_categorie VALUES (NULL, 'Développement');
INSERT INTO exa_categorie VALUES (NULL, 'Réseau');
COMMIT;

INSERT INTO exa_projet VALUES (NULL, 'NOSQ', 'MongoDB & neo4j', 2, 1);
INSERT INTO exa_projet VALUES (NULL, 'MODL', 'Modélisation', 1, 1);
INSERT INTO exa_projet VALUES (NULL, 'GEST', 'Application de gestion', 4, 2);
INSERT INTO exa_projet VALUES (NULL, 'CSCO', 'Configuration Cisco', 9, 3);
INSERT INTO exa_projet VALUES (NULL, 'MIGR', 'Migration des données', 5, 1);
COMMIT;

INSERT INTO exa_employe VALUES (NULL, 'Arial Alba', 'Responsable projet');
INSERT INTO exa_employe VALUES (NULL, 'Babst Béa', 'Analyste');
INSERT INTO exa_employe VALUES (NULL, 'Chollet Carl', 'DBA');
INSERT INTO exa_employe VALUES (NULL, 'Dubois Dan', 'Développeur');
INSERT INTO exa_employe VALUES (NULL, 'Emery Emily', 'Développeuse');
INSERT INTO exa_employe VALUES (NULL, 'Favre Flavie', 'Ingénieure réseau');
INSERT INTO exa_employe VALUES (NULL, 'Giroud Guy', 'Développeur');
COMMIT;

INSERT INTO exa_affectation VALUES (11, 101);
INSERT INTO exa_affectation VALUES (11, 102);
INSERT INTO exa_affectation VALUES (11, 104);
INSERT INTO exa_affectation VALUES (11, 105);
INSERT INTO exa_affectation VALUES (12, 102);
INSERT INTO exa_affectation VALUES (12, 105);
INSERT INTO exa_affectation VALUES (13, 101);
INSERT INTO exa_affectation VALUES (13, 105);
INSERT INTO exa_affectation VALUES (14, 106);
COMMIT;
