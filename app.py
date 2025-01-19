from flask import Flask, jsonify, request, render_template, redirect
import psycopg2

app = Flask(__name__)

# PostgreSQL konekcijski parametri
DB_CONFIG = {
    "dbname": "plant_tracker",
    "user": "postgres",
    "password": "Lkmagnum4848",
    "host": "localhost",
    "port": "5432"
}

# Povezivanje s bazom podataka
try:
    conn = psycopg2.connect(**DB_CONFIG)
    print("Uspješno povezano s bazom!")
except Exception as e:
    print("Greška pri povezivanju s bazom:", e)

# Ruta za prikaz svih biljaka
@app.route('/plants_view', methods=['GET'])
def plants_view():
    try:
        cur = conn.cursor()
        cur.execute("SELECT * FROM plants;")
        plants = cur.fetchall()
        cur.close()
        return render_template('plants.html', plants=plants)
    except Exception as e:
        print("Greška prilikom dohvaćanja biljaka:", e)
        return "Dogodila se greška prilikom dohvaćanja biljaka.", 500

# Ruta za dodavanje biljke
@app.route('/add_plant', methods=['GET', 'POST'])
def add_plant_view():
    if request.method == 'POST':
        try:
            name = request.form['name']
            species = request.form['species']
            planting_date = request.form['planting_date']
            description = request.form['description']

            cur = conn.cursor()
            cur.execute(
                "INSERT INTO plants (name, species, planting_date, description) VALUES (%s, %s, %s, %s);",
                (name, species, planting_date, description)
            )
            conn.commit()
            cur.close()
            return render_template('add_plant.html', message="Biljka je uspješno dodana!")
        except Exception as e:
            print("Greška prilikom dodavanja biljke:", e)
            return render_template('add_plant.html', message="Dogodila se greška.")
    return render_template('add_plant.html')

# Ruta za ažuriranje biljke
@app.route('/update_plant/<int:plant_id>', methods=['GET', 'POST'])
def update_plant_view(plant_id):
    if request.method == 'POST':
        try:
            name = request.form['name']
            species = request.form['species']
            planting_date = request.form['planting_date']
            description = request.form['description']

            cur = conn.cursor()
            cur.execute(
                "UPDATE plants SET name = %s, species = %s, planting_date = %s, description = %s WHERE id = %s;",
                (name, species, planting_date, description, plant_id)
            )
            conn.commit()
            cur.close()
            return redirect('/plants_view')
        except Exception as e:
            print("Greška prilikom ažuriranja biljke:", e)
            return "Dogodila se greška prilikom ažuriranja biljke.", 500

    cur = conn.cursor()
    cur.execute("SELECT * FROM plants WHERE id = %s;", (plant_id,))
    plant = cur.fetchone()
    cur.close()
    return render_template('update_plant.html', plant=plant)

@app.route('/reminders_view', methods=['GET'])
def reminders_view():
    try:
        cur = conn.cursor()
        cur.execute("""
            SELECT reminders.id, plants.name, reminders.reminder_date, reminders.message, reminders.is_done
            FROM reminders
            JOIN plants ON reminders.plant_id = plants.id
        """)
        reminders = cur.fetchall()
        cur.close()
        return render_template('reminders.html', reminders=reminders)
    except Exception as e:
        print("Greška prilikom dohvaćanja podsjetnika:", e)
        return "Dogodila se greška prilikom dohvaćanja podsjetnika.", 500

# Pokretanje aplikacije
if __name__ == '__main__':
    app.run(debug=True)
