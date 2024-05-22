FROM alpine:latest

WORKDIR /app

RUN apk update && \
    apk add yarn

COPY package.json index.html ./

RUN yarn install

ENTRYPOINT ["yarn", "serve"]
