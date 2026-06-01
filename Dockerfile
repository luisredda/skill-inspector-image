FROM python:3.12-slim

# Set working directory for building the tool
WORKDIR /skillspector

# Copy Skillspector source code (cloned by Harness CI step)
COPY . .

# Build and install Skillspector
RUN pip install --no-cache-dir -e .

# Create output directory for SARIF results
RUN mkdir -p /output

# Set environment variables with defaults
ENV SCAN_PATH=/workspace \
    OUTPUT_PATH=/output/results.sarif \
    SKILLSPECTOR_LOG_LEVEL=INFO

# Copy and set up entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
