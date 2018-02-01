RELEASE_REPO_URL="https://github.com/j-rivero/drake-release"
DEBIAN_FRONTEND=noninteractive
DEBFULLNAME='TRI builder'
DEBEMAIL='tri@builder.test'

git config --global user.email "${DEBFULLNAME}"
git config --global user.name "${DEBEMAIL}"
