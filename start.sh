#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================

WORKSPACE="/workspace"
COMFYUI_DIR="${WORKSPACE}/ComfyUI"
CUSTOM_NODES_DIR="${COMFYUI_DIR}/custom_nodes"
LOG_DIR="${WORKSPACE}/logs"

COMFY_REPO="https://github.com/comfyanonymous/ComfyUI.git"
COMFY_BRANCH="${COMFY_BRANCH:-master}"
COMFY_UPDATE="${COMFY_UPDATE:-false}"

# Default custom nodes if not provided
CUSTOM_NODES="${CUSTOM_NODES:-manager,kjnodes,civicomfy}"

mkdir -p "${LOG_DIR}"

# =============================================================================
# Logging helpers
# =============================================================================

log() {
  echo "[start.sh] $1"
}

# =============================================================================
# CUDA / Torch diagnostics (must-have for RunPod)
# =============================================================================

log "CUDA / PyTorch diagnostics:"
python3 - <<'EOF'
import torch
print("  Torch version:", torch.__version__)
print("  CUDA available:", torch.cuda.is_available())
print("  CUDA runtime:", torch.version.cuda)
if torch.cuda.is_available():
    print("  GPU:", torch.cuda.get_device_name(0))
EOF

# =============================================================================
# Clone or update ComfyUI
# =============================================================================

if [ ! -d "${COMFYUI_DIR}" ]; then
  log "Cloning ComfyUI..."
  git clone --branch "${COMFY_BRANCH}" "${COMFY_REPO}" "${COMFYUI_DIR}"
elif [ "${COMFY_UPDATE}" = "true" ]; then
  log "Updating ComfyUI..."
  cd "${COMFYUI_DIR}"
  git pull
fi

# =============================================================================
# Install / update ComfyUI Python dependencies
# =============================================================================

log "Installing ComfyUI requirements..."
pip install --no-cache-dir -r "${COMFYUI_DIR}/requirements.txt"

# =============================================================================
# Custom nodes registry (N4 canonical)
# =============================================================================

declare -A NODE_REPOS=(
  ["manager"]="https://github.com/ltdrdata/ComfyUI-Manager.git"
  ["impact-pack"]="https://github.com/ltdrdata/ComfyUI-Impact-Pack.git"
  ["controlnet"]="https://github.com/Fannovel16/comfyui_controlnet_aux.git"
  ["kjnodes"]="https://github.com/kijai/ComfyUI-KJNodes.git"
  ["civicomfy"]="https://github.com/MoonGoblinDev/Civicomfy.git"
)

mkdir -p "${CUSTOM_NODES_DIR}"

# =============================================================================
# Install / update custom nodes
# =============================================================================

IFS=',' read -ra NODES <<< "${CUSTOM_NODES}"

for node in "${NODES[@]}"; do
  repo="${NODE_REPOS[$node]:-}"

  if [ -z "${repo}" ]; then
    log "WARNING: Unknown custom node alias: ${node}"
    continue
  fi

  target="${CUSTOM_NODES_DIR}/$(basename "${repo}" .git)"

  if [ ! -d "${target}" ]; then
    log "Cloning custom node: ${node}"
    git clone "${repo}" "${target}"
  elif [ "${COMFY_UPDATE}" = "true" ]; then
    log "Updating custom node: ${node}"
    cd "${target}"
    git pull
  fi
done

# =============================================================================
# Install dependencies for all custom nodes (unified pass)
# =============================================================================

log "Installing custom node dependencies..."

cd "${CUSTOM_NODES_DIR}"

for dir in */; do
  [ -d "${dir}" ] || continue
  log "Processing ${dir}"

  cd "${CUSTOM_NODES_DIR}/${dir}"

  if [ -f "requirements.txt" ]; then
    log "  Installing requirements.txt"
    pip install --no-cache-dir -r requirements.txt || true
  fi

  if [ -f "install.py" ]; then
    log "  Running install.py"
    python3 install.py || true
  fi

  if [ -f "setup.py" ]; then
    log "  Installing setup.py (editable)"
    pip install --no-cache-dir -e . || true
  fi
done

# =============================================================================
# Start ComfyUI
# =============================================================================

cd "${COMFYUI_DIR}"

FIXED_ARGS="--listen 0.0.0.0 --port 8188"
ARGS_FILE="${WORKSPACE}/comfyui_args.txt"

if [ -f "${ARGS_FILE}" ]; then
  EXTRA_ARGS=$(grep -v '^#' "${ARGS_FILE}" | xargs)
else
  EXTRA_ARGS=""
fi

log "Starting ComfyUI..."
log "Args: ${FIXED_ARGS} ${EXTRA_ARGS}"

exec python3 main.py ${FIXED_ARGS} ${EXTRA_ARGS}
