from flask import Flask

admin_app = Flask(__name__)

@admin_app.route('/flag')
def admin_flag():
    return "flag{ssrf_in_redirect}"

if __name__ == '__main__':
    admin_app.run(host='0.0.0.0', port=80, debug=True)




