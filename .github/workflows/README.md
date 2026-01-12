# Workflows

## ROS 2 VxWorks Docker Build

This repository contains a `GitHub Actions` workflow to build Docker containers for ROS 2 on VxWorks. The workflow dynamically resolves the required Ubuntu base version from a configuration file.

### Configuration

The mapping between ROS 2 distributions and Ubuntu versions is maintained in `.github/workflows/ros2.json`:

```json
{
  "humble": { "ubuntu": "22.04" },
  "jazzy":  { "ubuntu": "24.04" }
}
```
### Running the Workflow

1. On `GitHub`

- Navigate to the Actions tab.
- Select the Docker build workflow.
- Click Run workflow, choose the branch, and select the desired `ros_distro` (e.g., `humble` or `jazzy`).

2. Locally using `act`

To run the build locally, ensure you have `act` and the GitHub CLI installed.
Run the following command from the repository root:

```bash
$ act workflow_dispatch \
    -W .github/workflows/docker-build.yaml \
    -P ubuntu-24.04=ghcr.io/catthehacker/ubuntu:act-24.04 \
    -s GITHUB_TOKEN="$(gh auth token)" \
    --input ros_distro=jazzy \
    --artifact-server-path /tmp/artifacts
```

### Output

Upon successful completion, the workflow generates a compressed Docker image: `vxros2build.<ros_distro>.tar.gz`

To load this image into local Docker engine use:

```bash
$ docker load -i vxros2build.<ros_distro>.tar.gz
```

