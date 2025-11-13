FROM alpine:latest

WORKDIR /app

RUN apk update && \
    apk add yarn

COPY package.json yarn.lock index.html ./

RUN yarn install --frozen-lockfile

ENTRYPOINT ["yarn", "serve"]
