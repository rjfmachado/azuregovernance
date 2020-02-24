git checkout -q master

git branch | grep "master"

# the feature name is expected in arguments
if [[ $# -ne 1 ]] ; then
    echo "Usage: ./newfeature.sh [New Feature Name]"
    exit 1
else
 featurename=$1
fi

if git checkout -b "feature/${featurename}" && git push --set-upstream origin feature/${featurename} ;
then
    echo "Feature branch feature/${featurename} is now ready."
else
    echo "Failed to create branch for feature name ${featurename}."
fi
