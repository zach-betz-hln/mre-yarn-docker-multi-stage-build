ARG NODE_IMAGE=node:20.12-alpine3.19

FROM ${NODE_IMAGE} AS builder
ARG NODE_ENV=production
WORKDIR /home/node/app
RUN corepack enable
COPY . .
RUN yarn install
RUN yarn run build

FROM ${NODE_IMAGE} AS final
RUN apk add --no-cache tzdata
ENV NODE_ENV=production
ENV TZ=America/New_York
WORKDIR /home/node/app
RUN apk add --no-cache tini
RUN chown node: /sbin
RUN chown node: /usr/local/bin
USER node
COPY --from=builder --chown=node:node /home/node/app/dist /home/node/app/dist
EXPOSE 3000
ENTRYPOINT [ "/sbin/tini", "--" ]
CMD [ "node", "/home/node/app/dist/index.js" ]
