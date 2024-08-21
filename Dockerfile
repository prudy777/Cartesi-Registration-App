# syntax=docker/dockerfile:1.4
FROM --platform=linux/riscv64 cartesi/python:3.10-slim-jammy

# Simplified - Directly copying the file
COPY machine-emulator-tools-v0.14.1.deb /tmp/
RUN dpkg -i /tmp/machine-emulator-tools-v0.14.1.deb && rm /tmp/machine-emulator-tools-v0.14.1.deb

LABEL io.cartesi.rollups.sdk_version=0.9.0
LABEL io.cartesi.rollups.ram_size=128Mi

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    busybox-static=1:1.30.1-7ubuntu3 && \
    rm -rf /var/lib/apt/lists/* /var/log/* /var/cache/* && \
    useradd --create-home --user-group dapp

ENV PATH="/opt/cartesi/bin:${PATH}"

WORKDIR /opt/cartesi/dapp
COPY ./requirements.txt .

RUN pip install -r requirements.txt --no-cache && \
    find /usr/local/lib -type d -name __pycache__ -exec rm -r {} +

COPY ./dapp.py .

ENV ROLLUP_HTTP_SERVER_URL="http://127.0.0.1:5004"

ENTRYPOINT ["rollup-init"]
CMD ["python3", "dapp.py"]
