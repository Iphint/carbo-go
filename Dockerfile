FROM node:20-bookworm-slim

WORKDIR /app

COPY backend/package*.json ./backend/
RUN cd backend && npm ci

COPY backend ./backend
COPY database ./database

WORKDIR /app/backend

EXPOSE 5000

CMD ["npm", "start"]
