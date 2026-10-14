# GNExT Shiny App

The **GNExT Shiny App** provides a graphical user interface for configuring and launching the [GNExT Nextflow preprocessing pipeline](https://github.com/DyHealthNet/gnext_nf_pipeline) and preparing the [GNExT web platform](https://github.com/DyHealthNet/gnext_platform) for deployment.

The application simplifies the configuration of GWAS preprocessing and platform deployment by providing a unified interface for managing input files, computational parameters, and execution settings.

## Quick Start

### 1. Pull and run the GNExT Shiny App

Download the Docker image:

```bash
docker pull gnext_config_interface
```

Start the Shiny application:

```bash
docker run -d \
  --name gnext-shiny \
  -p 3838:3838 \
  <required-volume-mounts> \
  gnext_config_interface
```

**Note:** The Docker container must have access to the required input/output directories, the GNExT repositories, and the SLURM environment used to submit Nextflow jobs. Configure the appropriate volume mounts and permissions for your system.

### 2. Access the Shiny App via SSH port forwarding

If the application is running on a remote server or HPC cluster, create an SSH tunnel from your local computer:

```bash
ssh -N -L 3838:localhost:3838 username@server
```

Then open the following address in your browser:

**http://localhost:3838**

Keep the SSH connection active while using the application.

### 3. Configure the GNExT Nextflow pipeline

In the **GNExT nf pipeline** tab:

1. Specify the required input and output paths.
2. Load or create the phenotype metadata table.
3. Configure study-specific parameters.
4. Set computational resources and SLURM parameters.
5. Generate the Nextflow configuration files and launch the pipeline.

The preprocessing workflow is submitted to SLURM and generates the files required by the GNExT web platform.

### 4. Configure and launch the GNExT platform

After successful completion of the preprocessing pipeline:

1. Open the **GNExT platform** tab.
2. Specify the GNExT platform repository and deployment directories.
3. Configure the platform environment variables.
4. Point the platform to the generated phenotype metadata and Nextflow results (JOB_DIR/nf_output/).
5. Generate the `.env` file and Docker launch script.
6. Execute the generated launch script to start the GNExT web platform.


### 5. Access the GNExT web platform

If the frontend is running on a remote server, create an SSH tunnel to the frontend port:

```bash
ssh -N -L 8080:localhost:<frontend-port> username@server
```

Replace `<frontend-port>` with the actual port exposed by the GNExT frontend.

Then open:

**http://localhost:8080**

## Requirements

- Docker and Docker Compose
- Access to a SLURM-enabled computational environment
- Nextflow and Java available in the execution environment
- GNExT Nextflow pipeline and GNExT platform repositories
- Appropriate filesystem permissions and access to GWAS input data

## Documentation

For additional information, see:

- [GNExT Nextflow Pipeline](https://github.com/DyHealthNet/gnext_nf_pipeline)
- [GNExT Web Platform](https://github.com/DyHealthNet/gnext_platform)

