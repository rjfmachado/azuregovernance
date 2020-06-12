git checkout -q master

git branch | grep "master"

currentrelease=$(cat release.json | jq .release | sed "s/\"//g")

# the release name is expected in arguments
if [[ $# -ne 1 ]] ; then
    echo "Current Release: ${currentrelease}"
    echo
    echo "Usage: ./newrelease.sh [New Release Name]"
    echo
    echo "Note: please use release names with the format"
    exit 1
else
 newrelease=$1
fi

echo "Current Release: ${currentrelease}"
echo "Creating Release: ${newrelease}"

sed -i "s/${currentrelease}/${newrelease}/g" ./release.json
sed -i "s/- release\/${currentrelease}/- release\/${newrelease}/g" ../../pipelines/ops-dailyvalidation.yaml
# TODO: add readme badge

git add release.json
git add ../../pipelines/ops-dailyvalidation.yaml

git commit -a -m "Creating release ${newrelease}."

git push

git checkout -b "release/${newrelease}"
git push --set-upstream origin "release/${newrelease}"

echo "You are now ready to release ${newrelease} from branch release/${newrelease}."
