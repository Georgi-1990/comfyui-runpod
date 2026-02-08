Run the latest ComfyUI on RunPod with CUDA acceleration.
On first start, ComfyUI and optional custom nodes are installed into the persistent /workspace volume.
Subsequent starts are fast and reuse the existing installation.

When you see the following message in logs, ComfyUI is ready:
[ComfyUI-Manager] All startup tasks have been completed.


## Access

| Service        | Port   | Notes                                                      |
| -------------- | ------ | ---------------------------------------------------------- |
| ComfyUI Web UI | `8188` | Main interface                                             |
| FileBrowser    | `8080` | Manage files in `/workspace`                               |
| JupyterLab     | `8888` | Root directory: `/workspace`                               |
| SSH            | `22`   | Use `PUBLIC_KEY` or check logs for generated root password |


## Environment Variables
These variables control the behavior of the template:

| Variable           | Default   | Description                                     |
| ------------------ | --------- | ----------------------------------------------- |
| `COMFY_UPDATE`     | `false`   | Update ComfyUI and custom nodes on startup      |
| `CUSTOM_NODES`     | *(empty)* | Comma-separated list of custom nodes to install |
| `JUPYTER_PASSWORD` | *(empty)* | Token for JupyterLab                            |
| `PUBLIC_KEY`       | *(empty)* | SSH public key for root login                   |


## Example
COMFY_UPDATE=true
CUSTOM_NODES=manager,impact-pack,controlnet


## Supported Custom Nodes
The following node keys are supported out of the box:

| Key           | Repository                        |
| ------------- | --------------------------------- |
| `manager`     | ltdrdata/ComfyUI-Manager          |
| `impact-pack` | ltdrdata/ComfyUI-Impact-Pack      |
| `controlnet`  | Fannovel16/comfyui_controlnet_aux |

Custom nodes are installed into:
/workspace/ComfyUI/custom_nodes

## Custom ComfyUI Arguments
You can pass additional arguments to ComfyUI via:
/workspace/comfyui_args.txt

One argument per line, for example:
--max-batch-size 8
--preview-method auto

These arguments are automatically appended on startup.

## Directory Structure
/workspace
├── ComfyUI/
│   ├── main.py
│   ├── custom_nodes/
│   └── models/
├── comfyui_args.txt
└── logs/

All data in /workspace is persistent across pod restarts.

## CUDA & PyTorch
* CUDA version is defined at build time (CUDA_VERSION)
* PyTorch is installed with a compatible CUDA build
* GPU availability and versions are logged on startup

Check logs for:

Torch version
CUDA available
CUDA runtime
GPU name

## Source Code
This template is open source.
Repository: (replace with your repo URL)

## Notes
* First startup may take several minutes due to dependency installation
* Updating ComfyUI on every start is optional and controlled via COMFY_UPDATE
* Designed for RunPod Pods (not Serverless)
