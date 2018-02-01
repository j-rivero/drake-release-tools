RELEASE_REPO_URL="https://github.com/j-rivero/drake-release"
DEBIAN_FRONTEND=noninteractive
DEBFULLNAME='TRI builder'
DEBEMAIL='tri@builder.test'

git config --global user.email "${DEBFULLNAME}"
git config --global user.name "${DEBEMAIL}"

RED='\033[1;31m'
GREEN='\033[1;32m'
NC='\033[0m' # No Color

error()
{
  local msg=${1}

  echo -e "${RED}[EE] ${msg}${NC}"
  exit 1
}

info()
{
  local msg=${1}

  echo -e "${GREEN}[-] ${msg}${NC}"
}
