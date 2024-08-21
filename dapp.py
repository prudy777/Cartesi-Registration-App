import os
import logging
import requests
from eth_utils import to_hex, to_bytes

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

rollup_server = os.environ["ROLLUP_HTTP_SERVER_URL"]
logger.info(f"HTTP rollup_server url is {rollup_server}")

users = []
to_upper_total = 0


def hex2str(hex_data):
    return bytes.fromhex(hex_data[2:]).decode('utf-8')


def str2hex(payload):
    return "0x" + payload.encode('utf-8').hex()


def is_numeric(num):
    try:
        float(num)
        return True
    except ValueError:
        return False


def handle_advance(data):
    global to_upper_total
    logger.info(f"Received advance request data {data}")

    metadata = data["metadata"]
    sender = metadata["msg_sender"]
    payload = data["payload"]

    sentence = hex2str(payload)
    if is_numeric(sentence):
        report_req = requests.post(rollup_server + "/report", json={"payload": str2hex("sentence is not on hex format")})
        return "reject"

    users.append(sender)
    to_upper_total += 1

    sentence = sentence.upper()
    notice_req = requests.post(rollup_server + "/notice", json={"payload": str2hex(sentence)})

    return "accept"


def handle_inspect(data):
    logger.info(f"Received inspect request data {data}")

    payload = data["payload"]
    route = hex2str(payload)

    if route == "list":
        response_object = {"users": users}
    elif route == "total":
        response_object = {"toUpperTotal": to_upper_total}
    else:
        response_object = "route not implemented"

    report_req = requests.post(rollup_server + "/report", json={"payload": str2hex(str(response_object))})

    return "accept"


handlers = {
    "advance_state": handle_advance,
    "inspect_state": handle_inspect,
}

finish = {"status": "accept"}

while True:
    logger.info("Sending finish")
    response = requests.post(rollup_server + "/finish", json=finish)
    logger.info(f"Received finish status {response.status_code}")

    if response.status_code == 202:
        logger.info("No pending rollup request, trying again")
    else:
        rollup_request = response.json()
        handler = handlers[rollup_request["request_type"]]
        finish["status"] = handler(rollup_request["data"])
