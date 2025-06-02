#!/bin/bash

set -e

changed_dirs=$(git status --porcelain | awk '{print $2}' | cut -d/ -f1,2 | sort -u)
bumped_any=false

for dir in $changed_dirs; do
    if [[ -f "$dir/pyproject.toml" ]]; then
        echo "Detected changes in $dir"
        cd "$dir"
        if cz check --rev-range HEAD~1..HEAD > /dev/null 2>&1; then
            cz bump --yes --no-changelog
            echo "Bumped version in $dir/pyproject.toml"
            git add pyproject.toml || true
            git commit -m "chore($dir): bump version [skip ci]"
            latest_tag=$(git describe --tags --abbrev=0)
            git tag "$latest_tag"
            bumped_any=true
        else
            echo "No conventional commit found for $dir, skipping version bump."
        fi
        cd - > /dev/null
    fi
done

if [ "$bumped_any" = true ]; then
    git push
    git push --tags
fi