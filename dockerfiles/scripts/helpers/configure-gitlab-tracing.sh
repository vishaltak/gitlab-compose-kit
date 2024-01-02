#!/usr/bin/env bash

case "$USE_TRACING" in
  jaeger)
    echo "Using Jaeger for GitLab Tracing..."
    export GITLAB_TRACING="opentracing://jaeger?http_endpoint=http%3A%2F%2Fjaeger%3A14268%2Fapi%2Ftraces&udp_endpoint=jaeger%3A6831&sampler=const&sampler_param=1"
    export GITLAB_TRACING_URL="http://${CUSTOM_HOSTNAME}:16686/search?service={{ service }}&tags=%7B\"correlation_id\"%3A\"{{ correlation_id }}\"%7D"
    ;;

  "")
    ;;

  *)
    echo "Unsupported Tracing setting: ${USE_TRACING}"
    exit 1
    ;;
esac
