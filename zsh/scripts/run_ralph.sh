#!/usr/bin/env zsh

# Usage: ./run_ralph.sh <prd_path> [max_iterations]
# Example: ./run_ralph.sh notes/prds/12-01-2026_task_label_refactor.md 10

prd_path="$1"
max_iterations="${2:-10}"  # Default to 10 iterations if not specified

# Exit codes
EXIT_SUCCESS=0
EXIT_INVALID_ARGS=1
EXIT_BLOCKED=2
EXIT_NO_ELIGIBLE=3
EXIT_MAX_ITERATIONS=4
EXIT_NO_SIGNAL=5

# Validate arguments
if [[ -z "$prd_path" ]]; then
    echo "Usage: $0 <prd_path> [max_iterations]"
    echo "  prd_path:       Relative path to the PRD file (e.g., notes/prds/my_prd.md)"
    echo "  max_iterations: Maximum loop iterations (default: 10)"
    exit $EXIT_INVALID_ARGS
fi

# Validate DEFAULT_MODEL is set
if [[ -z "$DEFAULT_MODEL" ]]; then
    echo "Error: DEFAULT_MODEL environment variable is not set."
    exit $EXIT_INVALID_ARGS
fi

# Validate PRD file exists
if [[ ! -f "$prd_path" ]]; then
    echo "Error: PRD file not found: $prd_path"
    exit $EXIT_INVALID_ARGS
fi

iteration=0
should_continue=true
final_exit_code=$EXIT_SUCCESS

echo "=========================================="
echo "Starting PRD Loop Execution"
echo "PRD: $prd_path"
echo "Model: $DEFAULT_MODEL"
echo "Max Iterations: $max_iterations"
echo "=========================================="

while $should_continue && (( iteration < max_iterations )); do
    ((iteration++))
    echo ""
    echo "=========================================="
    echo "Iteration $iteration of $max_iterations"
    echo "=========================================="
    
    # Run opencode with the loop command, streaming output to terminal and capturing to temp file
    output_file=$(mktemp)
    opencode run --command loop --model "$DEFAULT_MODEL" "$prd_path" 2>&1 | tee "$output_file"
    exit_code=$?
    
    # Check for exit signals in output
    if rg -qF '[LOOP_SIGNAL:ALL_PHASES_COMPLETE]' "$output_file"; then
        echo ""
        echo "=========================================="
        echo "SUCCESS: All phases complete!"
        echo "=========================================="
        should_continue=false
        final_exit_code=$EXIT_SUCCESS
        
    elif rg -qF '[LOOP_SIGNAL:PHASE_COMPLETE]' "$output_file"; then
        echo ""
        echo "Phase completed. Continuing to next phase..."
        # Continue to next iteration
        
    elif rg -qF '[LOOP_SIGNAL:PHASE_BLOCKED]' "$output_file"; then
        echo ""
        echo "=========================================="
        echo "BLOCKED: Phase is blocked and cannot continue."
        echo "Please review the PRD and plan files for details."
        echo "=========================================="
        should_continue=false
        final_exit_code=$EXIT_BLOCKED
        
    elif rg -qF '[LOOP_SIGNAL:NO_ELIGIBLE_PHASE]' "$output_file"; then
        echo ""
        echo "=========================================="
        echo "STOPPED: No eligible phase to work on."
        echo "All remaining phases may be blocked or have unmet dependencies."
        echo "=========================================="
        should_continue=false
        final_exit_code=$EXIT_NO_ELIGIBLE
        
    else
        echo ""
        echo "=========================================="
        echo "WARNING: No recognized exit signal detected."
        echo "This may indicate an unexpected error or the agent did not complete properly."
        echo "Exit code: $exit_code"
        echo "=========================================="
        should_continue=false
        final_exit_code=$EXIT_NO_SIGNAL
    fi
    
    # Clean up temp file
    rm -f "$output_file"
done

# Check if we hit the iteration limit
if (( iteration >= max_iterations )) && $should_continue; then
    echo ""
    echo "=========================================="
    echo "STOPPED: Maximum iterations ($max_iterations) reached."
    echo "The PRD may not be fully complete."
    echo "=========================================="
    final_exit_code=$EXIT_MAX_ITERATIONS
fi

echo ""
echo "Loop finished after $iteration iteration(s)."
exit $final_exit_code
