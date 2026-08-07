import os

from flask import Flask, request, jsonify

flags = {}
PORT = int(os.environ.get('PORT', '10000'))
DOWN = False
app = Flask(__name__)


def _is_down():
    return DOWN


@app.route('/put/', methods=['POST'])
def put():
    if _is_down():
        return jsonify({'status': 'down'}), 503
    data = request.get_json(force=True)
    flag_id = data['id']
    vuln = data['vuln']
    flag = data['flag']
    flags[f'{vuln}:{flag_id}'] = flag
    return jsonify({'status': 'ok'})


@app.route('/get/', methods=['GET'])
def get():
    if _is_down():
        return jsonify({'status': 'down'}), 503
    flag_id = request.args['id']
    vuln = request.args['vuln']
    flag = flags[f'{vuln}:{flag_id}']
    return jsonify({'flag': flag})


@app.route('/ping/', methods=['GET'])
def ping():
    if _is_down():
        return jsonify({'status': 'down'}), 503
    return jsonify({'status': 'ok'})


@app.route('/down/', methods=['POST'])
def down():
    global DOWN
    DOWN = True
    return jsonify({'status': 'down', 'mode': 'down'})


@app.route('/up/', methods=['POST'])
def up():
    global DOWN
    DOWN = False
    return jsonify({'status': 'ok', 'mode': 'up'})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=PORT, debug=True)