#!/bin/bash

set -euo pipefail

# Mirror starred Github repos to a Gitea Organization
CURL="curl -f -S -s"

if [[ -z "${LOCAL_GIT_ACCESS_TOKEN}" || -z "${LOCAL_GIT_URL}" ]];then
    echo -e "Please set gitea LOCAL_GIT_ACCESS token and url in environment:\nexport LOCAL_GIT_ACCESS_TOKEN=abc\nexport LOCAL_GIT_URL=http://gitea:3000\n\nexport MODE=repos\n" >&2
    echo -e "Don't use trailing slash in URL!"
    exit 1
fi

github_user="${1:-}"
gitea_organization="${2:-}"
# starred or repos2
mode="${3:-}"

if [[ -z "${github_user}" || -z "${gitea_organization}" ]]; then
    echo "Usage: $0 github_user gitea_organization" >&2
    exit 1
fi

header_options=(-H  "Authorization: Bearer ${LOCAL_GIT_ACCESS_TOKEN}" -H "accept: application/json" -H "Content-Type: application/json")
jsonoutput=$(mktemp -d -t github-repos-XXXXXXXX)
trap "rm -rvf ${jsonoutput}" EXIT

uid=$($CURL "${header_options[@]}" $LOCAL_GIT_URL/api/v1/orgs/${gitea_organization} |jq .id)

fetch_starred_repos(){
    i=1
    # Github API just returns empty arrays instead of 404
    while $CURL "https://api.github.com/users/${github_user}/${mode}?page=${i}&per_page=100" >${jsonoutput}/${i}.json \
	    && (( $(jq <${jsonoutput}/${i}.json '.|length') > 0 )) ; do
	(( i++ ))
    done
}

create_migration_repo() {
    if ! $CURL -w  "%{http_code}\n"  "${header_options[@]}" -d @- -X POST $LOCAL_GIT_URL/api/v1/repos/migrate > ${jsonoutput}/result.txt 2>${jsonoutput}/stderr.txt;then
	local code=$(<${jsonoutput}/result.txt)
	if (( code != 409 ));then # 409 == repo already exits
	    cat ${jsonoutput}/stderr.txt >&2
	fi
    fi
}

repos_to_migration() {
    for f in ${jsonoutput}/*.json; do
        n=$(jq '.|length'<$f)
        (( n-- ))		# last element
        for i in $(seq 0 $n); do
            jq ".[$i]|.uid=${uid}|.mirror=true|.clone_addr=.clone_url|.description=.description[0:255]|.repo_name=.name|{uid,repo_name,clone_addr,description,mirror}" <$f \
            | create_migration_repo
        done
    done
}

main(){
    fetch_starred_repos
    repos_to_migration
    sleep 43100

}
while :; do main; done
