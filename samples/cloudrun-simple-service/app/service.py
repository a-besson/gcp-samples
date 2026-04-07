from flask import Flask, jsonify
import os

app = Flask(__name__)


@app.route("/")
def hello():
    return jsonify(
        {
            "message": "Hello, World from Cloud Run Service!",
            "service": os.environ.get("K_SERVICE", "unknown"),
            "revision": os.environ.get("K_REVISION", "unknown"),
            "env": os.environ.get("ENV", "unknown"),
        }
    )


@app.route("/health")
def health():
    return jsonify({"status": "ok"}), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
