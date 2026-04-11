# Food Spot Discovery

A web app where users can find local food spots and leave reviews. Built with Python (Flask) and MySQL/MariaDB.

## Features

- **User Accounts** — register with a username, email, and password
- **Food Spot Discovery** — browse all spots with average ratings
- **Search** — find spots by name
- **Reviews** — rate spots 1–5 and leave comments

## Prerequisites

- Python 3.10+
- MySQL or MariaDB

---

## Setup — Linux

### 1. Install and start MariaDB

```bash
sudo pacman -S mariadb          # Arch/CachyOS
# or
sudo apt install mariadb-server # Ubuntu/Debian

sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
sudo systemctl start mariadb
sudo systemctl enable mariadb   # start on boot (optional)
```

### 2. Create the database user

```bash
sudo mariadb
```

```sql
CREATE USER 'food_app'@'localhost' IDENTIFIED BY 'your_password';
CREATE DATABASE IF NOT EXISTS food_reviews;
GRANT ALL PRIVILEGES ON food_reviews.* TO 'food_app'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 3. Load the schema

```bash
mariadb -u food_app -p food_reviews < schema/schema.sql
```

### 4. Install Python dependencies and run

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python app.py
```

---

## Setup — Windows

### 1. Install MariaDB

Download and run the installer from https://mariadb.org/download. During setup, set a root password when prompted.

### 2. Create the database user

Open the MariaDB command prompt from the Start menu and run:

```sql
CREATE USER 'food_app'@'localhost' IDENTIFIED BY 'your_password';
CREATE DATABASE IF NOT EXISTS food_reviews;
GRANT ALL PRIVILEGES ON food_reviews.* TO 'food_app'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 3. Load the schema

```cmd
mariadb -u food_app -p food_reviews < schema\schema.sql
```

### 4. Install Python dependencies and run

```cmd
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
python app.py
```

---

## Configuration

Update the `DB_CONFIG` block in `app.py` with your credentials:

```python
DB_CONFIG = {
    "host": "localhost",
    "database": "food_reviews",
    "user": "food_app",
    "password": "your_password",
}
```

Then open http://127.0.0.1:5000 in your browser.
