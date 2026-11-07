from flask import Flask, render_template, request, redirect, url_for, session
from db import connect
from datetime import timedelta
import random

app = Flask(__name__)
app.secret_key = b"spa_super_secret_key"
app.permanent_session_lifetime = timedelta(days=7)


# partie publique

@app.route("/")
def accueil():
    return render_template("accueil.html")


@app.route("/refuges")
def refuges():
    tri = request.args.get("tri", "ville")

    if tri == "codepostal":
        order_by = "codepostal, nom"
    else:
        order_by = "ville, nom"

    with connect() as conn:
        with conn.cursor() as cur:
            cur.execute(f"""
                SELECT idrefuge, nom, ville, codepostal
                FROM refuge
                ORDER BY {order_by}
            """)
            refuges = cur.fetchall()

    return render_template("refuges.html", refuges=refuges, tri=tri)


@app.route("/refuges/<idRefuge>")
def refuge_detail(idRefuge):
    with connect() as conn:
        with conn.cursor() as cur:
            # infos refuge
            cur.execute("""
                SELECT idrefuge, nom, adresse, ville, codepostal,
                       numtelrefuge, capacite
                FROM refuge
                WHERE idrefuge = %s
            """, (idRefuge,))
            refuge = cur.fetchone()
            if refuge is None:
                return "Refuge introuvable", 404
            cur.execute("""
                WITH refuge_infos AS (
                    SELECT a.numid,
                           c.idrefuge AS refuge_initial,
                           c.idfourriere,
                           (
                             SELECT ac.idrefugearrivee
                             FROM accueille ac
                             WHERE ac.numid = a.numid
                             ORDER BY ac.datearrivee DESC
                             LIMIT 1
                           ) AS dernier_refuge
                    FROM animal a
                    JOIN confie c ON c.numid = a.numid
                )
                SELECT an.numid, an.nom, an.espece, an.sexe,
                       an.datenaissancea,
                       fa.nom AS nom_fourriere,
                       ad.nom AS nom_adoptant, ad.prenom AS prenom_adoptant,
                       ri.refuge_initial, ri.dernier_refuge
                FROM animal an
                JOIN refuge_infos ri ON ri.numid = an.numid
                LEFT JOIN fourriere fa ON fa.idfourriere = ri.idfourriere
                LEFT JOIN adoptant ad ON ad.idadoptant = an.idadoptant
            """)
            lignes = cur.fetchall()

    #on garde que ceux qui sont dans ce refuge for now
    animaux = []
    for a in lignes:
        refuge_actuel = a.dernier_refuge if a.dernier_refuge is not None else a.refuge_initial
        if str(refuge_actuel) == str(idRefuge):
            animaux.append(a)

    return render_template("refuge_detail.html",
                           refuge=refuge,
                           animaux=animaux)


@app.route("/refuges/<idRefuge>/ajout_animal", methods=["GET", "POST"])
def ajout_animal(idRefuge):
    if "matricule" not in session:
        return redirect(url_for("login"))

    if request.method == "GET":
        with connect() as conn:
            with conn.cursor() as cur:
                cur.execute("""
                    SELECT idfourriere, nom
                    FROM fourriere
                    ORDER BY nom
                """)
                fourrieres = cur.fetchall()

        return render_template("ajout_animal.html",
                               idRefuge=idRefuge,
                               fourrieres=fourrieres)

    nom = request.form.get("nom") or None
    espece = request.form.get("espece")
    date_naiss = request.form.get("dateNaissanceA") or None
    sexe = request.form.get("sexe")
    idFourriere = request.form.get("idFourriere")

    with connect() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT numid
                FROM animal
                WHERE numid LIKE 'AN%'
                ORDER BY numid DESC
                LIMIT 1
            """)
            row = cur.fetchone()
            if row:
                dernier = row.numid
                num = int(dernier[2:]) + 1
            else:
                num = 1
            new_numid = f"AN{num:03d}"

            cur.execute("""
                INSERT INTO animal(numid, espece, nom, datenaissancea, sexe,
                                   idadoptant, idfourriere)
                VALUES (%s, %s, %s, %s, %s, NULL, %s)
            """, (new_numid, espece, nom, date_naiss, sexe, idFourriere))

            cur.execute("""
                INSERT INTO confie(idrefuge, numid, idfourriere, datearriveespa)
                VALUES (%s, %s, %s, CURRENT_DATE)
            """, (idRefuge, new_numid, idFourriere))

    return redirect(url_for("refuge_detail", idRefuge=idRefuge))


@app.route("/animal/<numId>")
def animal_detail(numId):
    with connect() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT numid, nom, espece, datenaissancea, sexe,
                       idadoptant, idfourriere
                FROM animal
                WHERE numid = %s
            """, (numId,))
            animal = cur.fetchone()
            if animal is None:
                return "Animal introuvable", 404

            cur.execute("""
                SELECT s.description
                FROM signedist s
                JOIN animal_signe asg ON asg.idsigne = s.idsigne
                WHERE asg.numid = %s
            """, (numId,))
            signes = cur.fetchall()

    return render_template("animal_detail.html", animal=animal, signes=signes)


