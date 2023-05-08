from flask import Flask
app = Flask(__name__)

@app.route("/")
def index():
    return "This is the index!"

@app.route("/hello")
def hello():
    return "Hello world!"

@app.route("/udea")
def udea():
    return "Mensaje de prueba"