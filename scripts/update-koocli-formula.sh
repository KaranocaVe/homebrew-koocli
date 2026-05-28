#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
FORMULA_PATH="${REPO_ROOT}/Formula/koocli.rb"

CURL_BIN="${CURL_BIN:-}"
if [[ -z "${CURL_BIN}" ]]; then
  if command -v curl >/dev/null 2>&1; then
    CURL_BIN="$(command -v curl)"
  elif [[ -x /usr/bin/curl ]]; then
    CURL_BIN="/usr/bin/curl"
  else
    echo "curl is required" >&2
    exit 1
  fi
fi

TMPDIR="$(mktemp -d)"
trap 'rm -rf "${TMPDIR}"' EXIT

BASE_URL="https://cn-north-4-hdn-koocli.obs.cn-north-4.myhuaweicloud.com/cli/latest"
MAC_ARM_ARCHIVE="huaweicloud-cli-mac-arm64.tar.gz"
MAC_INTEL_ARCHIVE="huaweicloud-cli-mac-amd64.tar.gz"
LINUX_ARM_ARCHIVE="huaweicloud-cli-linux-arm64.tar.gz"
LINUX_INTEL_ARCHIVE="huaweicloud-cli-linux-amd64.tar.gz"

fetch_sha() {
  local archive_name="$1"
  local sha_url="${BASE_URL}/${archive_name}.sha256"
  local sha_line

  sha_line="$("${CURL_BIN}" -fsSL "${sha_url}")"
  sha_line="${sha_line%% *}"

  if [[ ! "${sha_line}" =~ ^[0-9a-f]{64}$ ]]; then
    echo "Unexpected sha256 payload from ${sha_url}: ${sha_line}" >&2
    exit 1
  fi

  printf '%s' "${sha_line}"
}

extract_version() {
  local archive_name="$1"
  local archive_path="${TMPDIR}/${archive_name}"
  local expanded_dir="${TMPDIR}/extract"
  local hcloud_path version

  "${CURL_BIN}" -fsSL "${BASE_URL}/${archive_name}" -o "${archive_path}"
  rm -rf "${expanded_dir}"
  mkdir -p "${expanded_dir}"
  tar -xzf "${archive_path}" -C "${expanded_dir}"
  hcloud_path="${expanded_dir}/hcloud"

  if [[ ! -f "${hcloud_path}" ]]; then
    echo "Expected hcloud binary in ${archive_name}" >&2
    exit 1
  fi

  version="$(strings -a "${hcloud_path}" | perl -ne 'print "$1\n" if /-X hwcloudcli\/util\.CliVersion=([0-9]+(?:\.[0-9]+)+)/' | head -n1)"

  if [[ -z "${version}" ]]; then
    echo "Failed to extract KooCLI version from ${archive_name}" >&2
    exit 1
  fi

  printf '%s' "${version}"
}

MAC_ARM_SHA="$(fetch_sha "${MAC_ARM_ARCHIVE}")"
MAC_INTEL_SHA="$(fetch_sha "${MAC_INTEL_ARCHIVE}")"
LINUX_ARM_SHA="$(fetch_sha "${LINUX_ARM_ARCHIVE}")"
LINUX_INTEL_SHA="$(fetch_sha "${LINUX_INTEL_ARCHIVE}")"
VERSION="$(extract_version "${MAC_ARM_ARCHIVE}")"
export VERSION
export MAC_ARM_SHA
export MAC_INTEL_SHA
export LINUX_ARM_SHA
export LINUX_INTEL_SHA

ruby - "${FORMULA_PATH}" <<'RUBY'
formula_path = ARGV.fetch(0)
formula = File.read(formula_path)
base_url = "https://cn-north-4-hdn-koocli.obs.cn-north-4.myhuaweicloud.com/cli/latest"

formula.sub!(/version "[^"]+"/, %(version "#{ENV.fetch("VERSION")}"))

replacements = {
  "huaweicloud-cli-mac-arm64.tar.gz" => ENV.fetch("MAC_ARM_SHA"),
  "huaweicloud-cli-mac-amd64.tar.gz" => ENV.fetch("MAC_INTEL_SHA"),
  "huaweicloud-cli-linux-arm64.tar.gz" => ENV.fetch("LINUX_ARM_SHA"),
  "huaweicloud-cli-linux-amd64.tar.gz" => ENV.fetch("LINUX_INTEL_SHA"),
}

replacements.each do |archive, sha|
  pattern = Regexp.new("(url \"#{Regexp.escape(base_url)}/#{Regexp.escape(archive)}\"\\n\\s+sha256 \")[0-9a-f]{64}\"")
  unless formula.match?(pattern)
    warn "Failed to locate sha256 stanza for #{archive}"
    exit 1
  end
  formula.sub!(pattern, "\\1#{sha}\"")
end

File.write(formula_path, formula)
RUBY

echo "Updated ${FORMULA_PATH} to version ${VERSION}"
