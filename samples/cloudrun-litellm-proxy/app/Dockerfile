# Pinned LiteLLM image — bump explicitly to control rollouts and CVE exposure.
FROM ghcr.io/berriai/litellm:v1.88.6@sha256:0c73da8d132b893bfa037511553bafbc9e2ff6abe9b474a66e0e9a354c0be064

WORKDIR /app

COPY config.yaml /app/config.yaml

# Base image (apko/Wolfi) already ships an unprivileged "nonroot" account.
USER nonroot

EXPOSE 4000

# LiteLLM resolves --config from the path; LITELLM_CONFIG_PATH env is set by
# the Cloud Run service for clarity but the CLI flag is what binds it.
CMD ["--config", "/app/config.yaml", "--port", "4000", "--num_workers", "1"]
