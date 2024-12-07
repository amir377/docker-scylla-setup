# Docker ScyllaDB Setup

This repository provides an automated solution for deploying ScyllaDB inside a Docker container. It includes user-friendly scripts (`install.ps1` for Windows and `install.sh` for Linux/Mac) to simplify the setup process with customizable parameters.

## Features

1. **Environment File Generation**: Automatically generates a `.env` file with user-defined parameters such as container name, network name, ports, and credentials.
2. **Docker Network Management**: Creates a Docker network if it doesn’t already exist.
3. **Docker Compose Configuration**: Dynamically generates a `docker-compose.yaml` file from a `docker-compose.example.yaml` template.
4. **Build and Run**: Executes `docker-compose up -d --build` to build and start the ScyllaDB container.
5. **Container Status Check**: Checks the container status post-deployment.
6. **Error Handling**: Displays logs if the container fails to start.
7. **Interactive Access**: Connects to the container shell if it starts successfully.

## Prerequisites

- **Docker** must be installed and running on your system.
- **Docker Compose** must be installed.
- **Linux Only**: Ensure `dos2unix` is installed to handle line ending conversions if needed.
  ```bash
  sudo apt install dos2unix
  ```
- **Git** must be installed and available in your system’s PATH.
  ```bash
  sudo apt install git       # For Debian/Ubuntu
  sudo yum install git       # For CentOS/RHEL
  brew install git           # For macOS
  ```
- **Windows Users**: Run PowerShell as Administrator.

## Installation Steps

### One Command Install and Clone

#### Windows

Open PowerShell as Administrator and run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; git clone https://github.com/amir377/docker-scylla-setup; cd docker-scylla-setup; ./install.ps1
```

#### Linux/Mac

Run the following command in your terminal:

```bash
git clone https://github.com/amir377/docker-scylla-setup && cd docker-scylla-setup && dos2unix install.sh && chmod +x install.sh && ./install.sh
```

## Manual Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/amir377/docker-scylla-setup.git
   cd docker-scylla-setup
   ```

2. Ensure `docker-compose.example.yaml` is in the root directory (if not already provided).

3. Run the appropriate installation script:
    - **Windows**: `install.ps1`
    - **Linux/Mac**: `install.sh`

4. Follow the prompts to customize your setup:
    - Container name
    - Network name
    - Ports
    - Credentials

## File Descriptions

### `install.ps1`
Automates the setup process for Windows, including:

- Generating `.env` and `docker-compose.yaml` files.
- Checking for Docker and Docker Compose installations.
- Creating a Docker network.
- Building and starting the ScyllaDB container.
- Displaying logs or connecting to the container shell if necessary.

### `install.sh`
Automates the setup process for Linux/Mac, including:

- Generating `.env` and `docker-compose.yaml` files.
- Checking for Docker and Docker Compose installations.
- Creating a Docker network.
- Building and starting the ScyllaDB container.
- Displaying logs or connecting to the container shell if necessary.

### `.env`
Holds configuration values for the ScyllaDB container. Example:

```env
# ScyllaDB container settings
CONTAINER_NAME=scylla
NETWORK_NAME=general
SCYLLA_CQL_PORT=9042
SCYLLA_REST_PORT=9180
ALLOW_HOST=0.0.0.0

# ScyllaDB credentials
SCYLLA_USER=admin
SCYLLA_PASSWORD=admin
```

### `docker-compose.example.yaml`
Template file for the `docker-compose.yaml`. Placeholders are dynamically replaced with values from the `.env` file.

### `docker-compose.yaml`
Generated file used to deploy the ScyllaDB container with Docker Compose.

## Usage

### Accessing ScyllaDB

- **CQL Port**: The `SCYLLA_CQL_PORT` value specified during setup (default: `9042`)
- **REST Port**: The `SCYLLA_REST_PORT` value specified during setup (default: `9180`)
- **Username**: The `SCYLLA_USER` value specified during setup
- **Password**: The `SCYLLA_PASSWORD` value specified during setup

### Viewing Logs

If the container fails to start, the script will display logs automatically:

```bash
docker logs <container-name>
```

### Accessing the Container Shell

If the container starts successfully, the script will connect to the container shell automatically:

```bash
docker exec -it <container-name> bash
```

## Notes

- Ensure Docker is running before executing the script.
- If you encounter permission issues, run PowerShell or Bash as Administrator.
- Update the `docker-compose.example.yaml` file to suit your specific requirements.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

---

Feel free to customize the script or template files to fit your specific use case!

