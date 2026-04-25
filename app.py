import sys
from flask import Flask, render_template, request, redirect, url_for, session
import mysql.connector

app = Flask(__name__)
app.secret_key = 'food_spot_secret_key'

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
    cur.execute("SELECT * FROM RestaurantLeaderboard ORDER BY avg_rating DESC") ## CHANGE #2
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

@app.route('/login', methods=['GET', 'POST'])
def login():
    error = None
    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        password = request.form.get('password', '')
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT userID, username, PasswordHash FROM User WHERE username = %s", (username,))
        user = cur.fetchone()
        cur.close()
        conn.close()
        if user and user[2] == password:
            session['user_id'] = user[0]
            session['username'] = user[1]
            return redirect(url_for('index'))
        error = "Invalid username or password."
    return render_template('login.html', error=error)

@app.route('/logout', methods=['POST'])
def logout():
    session.clear()
    return redirect(url_for('index'))

@app.route('/profile')
def profile():
    if 'user_id' not in session:
        return redirect(url_for('login'))
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT avgRatingGiven, totalReviews, username FROM userSummary WHERE userID = %s", (session['user_id'],))
    stats = cur.fetchone()
    cur.close()
    conn.close()
    return render_template('profile.html', stats=stats)

@app.route('/add_review', methods=['POST'])
def add_review():
    if 'user_id' not in session:
        return redirect(url_for('login'))
    spot_id = request.form.get('spot_id', type=int)
    rating = request.form.get('rating', type=int)
    comment = request.form.get('comment', '').strip()
    if not spot_id or not rating:
        return redirect(url_for('spot_detail', spot_id=spot_id))
    conn = get_db_connection()
    cur = conn.cursor()
    cur.callproc('addReview', (rating, comment, session['user_id'], spot_id))
    conn.commit()
    cur.close()
    conn.close()
    return redirect(url_for('spot_detail', spot_id=spot_id))

if __name__ == '__main__':
    check_db()
    app.run(debug=True)
