FROM node:20-alpine

# Install dependencies needed to build the app
RUN apk update && apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev nasm bash vips-dev git

# Set the environment to development by default
ARG NODE_ENV=development
ENV NODE_ENV=${NODE_ENV}

# Set working directory
WORKDIR /opt

# Copy package.json and yarn.lock
COPY package.json yarn.lock ./

# Install node-gyp globally and project dependencies
RUN yarn global add node-gyp && \
    yarn config set network-timeout 600000 -g && \
    yarn install

# Set PATH
ENV PATH /opt/node_modules/.bin:$PATH

# Create the necessary directories and ensure permissions
RUN mkdir -p /opt/app /opt/.strapi && \
    chown -R node:node /opt/

# Copy application source
WORKDIR /opt/app
COPY . .

# Run as the node user
USER node

# Install and build the application
RUN yarn install && yarn build

# Make sure the vite directory exists and permissions are set
RUN mkdir -p /opt/app/node_modules/.strapi/vite && \
    chown -R node:node /opt/app/node_modules/.strapi/vite

# Expose necessary ports
EXPOSE 1337
EXPOSE 5173

# Start the application
CMD ["yarn", "develop"]