<<<<<<< HEAD
# syntax=docker.io/docker/dockerfile:1

# build stage: includes resources necessary for installing dependencies

# Here the image's platform does not necessarily have to be riscv64.
# If any needed dependencies rely on native binaries, you must use 
# a riscv64 image such as cartesi/node:20-jammy for the build stage,
# to ensure that the appropriate binaries will be generated.
FROM node:20.16.0-bookworm AS build-stage

WORKDIR /opt/cartesi/dapp
COPY . .
RUN yarn install && yarn build

# runtime stage: produces final image that will be executed

# Here the image's platform MUST be linux/riscv64.
# Give preference to small base images, which lead to better start-up
# performance when loading the Cartesi Machine.
FROM --platform=linux/riscv64 cartesi/node:20.16.0-jammy-slim

ARG MACHINE_EMULATOR_TOOLS_VERSION=0.14.1
ADD https://github.com/cartesi/machine-emulator-tools/releases/download/v${MACHINE_EMULATOR_TOOLS_VERSION}/machine-emulator-tools-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb /
RUN dpkg -i /machine-emulator-tools-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb \
  && rm /machine-emulator-tools-v${MACHINE_EMULATOR_TOOLS_VERSION}.deb
=======
# syntax=docker/dockerfile:1.4
FROM --platform=linux/riscv64 cartesi/python:3.10-slim-jammy

# Simplified - Directly copying the file
COPY machine-emulator-tools-v0.14.1.deb /tmp/
RUN dpkg -i /tmp/machine-emulator-tools-v0.14.1.deb && rm /tmp/machine-emulator-tools-v0.14.1.deb
>>>>>>> 7556e5fede24b82745c3f448837d97fb0d394f7e

LABEL io.cartesi.rollups.sdk_version=0.9.0
LABEL io.cartesi.rollups.ram_size=128Mi

ARG DEBIAN_FRONTEND=noninteractive
<<<<<<< HEAD
RUN <<EOF
set -e
apt-get update
apt-get install -y --no-install-recommends \
  busybox-static=1:1.30.1-7ubuntu3
rm -rf /var/lib/apt/lists/* /var/log/* /var/cache/*
useradd --create-home --user-group dapp
EOF
=======
RUN apt-get update && apt-get install -y --no-install-recommends \
    busybox-static=1:1.30.1-7ubuntu3 && \
    rm -rf /var/lib/apt/lists/* /var/log/* /var/cache/* && \
    useradd --create-home --user-group dapp
>>>>>>> 7556e5fede24b82745c3f448837d97fb0d394f7e

ENV PATH="/opt/cartesi/bin:${PATH}"

WORKDIR /opt/cartesi/dapp
<<<<<<< HEAD
COPY --from=build-stage /opt/cartesi/dapp/dist .
=======
COPY ./requirements.txt .

RUN pip install -r requirements.txt --no-cache && \
    find /usr/local/lib -type d -name __pycache__ -exec rm -r {} +

COPY ./dapp.py .
>>>>>>> 7556e5fede24b82745c3f448837d97fb0d394f7e

ENV ROLLUP_HTTP_SERVER_URL="http://127.0.0.1:5004"

ENTRYPOINT ["rollup-init"]
<<<<<<< HEAD
CMD ["node", "index.js"]
=======
CMD ["python3", "dapp.py"]
>>>>>>> 7556e5fede24b82745c3f448837d97fb0d394f7e
