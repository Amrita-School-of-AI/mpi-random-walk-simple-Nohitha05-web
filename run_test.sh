#!/bin/bash

# Exit immediately if any command fails
set -e

# Load the MPI module
module load mpi/openmpi-x86_64

# --- Test Configuration ---
# Number of MPI processes to use for the test
NP=4
# Name of the executable file
EXEC="./random_walk"
# Command-line arguments for the executable
# Format: <domain_size> <max_walk_iterations>
ARGS="20 1000"

# Make the executable file runnable
chmod +x $EXEC

# --- Test Execution ---
# Run the MPI program and capture its standard output
echo "Running command: mpirun --oversubscribe -np $NP $EXEC $ARGS"
OUTPUT=$(mpirun --oversubscribe -np $NP $EXEC $ARGS)

# --- Test Validation ---
# We expect each of the walker processes to print a "finished" message.
# With NP processes, we have 1 controller (rank 0) and (NP-1) walkers.
# Count how many times "Walker finished" appears in the output (not controller message).
COUNT=$(echo "$OUTPUT" | grep -c "Walker finished")

# The expected number of finished messages is equal to the number of walkers (NP-1).
EXPECTED_COUNT=$((NP-1))

if [ "$COUNT" -eq "$EXPECTED_COUNT" ]; then
    echo "✅ Test Passed: Found $COUNT 'finished' messages, as expected."
    echo "--- Program Output ---"
    echo "$OUTPUT"
    # Finalize the MPI environment
    MPI_Finalize();
    exit 0 # Success
else
    echo "❌ Test Failed: Expected $EXPECTED_COUNT 'finished' messages, but found $COUNT."
    echo "--- Program Output ---"
    echo "$OUTPUT"
    echo "----------------------"
    exit 1 # Failure
fi