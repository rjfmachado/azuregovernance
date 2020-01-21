currentrelease=$(cat release.json | jq .release)
newrelease=$((currentrelease+1))

echo "Current Release: r$currentrelease"
echo "Creating Release: r$newrelease"

git checkout master

git checkout -b "release/r${newrelease}"
git push --set-upstream origin release/r${newrelease}

sed -i 's|\"release\": $currentrelease|\"release\": $newrelease|g' ./release.json

git add release.json

git commit -A -m "Changing to release r${newrelease}"

echo "You are now ready to commit changes to terraform code."