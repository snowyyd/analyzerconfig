#!/bin/bash
set -e

# Colors
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
RESET="\033[0m"

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
PROJECT_DIR="$(realpath $SCRIPT_DIR/../AnalyzerConfig)"
ENV_FILE="$(realpath $SCRIPT_DIR/../.env)"

echo -e "${CYAN}Script directory: ${GREEN}${SCRIPT_DIR}${RESET}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo -e "${YELLOW}.env file not found in ${GREEN}${ENV_FILE}${RESET}"
  exit 1
fi

echo -e "${CYAN}Loading ${GREEN}${ENV_FILE}${RESET}"
set -a
source $ENV_FILE
set +a

CSPROJ_FILE=$(find "$PROJECT_DIR" -name "*.csproj" | head -n 1)
if [[ -z "$CSPROJ_FILE" ]]; then
  echo -e "${YELLOW}No .csproj file found in ${GREEN}${PROJECT_DIR}${RESET}"
  exit 1
fi

echo -e "${CYAN}Found .csproj file: ${GREEN}${CSPROJ_FILE}${RESET}"

VERSION=$(grep -oP '(?<=<Version>)(.*)(?=</Version>)' "$CSPROJ_FILE")
if [[ -z "$VERSION" ]]; then
  echo -e "${YELLOW}Version not found in .csproj file! Please set the version manually.${RESET}"
  exit 1
fi

echo -e "${CYAN}Found version: ${GREEN}${VERSION}${RESET}"

echo -e "${CYAN}Packing NuGet${RESET}"
dotnet pack -c Release

NUPKG_PATH="$PROJECT_DIR/build/bin/Release/Snowyyd.AnalyzerConfig.$VERSION.nupkg"
if [[ -z "$NUPKG_PATH" ]]; then
  echo -e "${YELLOW}.nupkg not found in ${GREEN}${NUPKG_PATH}${RESET}"
  exit 1
fi

echo -e "${CYAN}Pushing NuGet package to GitLab: ${GREEN}${NUPKG_PATH}${RESET}"
dotnet nuget push "$NUPKG_PATH" --source gitlab

echo -e "${YELLOW}Done!${RESET}"
