#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root_dir="$(cd "${script_dir}/.." && pwd)"
metadata_file="${root_dir}/blueprints/metadata.toml"
packages_file="${root_dir}/package-lists/daily-driver-dev.txt"
kickstart_file="${root_dir}/kickstarts/asus-tuf-a16-oem.ks"

if [[ ! -f "${metadata_file}" || ! -f "${packages_file}" || ! -f "${kickstart_file}" ]]; then
  echo "Missing required Fedora 43 image inputs" >&2
  exit 1
fi

cat "${metadata_file}"
printf '\n'

while IFS= read -r package || [[ -n "${package}" ]]; do
  [[ -z "${package}" ]] && continue
  [[ "${package}" =~ ^# ]] && continue
  printf '[[packages]]\n'
  printf 'name = "%s"\n' "${package}"
  printf 'version = "*"\n\n'
done < "${packages_file}"

printf '[customizations.installer.kickstart]\n'
printf 'contents = """\n'
cat "${kickstart_file}"
printf '\n"""\n'
