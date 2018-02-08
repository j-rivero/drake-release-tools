#!/bin/bash -e

RELEASE_REPO_URL="https://github.com/j-rivero/drake-release"
DEBIAN_FRONTEND=noninteractive
DEBFULLNAME='TRI builder'
DEBEMAIL='tri@builder.test'
RELEASE_REPO_DIR="$(mktemp -d)/drake-release"

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

install_bazel()
{
  if [[ -z `which bazel` ]]; then
	info "Did not find bazel. Proceed with the installation"
	sudo apt-get install -y -qq openjdk-8-jdk bash-completion zlib1g-dev
	# TODO: this piece of code is extracted from the setup/ directory in the drake
	# main repository. Refactoring that script should help to avoid the duplication
	dpkg_install_from_wget() {
		package="$1"
		version="$2"
		url="$3"
		checksum="$4"

		# Skip the install if we're already at the exact version.
		installed=$(dpkg-query --showformat='${Version}\n' --show "${package}" 2>/dev/null || true)
		if [[ "${installed}" == "${version}" ]]; then
		  echo "${package} is already at the desired version ${version}"
		  return
		fi

		# If installing our desired version would be a downgrade, ask the user first.
		if dpkg --compare-versions "${installed}" gt "${version}"; then
		  echo "This system has ${package} version ${installed} installed."
		  echo "Drake suggests downgrading to version ${version}, our supported version."
		  read -r -p "Do you want to downgrade? [Y/n] " reply
		  if [[ ! "${reply}" =~ ^([yY][eE][sS]|[yY])*$ ]]; then
			  echo "Skipping ${package} ${version} installation."
			  return
		  fi
		fi

		# Download and verify.
		tmpdeb="/tmp/${package}_${version}-amd64.deb"
		wget -O "${tmpdeb}" "${url}"
		if echo "${checksum} ${tmpdeb}" | sha256sum -c -; then
		  echo  # Blank line between checkout output and dpkg output.
		else
		  die "The ${package} deb does not have the expected SHA256.  Not installing."
		fi

		# Install.
		dpkg -i "${tmpdeb}"
		rm "${tmpdeb}"
	}

	# Install Bazel.
	dpkg_install_from_wget \
		bazel 0.6.1 \
		https://github.com/bazelbuild/bazel/releases/download/0.6.1/bazel_0.6.1-linux-x86_64.deb \
		5012d064a6e95836db899fec0a2ee2209d2726fae4a79b08c8ceb61049a115cd
  fi
}

clone_release_repo()
{
  git clone ${RELEASE_REPO_URL} ${RELEASE_REPO_DIR} -q > git_clone.log || error "Failed the clone of ${RELEASE_REPO_URL}"
  pushd ${RELEASE_REPO_DIR} > /dev/null
  cat debian/rules
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
  cat debian/changelog
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

export_pkgs()
{
  pushd ${RELEASE_REPO_DIR} > /dev/null
  mv ../*.deb ../*.dsc ../*.xz /pkgs/ || true
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

info "Installing Bazel"
install_bazel

info "Install build dependencies"
install_build_dependencies

info "Build packages"
build_package

info "Export pkgs"
export_pkgs
