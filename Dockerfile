FROM bash:4.3.48-alpine3.19
COPY github-git-mirror.sh /
ENV LOCAL_GIT_ACCESS_TOKEN=""
ENV LOCAL_GIT_URL=""
ENV GIT_USER=""
ENV TARGET_ORG=""
ENV MODDE=""
CMD ["bash", "/github-git-mirror.sh", "${GIT_USER}", "${TARGET_ORG}", "${MODE}"]