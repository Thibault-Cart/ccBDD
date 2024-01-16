package dao;

import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import org.bson.Document;
import org.neo4j.driver.AuthTokens;
import org.neo4j.driver.GraphDatabase;
import org.neo4j.driver.Session;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class Bdd {
    // TODO: indiquez vos url de connexion ainsi que les mots-de-passe de vos bdd
    private static final String URL_MONGO = "mongodb://localhost";
    private static final String URL_NEO4J = "neo4j+s://b8f1d9ca.databases.neo4j.io";
    private static final String PWD_NEO4J = "M5X2-2LttZWaLzaRtqSyt4jq28cWvu9YgO0xFiKDxq4";
    private static final String URL_ORACLE = "jdbc:oracle:thin:@localhost:1521:";
    private static final String BDD_ORACLE = "XE";
    private static final String USR_ORACLE = "system";
    private static final String PWD_ORACLE = "suisse200";

    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // !!!!!           NE MODIFIEZ PAS LE CODE DE CETTE CLASSE           !!!!!
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    public static Connection oracle = null;
    public static MongoDatabase mongo = null;
    public static Session neo4j = null;

    public static void connect() {
        System.out.print("Connection aux 3 bdd (oracle, mongo, neo4j) ... ");
        Logger.getLogger("org.mongodb.driver").setLevel(Level.SEVERE);
        try { oracle = DriverManager.getConnection(URL_ORACLE+BDD_ORACLE, USR_ORACLE, PWD_ORACLE); } catch (SQLException e) { e.printStackTrace(); throw new RuntimeException(e); }
        mongo = MongoClients.create(URL_MONGO).getDatabase("AffectationProjets");
        neo4j = GraphDatabase.driver(URL_NEO4J, AuthTokens.basic("neo4j", PWD_NEO4J)).session();
        String[] t = {"{'no':101,'nom':'Arial Alba','fonction':'Responsable projet'}", "{'no':102,'nom':'Babst Béa','fonction':'Analyste'}", "{'no':103,'nom':'Chollet Carl','fonction':'DBA'}", "{'no':104,'nom':'Dubois Dan','fonction':'Développeur'}", "{'no':105,'nom':'Emery Emily','fonction':'Développeuse'}", "{'no':106,'nom':'Favre Flavie','fonction':'Ingénieure réseau'}", "{'no':107,'nom':'Giroud Guy','fonction':'Développeur'}"};
        MongoCollection coll = mongo.getCollection("Employes"); coll.drop(); for (int i=0; i<t.length; i++) { coll.insertOne(Document.parse(t[i])); }
        neo4j.run("MATCH (n) DETACH DELETE n"); neo4j.run("CREATE (p1:Projet{nom:'NOSQ'}), (p2:Projet{nom:'MODL'}), (p3:Projet{nom:'GEST'}), (p4:Projet{nom:'CSCO'}), (p5:Projet{nom:'MIGR'}), (e1:Employe{no:101,nom:'Arial Alba',fonction:'Responsable projet'}), (e2:Employe{no:102,nom:'Babst Béa',fonction:'Analyste'}), (e3:Employe{no:103,nom:'Chollet Carl',fonction:'DBA'}), (e4:Employe{no:104,nom:'Dubois Dan',fonction:'Développeur'}), (e5:Employe{no:105,nom:'Emery Emily',fonction:'Développeuse'}), (e6:Employe{no:106,nom:'Favre Flavie',fonction:'Ingénieure réseau'}), (e7:Employe{no:107,nom:'Giroud Guy',fonction:'Développeur'}), (e1)-[:AFFECTE]->(p1),(e1)-[:AFFECTE]->(p3),(e2)-[:AFFECTE]->(p1),(e2)-[:AFFECTE]->(p2),(e4)-[:AFFECTE]->(p1),(e5)-[:AFFECTE]->(p1),(e5)-[:AFFECTE]->(p2),(e5)-[:AFFECTE]->(p3),(e6)-[:AFFECTE]->(p4), (e1)-[:AFFECTE]->(p5),(e3)-[:AFFECTE]->(p1),(e3)-[:AFFECTE]->(p5)");
        System.out.println("ok, bases mongodb & neo4j remplies !");
    }
}