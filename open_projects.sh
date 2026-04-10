#!/bin/bash

# Check if tmux is already running
echo "Starting a new tmux session..."
tmux new-session -d -s projs 
SESSION_NAME="projs"

# Open the first window for gpu-offload
echo "Opening window for gpu-offload..."
tmux new-window -t "$SESSION_NAME":1 -n "gpu-offload"
tmux send-keys -t "$SESSION_NAME":1 "cd ~/projs/gpu-offload" C-m

# Open the second window for triton
echo "Opening window for triton..."
tmux new-window -t "$SESSION_NAME":2 -n "triton"
tmux send-keys -t "$SESSION_NAME":2 "cd ~/projs/triton-related/triton && source venv-triton/bin/activate && source env-debug.sh" C-m

# Open the second window for triton
echo "Opening window for llvm..."
tmux new-window -t "$SESSION_NAME":3 -n "llvm"
tmux send-keys -t "$SESSION_NAME":3 "cd ~/projs/triton-related/llvm-project" C-m

# Open the second window for triton-cache
echo "Opening window for cache..."
tmux new-window -t "$SESSION_NAME":4 -n "cache"
tmux send-keys -t "$SESSION_NAME":4 "cd ~/.triton/cache" C-m

# Open the second window for cutedsl 
echo "Opening window for cache..."
tmux new-window -t "$SESSION_NAME":5 -n "llm.cutedsl"
tmux send-keys -t "$SESSION_NAME":5 "cd ~/projs/llm.cutedsl" C-m

# Open the second window for cutedsl 
echo "Opening window for cache..."
tmux new-window -t "$SESSION_NAME":6 -n "llm.triton"
tmux send-keys -t "$SESSION_NAME":6 "cd ~/projs/llm.triton" C-m

# Open the second window for cutedsl 
echo "Opening window for cache..."
tmux new-window -t "$SESSION_NAME":7 -n "cutedsl-copilot"
tmux send-keys -t "$SESSION_NAME":7 "cd ~/projs/cutedsl-compiler/cutedsl-diy/ && source .venv-cutedsl-lj/bin/activate" C-m

echo "Opening window for cache..."
tmux new-window -t "$SESSION_NAME":8 -n "dsl-git"
tmux send-keys -t "$SESSION_NAME":8 "cd ~/projs/cutedsl-compiler/cutedsl-diy/ && source .venv-cutedsl-lj/bin/activate" C-m

echo "Opening window for cache..."
tmux new-window -t "$SESSION_NAME":9 -n "dsl-filetree"
tmux send-keys -t "$SESSION_NAME":9 "cd ~/projs/cutedsl-compiler/cutedsl-diy/ && source .venv-cutedsl-lj/bin/activate" C-m

echo "Opening window for cache..."
tmux new-window -t "$SESSION_NAME":10 -n "dsl-run"
tmux send-keys -t "$SESSION_NAME":10 "cd ~/projs/cutedsl-compiler/cutedsl-diy/ && source .venv-cutedsl-lj/bin/activate" C-m

# Select the first window
tmux select-window -t "$SESSION_NAME":7

# Attach to the session if not already attached
if [ -z "$TMUX" ]; then
  tmux attach-session -t "$SESSION_NAME"
fi

echo "Script finished. Your tmux windows are ready."
