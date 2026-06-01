# Skillspector Docker Image for Harness STO

Docker image that wraps [NVIDIA Skillspector](https://github.com/nvidia/skillspector) for use as a Harness STO (Security Testing Orchestration) step. Scans AI agent skills for security vulnerabilities and outputs results in SARIF format.

## What is Skillspector?

Skillspector is a security scanner for AI agent skills (Claude Code, Cursor, etc.) that detects:
- Prompt injection vulnerabilities
- Data exfiltration risks
- Privilege escalation attempts
- Supply chain security issues
- 64+ vulnerability patterns across 16 categories

## Quick Start

### Build the Image

```bash
docker build -t skillspector-sto:latest .
```

### Run Locally

Scan a directory containing skill files (SKILL.md):

```bash
docker run --rm \
  -v $(pwd)/my-skills:/workspace \
  -v $(pwd)/output:/output \
  skillspector-sto:latest
```

## Configuration Parameters

Configure via environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `SCAN_PATH` | Path to scan for skill files | `/workspace` |
| `OUTPUT_PATH` | SARIF output file path | `/output/results.sarif` |
| `VERBOSE` | Enable verbose logging | `false` |
| `NO_LLM` | Disable LLM analysis (faster) | `false` |
| `SKILLSPECTOR_LOG_LEVEL` | Log level (DEBUG/INFO/WARNING/ERROR) | `INFO` |

### LLM Provider Configuration (Optional)

For enhanced semantic analysis, configure an LLM provider:

| Variable | Description |
|----------|-------------|
| `SKILLSPECTOR_PROVIDER` | Provider (openai/anthropic/nv_build) |
| `OPENAI_API_KEY` | OpenAI API key |
| `ANTHROPIC_API_KEY` | Anthropic API key |
| `NVIDIA_INFERENCE_KEY` | NVIDIA Inference API key |
| `SKILLSPECTOR_MODEL` | Override default model |

## Harness STO Integration

### Pipeline Setup

Your Harness pipeline should:
1. Clone Skillspector to `/skillspector/` (you already have this configured)
2. Add a **Run step** before Build to copy Skillspector into the build context:

```yaml
- step:
    type: Run
    name: Copy Skillspector to Build Context
    identifier: copy_skillspector
    spec:
      shell: Sh
      command: |-
        # Copy Skillspector source into build context
        cp -r /skillspector/* .
        
        # Verify pyproject.toml exists
        test -f pyproject.toml && echo "✓ pyproject.toml found" || echo "✗ pyproject.toml missing"
```

Then your **BuildAndPushDockerRegistry** step will build from `.` which now contains Skillspector's source files.

## Local Testing

Test the Docker image with a sample skill:

```bash
# Create a test skill
mkdir -p test-skills
cat > test-skills/SKILL.md << 'EOF'
---
name: test-skill
---

# Test Skill

This is a test skill for scanning.
EOF

# Run scan
docker run --rm \
  -v $(pwd)/test-skills:/workspace \
  -v $(pwd)/output:/output \
  -e VERBOSE=true \
  skillspector-sto:latest

# Check results
cat output/results.sarif
```

## SARIF Output

The tool outputs SARIF 2.1.0 format, which Harness STO can ingest to:
- Display vulnerability findings in the UI
- Fail builds based on severity thresholds
- Track security posture over time
- Generate compliance reports

## Troubleshooting

### No findings in SARIF

- Ensure your repository contains `SKILL.md` files
- Check the `SCAN_PATH` is correctly mounted
- Enable `VERBOSE=true` to see scan details

### Build failures

- Requires Python 3.12+ base image
- Ensure git is available during build
- Check network access to GitHub for cloning Skillspector

### Performance

- Use `NO_LLM=true` for faster scans (static analysis only)
- LLM analysis provides deeper semantic vulnerability detection
- Consider resource limits in Harness (1Gi memory recommended)

## License

This wrapper is provided as-is. Skillspector is licensed under Apache 2.0 by NVIDIA.
