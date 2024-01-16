package metier;

import dao.Bdd;
import org.bson.Document;

import java.sql.ResultSet;
import java.util.HashMap;

import static dao.Bdd.neo4j;
import static dao.Bdd.oracle;

public class AffectationProjets {
    public AffectationProjets() {
        Bdd.connect();  // vous aurez donc accès direct aux 3 variables : oracle, mongo & neo4j
        mettreAJourToutesLesBases();
    }

    private void mettreAJourToutesLesBases() {
        System.out.println("Mise-à-jour des données dans les 3 bdd...");
        // TODO: vous pouvez tout faire dans cette procédure !
        try {
            ResultSet allProject = oracle.createStatement().executeQuery("SELECT * FROM VW_EXA_PROJETS ");
            while (allProject.next()) {
                // ajout des projets dans mongoDB
                String nom = allProject.getString("PROJET");
                String description = allProject.getString("DESCRIPTION");
                int priorite = allProject.getInt("PRIORITE");
                String catNom = allProject.getString("CATEGORIE");

                ResultSet cat_no = oracle.createStatement().executeQuery("SELECT c.cat_no FROM exa_categorie c  WHERE c.cat_nom LIKE '" + catNom + "'");
                cat_no.next();
                int cat_id = cat_no.getInt("cat_no");

                Bdd.mongo.getCollection("Projets").insertOne(new Document("nom", nom).append("description", description).append("priorite", priorite).append("categorie", catNom));

                // ajout categorie si exsite pas deja
                Bdd.neo4j.run("MERGE (c:categorie {id: '" + cat_id + "'})\n" + "ON CREATE SET c.id = '" + cat_id + "' , c.nom = '" + catNom + "'");
                // ajout du projet dans neo4j
                Bdd.neo4j.run("MATCH (n:Projet {nom: '" + nom + "'})\n" + "SET n.description = '" + description + "', n.priorite = " + priorite + ", n.categorie = '" + catNom + "'");
                // creation lien entre projet et categorie
                neo4j.run("MATCH (p:Projet {nom: '" + nom + "'}), (c:categorie {nom: '" + catNom + "'}) MERGE (p)-[:EST]->(c)");
            }
            var data = neo4j.run("MATCH (n:Employe)-[r:AFFECTE]-(m:Projet)\n" + "RETURN n, r, m");

           
            while (data.hasNext()) {
                // ajout des affectations dans mongoDB
                String nom = data.next().get("n").get("nom").asString();
                String projet = data.next().get("m").get("nom").asString();
                oracle.createStatement().executeUpdate("UPDATE VW_EXA_PROJETS SET PROJET = '" + projet + "' WHERE EMPLOYES = '" + nom + "'");

                /* marche pas encore

                Document employerDocument = mongo.getCollection("Employer").find(new Document("nom", nom)).first();

                if (employerDocument != null) {

                    String employerIdToUpdate = employerDocument.getObjectId("_id").toString();

                    /
                    Document projectDocument = mongo.getCollection("Projet").find(new Document("nom",projet)).first();

                    if (projectDocument != null) {

                        Document updateDocument = new Document("$push", new Document("projects", projectDocument));


                        mongo.getCollection("Employer").updateOne(new Document("_id", employerIdToUpdate), updateDocument);
                    }
                    */


            }
            /*
            for (var entry : arrayProjet.entrySet()) {
                mongo.getCollection("Employes").updateOne(new Document("nom", entry.getKey()), new Document("$set", entry.getValue()));
            }
*/

        } catch (Exception e) {
            e.printStackTrace();
        }


    }
}