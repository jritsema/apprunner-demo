FROM public.ecr.aws/docker/library/node:alpine
WORKDIR /usr/src/app
COPY package.json .
RUN npm install --loglevel warn
COPY index.js index.html ./
CMD [ "node", "." ]
