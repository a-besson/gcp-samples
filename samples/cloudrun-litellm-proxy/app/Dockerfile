# Pinned LiteLLM image — bump explicitly to control rollouts and CVE exposure.
FROM ghcr.io/berriai/litellm:v1.86.2@sha256:cae1ac3492d6d0bea69c26f4485381624e073eb753f3534ae7703a4204a4ce6b

WORKDIR /app

COPY config.yaml /app/config.yaml

# Base image (apko/Wolfi) already ships an unprivileged "nonroot" account.
USER nonroot

EXPOSE 4000

# LiteLLM resolves --config from the path; LITELLM_CONFIG_PATH env is set by
# the Cloud Run service for clarity but the CLI flag is what binds it.
CMD ["--config", "/app/config.yaml", "--port", "4000", "--num_workers", "1"]
