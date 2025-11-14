FROM alpine:latest

WORKDIR /app

RUN apk update && \
    apk add yarn

# legger til `package.json`:
COPY yarn.lock index.html package.json ./

RUN yarn install --frozen-lockfile

ENTRYPOINT ["yarn", "serve"]