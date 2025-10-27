FROM node:lts

WORKDIR /app

RUN git clone --depth=1 --branch=prod https://github.com/texas2010/api.home.texas2010.com.git .

RUN npm i -g pino-pretty

RUN npm ci
RUN npm run build:ts
RUN npm prune --omit=dev

ENV NODE_ENV=production
CMD ["npm", "run", "prod:start"]