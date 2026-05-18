# ── Stage 1: build ──────────────────────────────────────────────────────────
# Targets x86_64 Linux (HPE DL380 Gen9, Intel Xeon E5 v3/v4).
# AVX2 is universally available on E5 v3+.
# Set --build-arg ENABLE_AVX512=ON if your specific CPUs support it (v4 select SKUs).
FROM debian:bookworm-slim AS builder

ARG LLAMA_CPP_REF=master
ARG ENABLE_AVX512=OFF

RUN apt-get update && apt-get install -y --no-install-recommends \
    git cmake build-essential \
    libcurl4-openssl-dev ca-certificates \
  && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch ${LLAMA_CPP_REF} \
    https://github.com/ggerganov/llama.cpp /llama.cpp

WORKDIR /llama.cpp

# GGML_NATIVE=OFF + explicit AVX flags gives a portable binary that runs on
# any Xeon E5 v3/v4 without relying on the build host's CPU feature detection.
# LLAMA_RPC=ON registers the llama-rpc-server cmake target (off by default).
# Build everything rather than named targets to stay robust across llama.cpp
# cmake reorganisations — only the two required binaries are copied below.
RUN cmake -B build \
      -DCMAKE_BUILD_TYPE=Release \
      -DGGML_NATIVE=OFF \
      -DGGML_AVX=ON \
      -DGGML_AVX2=ON \
      -DGGML_F16C=ON \
      -DGGML_FMA=ON \
      -DGGML_AVX512=${ENABLE_AVX512} \
      -DLLAMA_CURL=ON \
      -DLLAMA_RPC=ON \
  && cmake --build build -j"$(nproc)"


# ── Stage 2: runtime ─────────────────────────────────────────────────────────
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4 ca-certificates curl \
    dnsutils \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder /llama.cpp/build/bin/llama-server     /usr/local/bin/llama-server
COPY --from=builder /llama.cpp/build/bin/llama-rpc-server /usr/local/bin/llama-rpc-server

RUN chmod +x /usr/local/bin/llama-server /usr/local/bin/llama-rpc-server \
 && useradd -u 1000 -m -s /bin/bash llama

USER 1000

EXPOSE 8080
EXPOSE 50052

ENTRYPOINT ["llama-server"]
