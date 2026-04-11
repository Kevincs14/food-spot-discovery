import sys
from flask import Flask, render_template, request, redirect, url_for
import mysql.connector

app = Flask(__name__)

DB_CONFIG = {
    "host": "localhost",
    "database": "food_reviews",
    "user": "food_app",
    "password": "password123",
}

def get_db_connection():
    try:
        return mysql.connector.connect(**DB_CONFIG)
    except mysql.connector.errors.DatabaseError as e:
        raise RuntimeError(
            f"Could not connect to MySQL at {DB_CONFIG['host']}:3306 — "
            "is the server running? (try: sudo systemctl start mysql)"
        ) from e

def check_db():
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        conn.close()
    except mysql.connector.errors.DatabaseError as e:
        print(f"\n[ERROR] Cannot connect to MySQL: {e}")
        print(f"        Make sure MySQL is running: sudo systemctl start mysql\n")
        sys.exit(1)

@app.route('/', methods=['GET', 'POST'])
def index():
    results = []
    search_query = ""

    if request.method == 'POST':
        search_query = request.form.get('search', '')
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            "SELECT spotID, name, address, picture FROM FoodSpot WHERE name LIKE %s",
            ('%' + search_query + '%',)
        )
        results = cur.fetchall()
        cur.close()
        conn.close()

    return render_template('index.html', results=results, search_query=search_query)

@app.route('/spots')
def spots():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        SELECT f.spotID, f.name, f.address, f.picture,
               ROUND(AVG(r.rating), 1) AS avg_rating,
               COUNT(r.reviewID) AS review_count
        FROM FoodSpot f
        LEFT JOIN Review r ON f.spotID = r.spotID
        GROUP BY f.spotID, f.name, f.address, f.picture
        ORDER BY avg_rating DESC
    """)
    spots = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('spots.html', spots=spots)

@app.route('/spot/<int:spot_id>')
def spot_detail(spot_id):
    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("SELECT spotID, name, address, picture FROM FoodSpot WHERE spotID = %s", (spot_id,))
    spot = cur.fetchone()

    cur.execute("""
        SELECT r.rating, r.comment, r.reviewDate, u.username
        FROM Review r
        JOIN User u ON r.userID = u.userID
        WHERE r.spotID = %s
        ORDER BY r.reviewDate DESC
    """, (spot_id,))
    reviews = cur.fetchall()

    cur.close()
    conn.close()

    if spot is None:
        return "Spot not found", 404
    return render_template('spot.html', spot=spot, reviews=reviews)

@app.route('/register', methods=['GET', 'POST'])
def register():
    error = None
    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        email = request.form.get('email', '').strip()
        password = request.form.get('password', '')
        if not username or not email or not password:
            error = "All fields are required."
        else:
            conn = get_db_connection()
            cur = conn.cursor()
            try:
                cur.execute(
                    "INSERT INTO User (username, email, PasswordHash) VALUES (%s, %s, %s)",
                    (username, email, password)
                )
                conn.commit()
                cur.close()
                conn.close()
                return redirect(url_for('index'))
            except mysql.connector.IntegrityError:
                error = "Username or email already taken."
            finally:
                cur.close()
                conn.close()
    return render_template('register.html', error=error)

if __name__ == '__main__':
    check_db()
    app.run(debug=True)
