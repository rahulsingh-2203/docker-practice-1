FROM node:20-alpine AS build

WORKDIR /frontend

COPY package*.json ./
RUN npm install

COPY . .

RUN npm run build


FROM httpd:alpine

COPY --from=build /frontend/dist /usr/local/apache2/htdocs/

EXPOSE 80

CMD ["httpd-foreground"]