@app.route("/animal/<numId>/adoption", methods=["GET", "POST"])
def adoption(numId):
    if "matricule" not in session:
        return redirect(url_for("login"))

    with connect() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT numid, nom, espece, idadoptant
                FROM animal
                WHERE numid = %s
            """, (numId,))
            animal = cur.fetchone()

            if animal is None:
                return "Animal introuvable", 404

            if animal.idadoptant is not None:
                return redirect(url_for("animal_detail", numId=numId))

            if request.method == "GET":
                cur.execute("""
                    SELECT idadoptant, nom, prenom, ville, codepostal
                    FROM adoptant
                    ORDER BY nom, prenom
                """)
                adoptants = cur.fetchall()

                return render_template("adoption.html",
                                       animal=animal,
                                       adoptants=adoptants)

            choix = request.form.get("type_adoptant")

            if choix == "existant":
                idAdoptant = request.form.get("idAdoptant")
            else:
                nom = request.form.get("nomAdoptant")
                prenom = request.form.get("prenomAdoptant")
                ville = request.form.get("villeAdoptant") or None
                codePostal = request.form.get("codePostal") or None
                tel = request.form.get("numTelAdoptant") or None

                cur.execute("""
                    SELECT idadoptant
                    FROM adoptant
                    WHERE idadoptant LIKE 'A%'
                    ORDER BY idadoptant DESC
                    LIMIT 1
                """)
                row = cur.fetchone()
                if row:
                    dernier = row.idadoptant
                    num = int(dernier[1:]) + 1
                else:
                    num = 1
                idAdoptant = f"A{num:03d}"

                cur.execute("""
                    INSERT INTO adoptant(idadoptant, nom, prenom, ville, codepostal, numteladoptant)
                    VALUES (%s, %s, %s, %s, %s, %s)
                """, (idAdoptant, nom, prenom, ville, codePostal, tel))

            cur.execute("""
                UPDATE animal
                SET idadoptant = %s
                WHERE numid = %s
            """, (idAdoptant, numId))

    return redirect(url_for("animal_detail", numId=numId))

@app.route("/animal/<numId>/transfert", methods=["GET", "POST"])
def transfert(numId):
    if "matricule" not in session:
        return redirect(url_for("login"))

    with connect() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT numid, nom, espece
                FROM animal
                WHERE numid = %s
            """, (numId,))
            animal = cur.fetchone()
            if animal is None:
                return "Animal introuvable", 404

            #on cherche d'abord le dernier refuge d'arrivée
            cur.execute("""
                SELECT idrefugearrivee
                FROM accueille
                WHERE numid = %s
                ORDER BY datearrivee DESC
                LIMIT 1
            """, (numId,))
            row = cur.fetchone()

            if row:
                refuge_actuel_id = row.idrefugearrivee
            else:
                #refuge d'origine dans confie si pas de transfert
                cur.execute("""
                    SELECT idrefuge
                    FROM confie
                    WHERE numid = %s
                """, (numId,))
                row2 = cur.fetchone()
                if row2 is None:
                    return "Refuge actuel introuvable", 400
                refuge_actuel_id = row2.idrefuge

            cur.execute("""
                SELECT idrefuge, nom, ville
                FROM refuge
                WHERE idrefuge = %s
            """, (refuge_actuel_id,))
            refuge_actuel = cur.fetchone()

            if request.method == "GET":
                cur.execute("""
                    SELECT idrefuge, nom, ville
                    FROM refuge
                    WHERE idrefuge <> %s
                    ORDER BY ville, nom
                """, (refuge_actuel_id,))
                refuges_dest = cur.fetchall()

                return render_template(
                    "transfert.html",
                    animal=animal,
                    refuge_actuel=refuge_actuel,
                    refuges_dest=refuges_dest
                )

            idRefugeArrivee = request.form.get("idRefugeArrivee")
            dateDepart = request.form.get("dateDepart")
            dateArrivee = request.form.get("dateArrivee")

            if not idRefugeArrivee or not dateDepart or not dateArrivee:
                return redirect(url_for("transfert", numId=numId))

            cur.execute("""
                INSERT INTO accueille(idrefugeorigine, idrefugearrivee, numid, datedepart, datearrivee)
                VALUES (%s, %s, %s, %s, %s)
            """, (refuge_actuel_id, idRefugeArrivee, numId, dateDepart, dateArrivee))

    return redirect(url_for("historique_animal", numId=numId))


@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "GET":
        return render_template("login.html")

    login = request.form.get("login", "")
    mdp = request.form.get("mdp", "")

    with connect() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT matricule, nom, prenom, mdp
                FROM employe
                WHERE login = %s
            """, (login,))
            emp = cur.fetchone()

    if emp is None or emp.mdp != mdp:
        return render_template("login.html", erreur="Login ou mot de passe incorrect")

    session["matricule"] = emp.matricule
    session["nom"] = emp.nom
    session["prenom"] = emp.prenom

    return redirect(url_for("espace_prive"))


@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("accueil"))


def login_required(f):
    def wrapper(*args, **kwargs):
        if "matricule" not in session:
            return redirect(url_for("login"))
        return f(*args, **kwargs)
    wrapper.__name__ = f.__name__
    return wrapper


# partie privée

@app.route("/espace_prive")
@login_required
def espace_prive():
    mat = session["matricule"]
    with connect() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT r.idrefuge, r.nom, r.ville
                FROM refuge r
                JOIN occupe o ON o.idrefuge = r.idrefuge
                WHERE o.matricule = %s
                ORDER BY r.nom
            """, (mat,))
            refuges = cur.fetchall()
    return render_template("espace_prive.html", refuges=refuges)


