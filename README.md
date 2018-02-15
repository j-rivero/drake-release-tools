Drake release tools
===================

Repository containing the tools necessary to launch the process of .deb package creation.

Usage
-----------------

Be sure of having docker installed. In the case of a CI enviroment, if the CI setup automatically docker the build will need docker in docker so be sure of adding `--priviledge` to docker run and map the docker sock inside the container. 

***build-drake-pkg.bash***: one call for the whole process, will perform:
 * Setup a docker container for running all the process
 * Cloning the release repository
 * Generate snapshot from drake master branch repository     
 * Import the snapshot to the release repository
 * Generate debian changelogs
 * Install build dependencies
 * Build package
 * Export the package to the pkgs/ directory

Technical details
-----------------
The generation of .deb packages uses the [Debian Packaging with Git](https://wiki.debian.org/PackagingWithGit) approach (mainly to have a drake-release repo that imports upstream code and have the deb package metedata) and the tool `git-buildpackage`. The code to generate the snapshot is included in the debian/rules file inside the drake-release repository and it can be invoked individually just by running `./debian/rules get-source-orig`.

The .deb package generated uses the format: drake-`latest_released_version`+`timestamp`r`snapshot_commit`
