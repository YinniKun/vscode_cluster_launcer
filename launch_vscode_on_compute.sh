#!/bin/bash

# The name of your cluster connection in ~/.ssh/config
LOGIN_NODE="" 

echo "🔍 Connecting to $LOGIN_NODE ... (Approve the 2FA prompt on your phone if you have one)"
REMOTE_USER=""
WORKING_DIR=""


# The '<< EOF' block sends all this code to run natively on the cluster.
# This requires only 1 SSH connection.
OUTPUT=$(ssh -T $LOGIN_NODE << 'EOF'
    
    JOB_NAME="vscode_workspace"
    SLURM_ARGS=""
    REMOTE_USER=""

    NODE=$(squeue -u $REMOTE_USER --name=$JOB_NAME -t R -h -O NodeList | tr -d ' ')
    
    if [ -z "$NODE" ]; then
        >&2 echo "🚀 Submitting resource request to /scratch..."
        cd /scratch/$REMOTE_USER
        sbatch $SLURM_ARGS -J $JOB_NAME --wrap="sleep infinity" > /dev/null
        
        >&2 echo "⏳ Waiting for allocation in queue..."
        while [ -z "$NODE" ]; do
            sleep 5
            NODE=$(squeue -u $REMOTE_USER --name=$JOB_NAME -t R -h -O NodeList | tr -d ' ')
        done
    else
        >&2 echo "✅ Found existing allocation!"
    fi
    
    # Print the final node back to the Mac securely
    echo "ALLOCATED_NODE:$NODE"
EOF
)

# Extract the node name from the remote output
NODE=$(echo "$OUTPUT" | awk -F 'ALLOCATED_NODE:' '{print $2}' | tr -d ' \n')

if [ -n "$NODE" ]; then
    echo "🖥️  Target Compute Node: $NODE"
    echo "🔌 Launching VS Code..."
    code --remote ssh-remote+$NODE $WORKING_DIR
else
    echo "❌ Failed to retrieve a node allocation."
    echo "Debug Output: $OUTPUT"
fi