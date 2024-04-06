# Mirror your starred Github repos to a Gitea organization

### Inspiration for this script:

[Proposal: Mirror an entire github organization into gitea organization](https://github.com/go-gitea/gitea/issues/8424)


## Usage

The script runs forever, every 12 hours it executes API calls to retrieve either your starred or public repositories and mirrors them to your local gitea( or forks from this project) server.

Feel free to change it to a one time only script and calling it in a cronjob.

### Docker Compose

edit ```.env``` the way you need it

    docker-compose up --build

### Bash

    export LOCAL_GIT_ACCESS_TOKEN="your_access_token"
    export LOCAL_GIT_URL="your_git_url"
    export GIT_USER="your_git_user"
    export TARGET_ORG="your_target_org"
    export MODE="your_mode"

    bash github-git-mirror.sh "${GIT_USER}" "${TARGET_ORG}" "${MODE}"
