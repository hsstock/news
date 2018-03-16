#!/bin/sh

# This is the Meteor install script!
#
# Are you looking at this in your web browser, and would like to install Meteor?
#
# MAC AND LINUX:
#   Just open up your terminal and type:
#
#     curl https://install.meteor.com/ | sh
#
#   Meteor currently supports:
#    - Mac: OS X 10.7 and above
#    - Linux: x86 and x86_64 systems
#
# WINDOWS:
#   Download the Windows installer from https://install.meteor.com/windows
#
#   Meteor currently supports Windows 7, Windows 8.1, Windows Server 2008,
#   and Windows Server 2012.

# We wrap this whole script in a function, so that we won't execute
# until the entire script is downloaded.
# That's good because it prevents our output overlapping with curl's.
# It also means that we can't run a partially downloaded script.
# We don't indent because it would be really confusing with the heredocs.


# This always does a clean install of the latest version of Meteor into your
# ~/.meteor, replacing whatever is already there. (~/.meteor is only a cache of
# packages and package metadata; no personal persistent data is stored there.)

RELEASE="1.6.1"

# Now, on to the actual installer!

## NOTE sh NOT bash. This script should be POSIX sh only, since we don't
## know what shell the user has. Debian uses 'dash' for 'sh', for
## example.

PREFIX="/usr/local"

set -e
set -u

# Let's display everything on stderr.
exec 1>&2


UNAME=$(uname)
# Check to see if it starts with MINGW.
if [ "$UNAME" ">" "MINGW" -a "$UNAME" "<" "MINGX" ] ; then
    echo "To install Meteor on Windows, download the installer from:"
    echo "https://install.meteor.com/windows"
    exit 1
fi
if [ "$UNAME" != "Linux" -a "$UNAME" != "Darwin" ] ; then
    echo "Sorry, this OS is not supported yet via this installer."
    echo "For more details on supported platforms, see https://www.meteor.com/install"
    exit 1
fi


if [ "$UNAME" = "Darwin" ] ; then
  ### OSX ###
  if [ "i386" != "$(uname -p)" -o "1" != "$(sysctl -n hw.cpu64bit_capable 2>/dev/null || echo 0)" ] ; then
    # Can't just test uname -m = x86_64, because Snow Leopard can
    # return other values.
    echo "Only 64-bit Intel processors are supported at this time."
    exit 1
  fi

  # Running a version of Meteor older than 0.6.0 (April 2013)?
  if grep BUNDLE_VERSION /usr/local/bin/meteor >/dev/null 2>&1 ; then
    echo "You appear to have a very old version of Meteor installed."
    echo "Please remove it by running these commands:"
    echo "  $ sudo rm /usr/local/bin/meteor"
    echo "  $ sudo rm -rf /usr/local/meteor /usr/local/meteor.old"
    echo "and then run the installer command again:"
    echo "  $ curl https://install.meteor.com/ | sh"
    exit 1
  fi
  TARBALL_FILE="$METEOR_SETUP/meteor-bootstrap-os.osx.x86_64.tar.gz"
elif [ "$UNAME" = "Linux" ] ; then
  ### Linux ###
  LINUX_ARCH=$(uname -m)
  if [ "${LINUX_ARCH}" = "i686" ] ; then
    PLATFORM="os.linux.x86_32"
  elif [ "${LINUX_ARCH}" = "x86_64" ] ; then
    TARBALL_FILE="$METEOR_SETUP/meteor-bootstrap-os.linux.x86_64.tar.gz"
  else
    echo "Unusable architecture: ${LINUX_ARCH}"
    echo "Meteor only supports i686 and x86_64 for now."
    exit 1
  fi
fi

INSTALL_TMPDIR="$HOME/meteor-install-tmp"

cleanUp() {
  rm -rf "$TARBALL_FILE"
  rm -rf "$INSTALL_TMPDIR"
}

mkdir "$INSTALL_TMPDIR"

# bomb out if it didn't work, eg no net
test -e "${TARBALL_FILE}"

echo "unzip..."

tar zxvf "$TARBALL_FILE" -C "$INSTALL_TMPDIR" -o

test -x "${INSTALL_TMPDIR}/.meteor/meteor"
mv "${INSTALL_TMPDIR}/.meteor" "$HOME"
echo "move meteor install files to home dir"

# just double-checking :)
test -x "$HOME/.meteor/meteor"

# The `trap cleanUp EXIT` line above won't actually fire after the exec
# call below, so call cleanUp manually.
cleanUp
echo "clean up install dir"

echo "Meteor ${RELEASE} has been installed in your home directory (~/.meteor)."

METEOR_SYMLINK_TARGET="$(readlink "$HOME/.meteor/meteor")"
METEOR_TOOL_DIRECTORY="$(dirname "$METEOR_SYMLINK_TARGET")"
LAUNCHER="$HOME/.meteor/$METEOR_TOOL_DIRECTORY/scripts/admin/launch-meteor"

if cp "$LAUNCHER" "$PREFIX/bin/meteor" >/dev/null 2>&1; then
  echo "Writing a launcher script to $PREFIX/bin/meteor for your convenience."
  cat <<"EOF"

EOF
elif type sudo >/dev/null 2>&1; then
  echo "Writing a launcher script to $PREFIX/bin/meteor for your convenience."
  echo "This may prompt for your password."

  # New macs (10.9+) don't ship with /usr/local, however it is still in
  # the default PATH. We still install there, we just need to create the
  # directory first.
  # XXX this means that we can run sudo too many times. we should never
  #     run it more than once if it fails the first time
  if [ ! -d "$PREFIX/bin" ] ; then
      sudo mkdir -m 755 "$PREFIX" || true
      sudo mkdir -m 755 "$PREFIX/bin" || true
  fi

  if sudo cp "$LAUNCHER" "$PREFIX/bin/meteor"; then
    cat <<"EOF"

EOF
  else
    cat <<EOF

EOF
  fi
else
  cat <<EOF


EOF
fi

trap - EXIT