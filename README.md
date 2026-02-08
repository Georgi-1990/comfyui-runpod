# ComfyUI RunPod Template
Run the latest ComfyUI on RunPod with CUDA acceleration.

## Access

| Service        | Port   | Notes                                                      |
| -------------- | ------ | ---------------------------------------------------------- |
| ComfyUI Web UI | `8188` | Main interface                                             |
| FileBrowser    | `8080` | Manage files in `/workspace`                               |
| JupyterLab     | `8888` | Root directory: `/workspace`                               |
| SSH            | `22`   | Use `PUBLIC_KEY` or check logs for generated root password |


## Environment Variables
These variables control the behavior of the template:

Core Variables
| Variable           | Default   | Required | Description                          |
| ------------------ | --------- | -------- | ------------------------------------ |
| `PUBLIC_KEY`       | *(empty)* | No       | SSH public key for root access       |
| `JUPYTER_PASSWORD` | *(empty)* | No       | Token for JupyterLab access          |
| `COMFY_UPDATE`     | `true`    | No       | Update ComfyUI repository on startup |


## Custom Nodes

This template supports automatic installation of ComfyUI custom nodes 
via environment variables.

Example:
COMFY_UPDATE=true
CUSTOM_NODES=manager,impact-pack,controlnet

**Available Nodes**

| Alias          | Repository |
|---------------|------------|
| `manager`     | ComfyUI-Manager |
| `impact-pack` | ComfyUI-Impact-Pack |
| `controlnet`  | ComfyUI-ControlNet |
| `kjnodes`     | ComfyUI-KJNodes |
| `civicomfy`   | Civicomfy |


## COMFY_UPDATE
When `COMFY_UPDATE=true`:

- `git pull` is executed for the ComfyUI repository
- `git pull` is executed for all installed custom nodes
- Python dependencies are reinstalled if required

When `COMFY_UPDATE=false` (default):

- ComfyUI is cloned only once (on first start)
- Custom nodes are cloned only if missing
- No repository updates are performed

## CUDA / PyTorch Versioning
CUDA_VERSION=12.8
TORCH_VERSION=2.5.1
TORCH_CUDA=cu128


## Directory Structure
/workspace
├── ComfyUI/
│   ├── main.py
│   ├── custom_nodes/
│   └── models/
├── comfyui_args.txt
└── logs/


## Source Code
This template is open source.
Repository: (replace with your repo URL)

Notes
* First startup may take several minutes due to dependency installation
* Updating ComfyUI on every start is optional and controlled via COMFY_UPDATE
* Designed for RunPod Pods (not Serverless)
