#!/bin/bash

# <bitbar.title>Drone Status</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Craig Rosie</bitbar.author>
# <bitbar.author.github>craigrosie</bitbar.author.github>
# <bitbar.desc>Checks the status of the builds from Drone CI</bitbar.desc>
# <bitbar.dependencies>awk,bash,curl,jq</bitbar.dependencies>

# Needed for jq, curl, awk. If you install jq somewhere else you have to add it here as well
export PATH="/usr/local/bin:/usr/bin:$PATH"

# Filter repos by namespace
NAMESPACES="<Add Drone namespaces here>"

DRONE_SERVER="<Add Drone server url here>"

# The Account token from Webinterface -> Account -> Show Token
DRONE_TOKEN="<Add Drone token here>"

api_call() {
    local result

    result=$(curl --silent -sb -H "Accept: application/json" -H "Authorization: $DRONE_TOKEN" -X GET "$DRONE_SERVER/api/$1")
    echo "$result"
}

json=$(api_call "user/repos")

# Get all repos and their last build
repos_and_builds=$(api_call "user/repos" | jq --arg NAMESPACES "$NAMESPACES" '.[] | select(.owner|test($NAMESPACES)) | {name: .full_name, active: .last_build}')

# # Parse active repo names from JSON
repos=($(echo "$repos_and_builds" | grep name | awk '{ print $2}'))
# # Parse last build number from JSON
builds=($(echo "$repos_and_builds" | grep active | awk '{ print $2}'))

success=0
failure=0
running=0

output=

for i in "${!repos[@]}"; do
    repo=${repos[$i]//[,\"]/}
    build=${builds[$i]}

    build_location="repos/$repo/builds"

    # Get the status of the last build from the repo
    json=$(api_call "$build_location")

    result=$(echo "$json" | jq ".[] | select(.number==$build) | {status: .status}" | grep "status" | awk '{print $2}' | head -n 1)
    result=${result:1:${#result}-2}

    case $result in
        "success")
            output=$output"\\n$repo #$build: $result :white_check_mark: | href=$DRONE_SERVER/$repo/$build emojize=true"
            success=$((success + 1))
            ;;
        "failure")
            output=$output"\\n$repo #$build: $result :x: | href=$DRONE_SERVER/$repo/$build"
            failure=$((failure + 1))
            ;;
        "running")
            output=$output"\\n$repo #$build: $result :running: | href=$DRONE_SERVER/$repo/$build"
            running=$((running + 1))
            ;;
    esac

done

result_color=#00bfa5

if [[ $failure -gt 0 ]]; then
result_color=#f50057
fi

# Output data for BitBar
echo "Drone | color=$result_color"
echo "---"
echo -e "$output"

