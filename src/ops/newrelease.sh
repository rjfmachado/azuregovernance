currentrelease=$(cat release.json | jq .release)
newrelease=$((currentrelease+1))

echo "Current Release: r$currentrelease"
echo "Creating Release: r$newrelease"

git checkout master

git checkout -b "release/r$newrelease"

sed -i 's|\"release\": $currentrelease|\"release\": $newrelease|g' ./release.json

git add release.json

git commit -A -m "Changing to release r$newrelease"