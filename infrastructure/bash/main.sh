#!/bin/zsh

# Function to generate accounts
create_accounts() {
    echo "Generating accounts..."
    miners=$1
    clients=$2
    data_dir=$3  # Default data directory
    password_length=$4  # Default password length
    local bc_script="../middlewares/create_accounts.py"
    echo $miners
    # Remove existing data directory
    rm -rf "$data_dir"

    # Call geth to generate accounts
    echo "Miners: $miners, Clients: $clients, Data Directory: $data_dir, Password Length: $password_length"
    python3 $bc_script --miners $miners --clients $clients --data-dir $data_dir --password-length $password_length
    echo $data_dir
}


# Function to update genesis files
update_accounts_balance() {
    echo "Updating genesis files..."
    # genesis is the path to the directory containing the genesis file
    genesis=$1 # Default genesis path
    balance=$2  # Default balance
    data_dir=$3  # Default data directory for geth clients
    consensus="poa"
    local update_accounts_balance_script="../middlewares/update_accounts_balance.py"

    # Ensure datadir is defined if not provided as an argument
    if [[ -z "$data_dir" ]]; then
        echo "Error: a datadir for geth client should be provided"
        exit 1
    fi
    src="${genesis}/genesis_poa.json"
    dst="${data_dir}/genesis_poa.json"
    # Call the update_genesis function from bc python script
    python3 $update_accounts_balance_script --src $src --dst $dst --consensus $consensus --balance $balance --data-dir $data_dir
    if [[ $? -ne 0 ]]; then  # Check for errors
    echo "Error updating genesis file for consensus: $consensus"
    exit 1
    fi

}

# Function to build Docker images
build_images() {
  # Pull the base image at the beginning of the process
  #docker pull ethereum/client-go:v1.10.16
  
  bcNode_dockerfile="../Dockerfile.bcNode"
  # Build Docker image for geth node
  docker build -f "$bcNode_dockerfile" -t "bc-node" ".."
}

# create a docker network
create_docker_network() {
    network_name=$1
    driver=$2
    subnet=$3

    docker network create \
        --driver=$driver \
        --subnet=$subnet \
        $network_name
}

## launch docker container , the ones establishing the BC network
start_bc_containers(){
    local miners=$1  # Accept MINERS as an argument
    local networkid=$2  # Accept NETWORK_ID as an argument
    local blockchain_yml="../bc.yml"  # full path to bc.yml
    NETWORK_ID=$networkid MINERS=$miners docker compose -f $blockchain_yml -p one up  --remove-orphans 
    ##--build
}


# Function to connect peers
connect_peers() {
    echo "Connecting peers..."
    local network=$1
    local connect_peers_script="../middlewares/connect_peers.py"
    python3 $connect_peers_script --network $network

}


declare -A function_params



echo "Starting script..."



# Declare the associative array
typeset -A function_params

# Populate the array with predefined parameters
function_params[create_accounts]="4 4 ../blockchain/datadir 15"
function_params[update_accounts_balance]="../blockchain 1000000000000000000000 ../blockchain/datadir"
function_params[create_docker_network]="BCFL bridge 172.16.240.0/20"
function_params[build_bc_node_image]=""
function_params[start_bc_containers]="4 4444"
function_params[connect_peers]="de6a9dd05c56" #your docker network id 

# Debug: Print all keys and values
for key in ${(k)function_params}; do
    echo "Key: $key, Value: ${function_params[$key]}"
done



# Main logic to dispatch functions based on command-line arguments
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <function_name>"
    exit 1
fi

# Get the function name from the first argument
function_name=$1

case "$function_name" in
    create_accounts)
        # Use `eval` to split the string into separate arguments
        eval create_accounts ${function_params[$function_name]}
        ;;
    update_accounts_balance)
        eval update_accounts_balance ${function_params[$function_name]}
        ;;
    build_images)
        eval build_images ${function_params[$function_name]}
        ;;
    create_docker_network)
        eval create_docker_network ${function_params[$function_name]}
        ;;
    build_bc_node_image)
        eval build_bc_node_image ${function_params[$function_name]}
        ;;
    start_bc_containers)
        eval start_bc_containers ${function_params[$function_name]}
        ;;
    connect_peers)
        eval connect_peers ${function_params[$function_name]}
        ;;
    *)
        echo "Function '$function_name' not found."
        ;;
esac
