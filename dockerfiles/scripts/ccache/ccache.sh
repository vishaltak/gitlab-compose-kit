#!/bin/bash

# Ccache does provide the `/usr/lib/ccache`, but since this is symlink to
# `/usr/bin/ccache` some compilation tools (like cmake) might readlink
# This will result in ccache being executed not a tool (like gcc) asked
#
# Since this is not a symlink, it solves this problem.
#
# Include this as: `#!/scripts/ccache/ccache.sh`

# Avoid circular dependency, remove current path from search paths
export PATH=${PATH/"/scripts/ccache:"/}

TOOL="$1"
shift

exec ccache $(basename "$TOOL") "$@"
