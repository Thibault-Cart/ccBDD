CREATE OR REPLACE TRIGGER TRG_UPDATE_VW_EXA_PROJET
  INSTEAD OF UPDATE ON VW_EXA_PROJETS
  FOR EACH ROW
DECLARE
  V_PROJET_EXISTE          NUMBER;
  V_PROJET_CAT_NOM         VARCHAR2(10);
  V_CAT_EXISTE             NUMBER;
  V_CAT_NO                 NUMBER;
  V_EMPLOYE_EXISTE         NUMBER;
  V_EMP_NO                 NUMBER;
  V_PROJET_NO              NUMBER;
  V_AFFECTATION_EXISTEDEJA NUMBER;
BEGIN
  -- regarde si employer existe
  SELECT COUNT(*)
    INTO V_EMPLOYE_EXISTE
    FROM EXA_EMPLOYE E
   WHERE E.EMP_NOM_PRENOM LIKE :NEW.EMPLOYES;

  -- si employer pas dans la base
  IF (V_EMPLOYE_EXISTE = 0) THEN
    RAISE_APPLICATION_ERROR(-20001, 'L employer n existe pas ');
  END IF;

  -- recuperation id employer
  SELECT E.EMP_NO
    INTO V_EMP_NO
    FROM EXA_EMPLOYE E
   WHERE E.EMP_NOM_PRENOM LIKE :NEW.EMPLOYES;

  -- regarde si projet existe
  SELECT COUNT(*)
    INTO V_PROJET_EXISTE
    FROM VW_EXA_PROJETS EP
   WHERE EP.PROJET LIKE 'MIGR';
  V_PROJET_CAT_NOM := :NEW.CATEGORIE;

  -- si projet existe 
  IF (V_PROJET_EXISTE > 0) THEN
        DBMS_OUTPUT.PUT_LINE(:NEW.projet||' existe');

    -- regarde si cat existe
    SELECT COUNT(*)
      INTO V_CAT_EXISTE
      FROM EXA_CATEGORIE C
     WHERE C.CAT_NOM LIKE V_PROJET_CAT_NOM;
  
    -- si cat existe pas creation cat
    IF (V_CAT_EXISTE = 0) THEN
      INSERT INTO EXA_CATEGORIE C VALUES (NULL, V_PROJET_CAT_NOM);
      DBMS_OUTPUT.PUT_LINE(V_PROJET_CAT_NOM||' cat cree');

    END IF;
  
    -- recuperation No cat
    SELECT C.CAT_NO
      INTO V_CAT_NO
      FROM EXA_CATEGORIE C
     WHERE C.CAT_NOM LIKE V_PROJET_CAT_NOM;
  
  ELSE
  
    RAISE_APPLICATION_ERROR(-20001,
                            'Impossible de creer un projet lors d un UPDATE');
  END IF;
  -- recuperation id projet
  SELECT P.PRO_NO
    INTO V_PROJET_NO
    FROM EXA_PROJET P
   WHERE P.PRO_NOM LIKE :NEW.PROJET;

  -- verifie si affectation deja presente
  SELECT COUNT(*)
    INTO V_AFFECTATION_EXISTEDEJA
    FROM EXA_AFFECTATION A
   WHERE A.AFF_EMP_NO = V_EMP_NO
     AND A.AFF_PRO_NO = V_PROJET_NO;

  IF (V_AFFECTATION_EXISTEDEJA = 0) THEN
    -- creation affectation
    INSERT INTO EXA_AFFECTATION VALUES (V_PROJET_NO, V_EMP_NO);
    DBMS_OUTPUT.PUT_LINE(:NEW.EMPLOYES || 'a �t� affect� au projet' ||
                         :NEW.PROJET);
  END IF;

END TRG_UPDATE_VW_EXA_PROJET;
/
