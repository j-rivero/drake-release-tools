#!/bin/bash

source "lib/config.bash"

RELEASE_REPO_DIR="$(mktemp -d)/drake-release"
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

clone_release_repo()
{
  git clone ${RELEASE_REPO_URL} ${RELEASE_REPO_DIR} -q > git_clone.log || error "Failed the clone of ${RELEASE_REPO_URL}"
  pushd ${RELEASE_REPO_DIR} > /dev/null
  # need upstream branch to make gbp work
  git checkout upstream
  git checkout master
  popd > /dev/null
}

generate_snapshot()
{
  local repo_path=${1}

  pushd ${RELEASE_REPO_DIR} > /dev/null
  ./debian/rules get-orig-source > get_orig.log || error "Failed to get the drake snapshot"
  ls *.tar.xz || error "Unable to find the snapshot generated"
  mv *.tar.xz ../
  popd > /dev/null
}

import_snapshot()
{
  pushd ${RELEASE_REPO_DIR} > /dev/null
  gbp import-orig --no-interactive ../drake*.orig.tar.xz
  rm ../drake*.orig.tar.xz
  popd > /dev/null
}

generate_changelog()
{
  pushd ${RELEASE_REPO_DIR} > /dev/null
  gbp dch --auto --multimaint-merge --ignore-branch --distribution `lsb_release -c -s` --force-distribution --commit || error "Problem generating the new changelog entry"
  popd > /dev/null
}

install_build_dependencies()
{
  pushd ${RELEASE_REPO_DIR} > /dev/null
  mk-build-deps -r -i debian/control --tool 'apt-get --yes -o Debug::pkgProblemResolver=yes -o  Debug::BuildDeps=yes'
  popd > /dev/null
}

build_package()
{
  pushd ${RELEASE_REPO_DIR} > /dev/null
  gbp buildpackage --git-force-create --git-notify=false --git-ignore-branch --git-ignore-new --git-verbose --git-export-dir=../build-area -sa -S -uc -us 
  popd > /dev/null
}

info "Cloning the release repository"
clone_release_repo

info "Generate snapshot from drake source code"
generate_snapshot 

info "Import snapshot from drake source code"
import_snapshot 

info "Generate debian changelogs"
generate_changelog

info "Install build dependencies"
install_build_dependencies

info "Build packages"
build_package
