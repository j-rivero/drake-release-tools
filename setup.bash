#!/bin/bash -e

source "lib/config.bash"

sudo apt-get install -y git git-buildpackage build-essential dpkg-dev devscripts

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
