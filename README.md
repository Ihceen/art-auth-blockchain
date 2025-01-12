# Blockchain-Based Art Authentication Platform

This project demonstrates a simple blockchain-based platform for authenticating art pieces. The platform leverages blockchain technology to ensure the provenance and authenticity of art.

## Setup and Configuration

Follow the steps below to configure and deploy the platform:

### Step 1: Infrastructure Configuration

1. **Navigate to the Infrastructure Directory**
   
   Change your working directory to the `infrastructure` folder.

2. **Install Required Python Library**

   Install the `eth_account` library for Python:

   ```shell
   pip install eth_account
   ```

3. **Create System Services Network**

   Execute the following command to create a Docker network named `BCFL` with a bridge type and an IP address range of `172.16.240.0/20`:

   ```shell
   ./main.sh create_docker_network
   ```

4. **Update Network Configuration**

   Modify the parameter `function_params[connect_peers]` in the configuration file to include your `BCFL` network ID.

5. **Initialize Blockchain Accounts and Network**

   - Create accounts necessary for the blockchain network:

     ```bash
     ./main.sh create_accounts
     ```

   - Update the balance of each account:

     ```bash
     ./main.sh update_accounts_balance
     ```

   - Build a custom Docker image for the blockchain node:

     ```bash
     ./main.sh build_bc_node_image
     ```

   - Start the blockchain containers with 4 validators and a chain ID specified in the genesis file (e.g., `4444`):

     ```bash
     ./main.sh start_bc_containers
     ```

   - Connect peers using the previously created network ID:

     ```bash
     ./main.sh connect_peers
     ```

6. **Extract Miner’s Key and Password**

   - Retrieve one of the miner’s key files located in `infrastructure/datadir/keystore` and its corresponding password from `infrastructure/datadir/accounts.json` (in the `miners` section).

   - Decrypt the key file by running the following command in the `geth-decrypt-key` directory (clone this repo : "https://github.com/bsdelf/geth-decrypt-key.git"):

     ```shell
     ./geth-decrypt-key -key /path/to/keystore/file -password <password>
     ```

7. **Update Environment Variables**

   Copy the private key into the `.env` file and add the following details:

   ```plaintext
   PRIVATE_KEY=0x...
   RPC_URL=http://127.0.0.1:8545
   ```

### Step 2: Deploy the Smart Contract

Deploy the contract to the custom blockchain network:

```bash
npx hardhat run scripts/deploy.js --network customNetwork

