from flask import Flask, render_template, request
import psycopg2

app = Flask(__name__)

def get_db_connection():
    return psycopg2.connect(
        host="localhost",
        database="food_reviews", # Make sure this matches your DB name in pgAdmin
        user="postgres",
        password="yourpassword" 
    )

@app.route('/', methods=['GET', 'POST'])
def index():
    results = []
    search_query = ""
    
    if request.method == 'POST':
        search_query = request.form.get('search')
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Updated query to match your new schema
        # We fetch name, address, and the picture filename
        sql = "SELECT name, address, picture FROM FoodSpot WHERE name ILIKE %s"
        cur.execute(sql, ('%' + search_query + '%',))
        
        results = cur.fetchall()
        cur.close()
        conn.close()
        
    return render_template('index.html', results=results, search_query=search_query)

if __name__ == '__main__':
    app.run(debug=True)