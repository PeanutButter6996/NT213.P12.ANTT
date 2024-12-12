from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

@app.route('/fetch', methods=['GET'])
def fetch_url():
    url = request.args.get('url')
    if not url:
        return jsonify({"error": "URL parameter is missing"}), 400
    
    try:
        if url.startswith("http://localhost") or url.startswith("http://127.0.0.1") or url.startswith("http://admin_server"):
            return jsonify({"error": "Access to localhost is restricted"}), 403

        response = requests.get(url, timeout=5, allow_redirects=True)
        return jsonify({
            "status": response.status_code,
            "content": response.text
        })
    
    except requests.exceptions.RequestException as e:
        return jsonify({"error": str(e)}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)



