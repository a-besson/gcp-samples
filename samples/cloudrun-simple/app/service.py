from flask import Flask, jsonify
import os

app = Flask(__name__)


@app.route("/")
def hello():
    return jsonify(
        {
            "message": "Hello, World from Cloud Run!",
            "service": os.environ.get("K_SERVICE", "unknown"),
            "revision": os.environ.get("K_REVISION", "unknown"),
        }
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
