FROM node:20-alpine

# Instalar dependencias necesarias para construir la aplicación
RUN apk update && apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev nasm bash vips-dev git

# Establecer la variable de entorno para el entorno de desarrollo
ARG NODE_ENV=development
ENV NODE_ENV=${NODE_ENV}

# Establecer directorio de trabajo
WORKDIR /opt

# Copiar solamente package.json y yarn.lock para aprovechar el caché
COPY package.json yarn.lock ./

# Instalar node-gyp y dependencias del proyecto
RUN yarn global add node-gyp && \
    yarn config set network-timeout 600000 -g && \
    yarn install

# Ajustar el PATH
ENV PATH /opt/node_modules/.bin:$PATH

# Cambiar al directorio de la aplicación
WORKDIR /opt/app

# Copiar el resto del código fuente
COPY . .

# Asegurar que el usuario tiene privilegios necesarios en el directorio
RUN chown -R node:node /opt/app

# Cambiar al usuario 'node'
USER node

# Ejecutar comandos adicionales
RUN yarn install && yarn build

# Crear el directorio necesario para Vite (con permisos adecuados)
RUN mkdir -p /opt/app/node_modules/.strapi/vite && \
    chown -R node:node /opt/app/node_modules/.strapi/vite

# Exponer los puertos necesarios para Strapi y Vite
EXPOSE 1337
EXPOSE 5173

# Comando para ejecutar la aplicación
CMD ["yarn", "develop"]