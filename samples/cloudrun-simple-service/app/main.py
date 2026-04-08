import os
from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/")
def hello_world():
    return jsonify({
        "status": "healthy",
        "message": "Hello from Cloud Run on Port 443!",
        "authenticated": True,
        "protocol": "HTTPS (via GFE)"
    })

@app.route("/api/ping")
def ping():
    return jsonify({"response": "pong"})

if __name__ == "__main__":
    # Cloud Run passes the port as an environment variable.
    # We default to 443 as requested.
    port = int(os.environ.get("PORT", 443))
    app.run(host="0.0.0.0", port=port)
