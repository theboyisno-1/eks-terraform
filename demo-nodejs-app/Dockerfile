# FROM node:12-alpine

# RUN mkdir /home/code

# WORKDIR /home/code

# COPY . /home/code

# RUN npm install --production

# ENTRYPOINT [ "node", "/home/code/server.js" ]

# ---- Base Node ----
FROM alpine:3.12

# Install nodejs and and tini (its not recommended to run nodejs as PID 1)
RUN apk add --update --no-cache \
    nodejs=12.18.3-r0 yarn tini

COPY . .

RUN yarn install --only=production

ENTRYPOINT ["/sbin/tini", "--"]

CMD yarn run start