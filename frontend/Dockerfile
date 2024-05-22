FROM alpine:latest

WORKDIR /app

RUN apk update && \
    apk add yarn

# Task D.1:
# COPY yarn.lock index.html ./
# Answer D.1:
COPY yarn.lock index.html package.json ./
#

RUN yarn install --frozen-lockfile

ENTRYPOINT ["yarn", "serve"]
