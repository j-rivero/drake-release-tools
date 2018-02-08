Drake release tools
===================

Repository containing the tools necessary to launch the process of 
.deb package creation.

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
