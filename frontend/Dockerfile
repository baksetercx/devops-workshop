FROM alpine:latest

WORKDIR /app

RUN apk update && \
    apk add yarn

# Task D.1:
# COPY package.json index.html ./
# Answer D.1:
COPY package.json yarn.lock index.html ./

RUN yarn install

ENTRYPOINT ["yarn", "serve"]
