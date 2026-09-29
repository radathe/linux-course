from flask import Flask

app = Flask(__name__)


@app.route("/")
def index():
    return "flag{docker_complete}\n"


if __name__ == "__main__":
    # Слушаем 0.0.0.0, чтобы приложение было доступно извне контейнера.
    app.run(host="0.0.0.0", port=5000)
