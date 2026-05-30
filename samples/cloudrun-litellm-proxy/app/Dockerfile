# Pinned LiteLLM image — bump explicitly to control rollouts and CVE exposure.
FROM ghcr.io/berriai/litellm:main-v1.52.0

WORKDIR /app

COPY config.yaml /app/config.yaml

EXPOSE 4000

# LiteLLM resolves --config from the path; LITELLM_CONFIG_PATH env is set by
# the Cloud Run service for clarity but the CLI flag is what binds it.
CMD ["--config", "/app/config.yaml", "--port", "4000", "--num_workers", "1"]
