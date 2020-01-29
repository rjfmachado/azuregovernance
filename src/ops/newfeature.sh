git checkout -q master

git branch | grep "master"

# the feature name is expected in arguments
if [[ $# -ne 1 ]] ; then
    echo "Usage: ./newfeature.sh [New Feature Name]"
    exit 1
else
 featurename=$1
fi

git checkout -b "feature/${featurename}"
git push --set-upstream origin feature/${newrelease}

echo "Feature branch feature/${newrelease} is now ready."
