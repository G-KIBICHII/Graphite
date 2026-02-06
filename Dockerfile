# ---------- STAGE 1: Build Rust ----------
FROM rust:1.75 as rust-builder

WORKDIR /app

# copy rust files first (cache optimization)
COPY Cargo.toml Cargo.lock ./
COPY editor ./editor
COPY node-graph ./node-graph
COPY libraries ./libraries
COPY proc-macros ./proc-macros

RUN cargo build --release


# ---------- STAGE 2: Build Frontend ----------
FROM node:20 as frontend-builder

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY frontend ./frontend
RUN npm run build


# ---------- STAGE 3: Runtime ----------
FROM node:20-alpine

WORKDIR /app

COPY --from=frontend-builder /app .

EXPOSE 5173

CMD ["npm", "run", "dev"]
