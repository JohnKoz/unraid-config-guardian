#!/bin/bash
# Template refresh script - runs with elevated privileges to update cached templates

TEMPLATES_SOURCE="/boot/config/plugins/dockerMan/templates-user"
TEMPLATES_CACHE="/output/cached-templates"

echo "🔄 Refreshing cached templates..."

# Check if source directory exists
if [ ! -d "$TEMPLATES_SOURCE" ]; then
    echo "❌ Template source directory not found: $TEMPLATES_SOURCE"
    exit 1
fi

# Create cache directory
mkdir -p "$TEMPLATES_CACHE"

# Remove old cached templates
rm -f "$TEMPLATES_CACHE"/*.xml 2>/dev/null

# Copy current templates
if [ "$(ls -A "$TEMPLATES_SOURCE"/*.xml 2>/dev/null)" ]; then
    cp "$TEMPLATES_SOURCE"/*.xml "$TEMPLATES_CACHE"/ 2>/dev/null
    template_count=$(ls -1 "$TEMPLATES_CACHE"/*.xml 2>/dev/null | wc -l)
    echo "✅ Refreshed $template_count XML templates"

    # Ensure proper ownership for the user who will read them.
    # This script usually runs via sudo, which strips PUID/PGID from the
    # environment by default even though the sudoers rule allows it to
    # run - so match ownership to /output itself (already chowned to the
    # app's PUID:PGID user by entrypoint.sh) instead of depending on
    # those env vars surviving sudo.
    chown -R --reference="/output" "$TEMPLATES_CACHE" 2>/dev/null || true
else
    echo "ℹ️ No XML templates found to refresh"
fi
