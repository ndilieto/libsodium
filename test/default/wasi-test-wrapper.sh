#! /bin/sh

if [ -z "$WASI_RUNTIME" ] || [ "$WASI_RUNTIME" = "wasmtime" ]; then
  if command -v wasmtime >/dev/null; then
    wasmtime -o --dir=. "$1" && exit 0
  fi
fi

if [ -z "$WASI_RUNTIME" ] || [ "$WASI_RUNTIME" = "wasmer" ]; then
  if command -v wasmer >/dev/null; then
    wasmer run "$1" --backend "${WASMER_BACKEND:-cranelift}" --dir=. && exit 0
  fi
fi

if [ -z "$WASI_RUNTIME" ] || [ "$WASI_RUNTIME" = "lucet" ]; then
  if command -v lucetc-wasi >/dev/null && command -v lucet-wasi >/dev/null; then
    lucetc-wasi \
      --min-reserved-size "128MiB" \
      -o "${1}.so" --opt-level best "$1" &&
      lucet-wasi --dir=.:. "$1.so" && exit 0
  fi
fi

echo "WebAssembly runtime failed" >&2
exit 1