@app.route("/refuges/<idRefuge>/employes")
@login_required
def refuge_employes(idRefuge):
    with connect() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT e.matricule, e.nom, e.prenom, f.nomfonction
                FROM employe e
                JOIN occupe o ON o.matricule = e.matricule
                JOIN fonction f ON f.idfonction = o.idfonction
                WHERE o.idrefuge = %s
                ORDER BY e.nom, e.prenom
            """, (idRefuge,))
            employes = cur.fetchall()

            cur.execute("""
                SELECT e.nom, e.prenom
                FROM refuge r
                JOIN employe e ON e.matricule = r.gerant
                WHERE r.idrefuge = %s
            """, (idRefuge,))
            gerant = cur.fetchone()

    return render_template("refuge_employes.html",
                           employes=employes,
                           gerant=gerant)


@app.route("/animal/<numId>/historique")
@login_required
def historique_animal(numId):
    with connect() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT numid, nom, espece
                FROM animal
                WHERE numid = %s
            """, (numId,))
            animal = cur.fetchone()
            if animal is None:
                return "Animal introuvable", 404

            cur.execute("""
                SELECT sr.datesoin, s.nomsoin,
                       e.nom AS nom_employe, e.prenom AS prenom_employe
                FROM soinsrecus sr
                JOIN soin s ON s.idsoin = sr.idsoin
                JOIN employe e ON e.matricule = sr.soignant
                WHERE sr.numid = %s
                ORDER BY sr.datesoin DESC
            """, (numId,))
            soins = cur.fetchall()

            cur.execute("""
                SELECT a.idrefugeorigine, a.idrefugearrivee,
                       a.datedepart, a.datearrivee
                FROM accueille a
                WHERE a.numid = %s
                ORDER BY a.datedepart DESC
            """, (numId,))
            transferts = cur.fetchall()

    return render_template("historique_animal.html",
                           animal=animal,
                           soins=soins,
                           transferts=transferts)


@app.route("/animal/<numId>/ajout_soin", methods=["GET", "POST"])
@login_required
def ajout_soin(numId):
    if request.method == "GET":
        with connect() as conn:
            with conn.cursor() as cur:
                cur.execute("""
                    SELECT idsoin, nomsoin
                    FROM soin
                    ORDER BY nomsoin
                """)
                soins = cur.fetchall()
        return render_template("ajout_soin.html", numId=numId, soins=soins)

    idsoin = request.form.get("idsoin")
    soignant = session["matricule"]
    new_id = "SR" + str(random.randint(1000, 9999))

    with connect() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                INSERT INTO soinsrecus(idsoinsrecus, datesoin, soignant, idsoin, numid)
                VALUES (%s, CURRENT_DATE, %s, %s, %s)
            """, (new_id, soignant, idsoin, numId))

    return redirect(url_for("historique_animal", numId=numId))


@app.route("/vaccins")
@login_required
def vaccins():
    mat = session["matricule"]

    with connect() as conn:
        with conn.cursor() as cur:
            # refuges associés à l'employé
            cur.execute("""
                SELECT DISTINCT idrefuge
                FROM occupe
                WHERE matricule = %s
            """, (mat,))
            rows = cur.fetchall()
            refuges_emp = [r.idrefuge for r in rows]

            if not refuges_emp:
                return render_template("vaccins.html", a_vacciner=[])

            # animaux à vacciner (en retard) uniquement dans ces refuges
            cur.execute("""
                SELECT a.numid, a.nom, a.espece,
                       r.nom AS nom_refuge,
                       MAX(sr.datesoin) AS dernier_vaccin,
                       MAX(sr.datesoin) + s.perioderappel AS prochain_rappel
                FROM animal a
                JOIN soinsrecus sr ON sr.numid = a.numid
                JOIN soin s ON s.idsoin = sr.idsoin
                JOIN confie c ON c.numid = a.numid
                JOIN refuge r ON r.idrefuge = c.idrefuge
                WHERE s.nomsoin LIKE 'Vaccin%%'
                  AND s.perioderappel IS NOT NULL
                  AND c.idrefuge = ANY(%s)
                GROUP BY a.numid, a.nom, a.espece, r.nom, s.perioderappel
                HAVING MAX(sr.datesoin) + s.perioderappel <= CURRENT_DATE
                ORDER BY r.nom, a.espece, a.nom
            """, (refuges_emp,))
            a_vacciner = cur.fetchall()

    return render_template("vaccins.html", a_vacciner=a_vacciner)




if __name__ == "__main__":
    app.run(debug=True)
