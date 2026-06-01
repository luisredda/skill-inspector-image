#!/bin/bash
set -e

# Use environment variables or defaults
SCAN_PATH="${SCAN_PATH:-/workspace}"
OUTPUT_PATH="${OUTPUT_PATH:-/output/results.sarif}"
VERBOSE="${VERBOSE:-false}"

# Build the skillspector command
CMD="skillspector scan \"${SCAN_PATH}\" --format sarif --output \"${OUTPUT_PATH}\""

# Add verbose flag if requested
if [ "${VERBOSE}" = "true" ]; then
    CMD="${CMD} --verbose"
fi

# Add no-llm flag if LLM is disabled (for faster scans)
if [ "${NO_LLM}" = "true" ]; then
    CMD="${CMD} --no-llm"
fi

echo "Running: ${CMD}"
eval "${CMD}"

# Exit with the same code as skillspector
exit $?
