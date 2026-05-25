# Carbon-Go React + Express + MySQL

Project ini memigrasikan HTML native lama menjadi frontend Vite + React dan backend Express + MySQL.

## Struktur

```text
backend/   Express REST API, auth JWT cookie httpOnly, MySQL models/controllers/routes
frontend/  Vite + React + React Router, protected route, onboarding guard, axios
database/  schema.sql untuk import via phpMyAdmin
```

## Setup Database via phpMyAdmin

1. Buka phpMyAdmin.
2. Pilih tab SQL atau Import.
3. Import file `database/schema.sql`.
4. Pastikan database `carbon_go` sudah terbuat dan tabel seed `activities`, `badges`, dan `milestones` sudah terisi.
5. Jika sebelumnya sudah pernah import schema lama, cara paling bersih adalah drop database `carbon_go` lalu import ulang `database/schema.sql`. Alternatifnya, jalankan `database/migrate_activity_feedback_i18n.sql`, lalu jalankan seed ulang. Schema terbaru sudah menyimpan nama dan feedback activity dalam EN/ID.

## Setup Backend

```bash
cd backend
npm install
cp .env.example .env
npm run seed
npm run dev
```

Sesuaikan isi `.env` jika user/password MySQL berbeda:

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=carbon_go
JWT_SECRET=change_this_to_a_long_random_secret
FRONTEND_URL=http://localhost:5173
```

API berjalan di `http://localhost:5000`.

## Setup Docker Backend + MySQL + phpMyAdmin

Docker setup menjalankan:

- Backend Express: `http://localhost:5001`
- MySQL host port: `localhost:33306`
- phpMyAdmin: `http://localhost:8080`

```bash
docker compose up --build
```

Credential MySQL/phpMyAdmin:

```text
Server: mysql
User: root
Password: rootpassword
Database: carbon_go
```

Jika connect dari aplikasi di luar Docker, gunakan host `127.0.0.1` dan port `33306`.

Saat container backend start, command ini otomatis dijalankan:

```bash
npm run seed
npm run seed:test
npm start
```

`npm run seed:test` membuat 30 user test lengkap dengan profile dan random activity logs.

Contoh login user test:

```text
Username: testuser01
Password: password123

Username: testuser30
Password: password123
```

Untuk reset data Docker MySQL dari nol:

```bash
docker compose down -v
docker compose up --build
```

## Setup Frontend

```bash
cd frontend
npm install
npm run dev
```

Frontend berjalan di `http://localhost:5173`.

Jika backend memakai URL lain, buat file `frontend/.env`:

```env
VITE_API_URL=http://localhost:5000/api
```

Untuk backend Docker, gunakan:

```env
VITE_API_URL=http://localhost:5001/api
```

## Flow Aplikasi

1. Register hanya meminta username, email, password.
2. Setelah register, user diarahkan ke login.
3. Login menyimpan JWT di cookie httpOnly dari backend.
4. Jika profile belum lengkap, user wajib ke `/onboarding`.
5. Setelah onboarding berhasil, user masuk Home.
6. Halaman dashboard lain dilindungi protected route.

## Endpoint Utama

Auth:
- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/me`
- `POST /api/auth/logout`

Profile:
- `GET /api/profile/me`
- `POST /api/profile/onboarding`
- `PUT /api/profile/me`

Activities:
- `GET /api/activities`
- `POST /api/activity-logs`
- `GET /api/activity-logs/me`

Endpoint activity dan progress mendukung query `?lang=en` atau `?lang=id`, misalnya `GET /api/activities?lang=id`.

Progress:
- `GET /api/progress/me`
- `GET /api/progress/rank-log`

Rankings:
- `GET /api/rankings`

Badges:
- `GET /api/badges/me`

Milestones:
- `GET /api/milestones/me`
