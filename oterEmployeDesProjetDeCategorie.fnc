CREATE OR REPLACE FUNCTION oterEmployeDesProjet(emp_nom VARCHAR2, cat_nom VARCHAR2) RETURN VARCHAR2
IS
    -- D�claration de variable pour stocker les noms de projets
    v_projets_desaffectes VARCHAR2(4000);
BEGIN
    -- D�claration de variables pour stocker les IDs
    DECLARE
        v_emp_no NUMBER;
        v_cat_no NUMBER;
    BEGIN
        -- R�cup�rer l'ID de l'employ� en fonction du nom
        SELECT emp_no INTO v_emp_no
        FROM exa_employe
        WHERE emp_nom_prenom = emp_nom;

        -- R�cup�rer l'ID de la cat�gorie en fonction du nom
        SELECT cat_no INTO v_cat_no
        FROM exa_categorie
        WHERE cat_nom = cat_nom;

        -- S�lectionner les noms des projets avant la suppression
        SELECT LISTAGG(pro_nom, ', ') WITHIN GROUP (ORDER BY pro_nom)
        INTO v_projets_desaffectes
        FROM exa_projet
        WHERE pro_no IN (SELECT aff_pro_no FROM exa_affectation WHERE aff_emp_no = v_emp_no);

        -- Supprimer les affectations pour l'employ� et la cat�gorie sp�cifi�s
        DELETE FROM exa_affectation
        WHERE aff_emp_no = v_emp_no
          AND aff_pro_no IN (SELECT pro_no FROM exa_projet WHERE pro_cat_no = v_cat_no);

        -- Retourner les noms des projets d�saffect�s
        RETURN v_projets_desaffectes;
    END;
END oterEmployeDesProjet;
/
