FROM node:20-alpine
# Installing libvips-dev for sharp Compatibility
RUN apk update && apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev nasm bash vips-dev git
ARG NODE_ENV=development
ENV NODE_ENV=${NODE_ENV}

WORKDIR /opt/
COPY package.json yarn.lock ./
RUN yarn global add node-gyp
RUN yarn config set network-timeout 600000 -g && yarn install
ENV PATH /opt/node_modules/.bin:$PATH

WORKDIR /opt/app
COPY . .
RUN chown -R node:node /opt/app
USER node
RUN yarn install

RUN yarn build

# EXTRA VITE STUFF HERE
# switch back to root to make node:node owner of node_modules after build
USER root
RUN chown node:node /opt/app/node_modules
# switch back to node user to create vite writeable directory
USER node
RUN mkdir -p /opt/app/node_modules/.strapi/vite

EXPOSE 1337
EXPOSE 5173
CMD ["yarn", "develop"]