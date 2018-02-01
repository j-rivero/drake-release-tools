Drake release tools
===================

Repository containing the tools necessary to launch the process of 
.deb package creation.

Scripts available
-----------------

***setup.sh***: install the necessary packages in Ubuntu/Debian to use
the release scripts.

***release-new-snapshot.bash***: launch the release process which is composed
by the following phases:

 * Cloning the release repository
 * Generate snapshot from drake master branch repository
 * Import the snapshot to the release repository
 * Generate debian changelogs
 * Install build dependencies
 * Build package
