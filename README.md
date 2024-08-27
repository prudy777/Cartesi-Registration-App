# Cartesi dApp Backend

This repository contains a Cartesi dApp backend that handles user registration, retrieves user data, and interacts with Cartesi Rollups APIs. It is designed to run locally with no front-end components.

## Features

- Registers user data (name, phone number, email, and wallet address) and saves it to a MongoDB database.
- Fetches all registered users or individual users by phone number, email, or wallet address.
- Sends notices and reports using Cartesi Rollups APIs.

## Requirements

- Node.js
- MongoDB
- Cartesi Rollups Server (for interacting with the Rollups APIs)
- Latest Cartesi CLI (optional but recommended)

## Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/your-username/cartesi-dapp-backend.git
    cd cartesi-dapp-backend
    ```

2. Install dependencies:
    ```bash
    npm install
    ```

3. Create a `.env` file in the root directory and add the following:
    ```env
    PORT=3000
    MONGO_URI=your_mongodb_connection_string
    ROLLUP_HTTP_SERVER_URL=your_rollup_server_url
    ```

4. Start the MongoDB server locally or connect to a cloud MongoDB service.

5. Start the application:
    ```bash
    node index.js
    ```

6. The server will run on `http://localhost:3000`.

## API Endpoints

- **POST /api/register**: Registers a new user.
- **GET /api/users**: Fetches the list of all registered users.
- **GET /api/users/phone/:phoneNumber**: Fetches a user by phone number.
- **GET /api/users/email/:email**: Fetches a user by email.
- **GET /api/users/wallet/:walletAddress**: Fetches a user by wallet address.

## Running with Cartesi CLI

If using the Cartesi CLI to run locally, ensure that the `ROLLUP_HTTP_SERVER_URL` in your `.env` points to the correct Cartesi Rollups server URL.

## License

MIT
