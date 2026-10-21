# Pl Webpage

Rails 7.2 app with PostgreSQL, Hotwire, and Tailwind CSS v4.

## Requirements

- Ruby (see `.ruby-version`)
- Bundler
- Docker (for local PostgreSQL)

## First-time setup

```bash
bundle install
docker compose up -d db    # or let bin/dev start it
bin/setup                   # creates DB, runs migrations
bin/dev                     # starts Postgres (if needed) + Rails + Tailwind
```

Open http://localhost:3000

## Development database

PostgreSQL runs in Docker via [`docker-compose.yml`](docker-compose.yml).

| Setting  | Default   |
|----------|-----------|
| Host     | `127.0.0.1` |
| Port     | `5432`    |
| User     | `postgres` |
| Password | `postgres` |
| DB (dev) | `pl_webpage_development` |

Copy [`.env.example`](.env.example) to `.env` if you need to override connection settings.

### Useful commands

```bash
docker compose up -d        # start PostgreSQL in background
docker compose down         # stop containers (data kept in volume)
docker compose logs db      # view PostgreSQL logs
bin/rails db:prepare        # create/migrate databases
bin/rails db:seed           # load demo data
```

### Auto-start on boot

The compose service uses `restart: unless-stopped`. After the first `docker compose up -d`, PostgreSQL restarts when the Docker daemon starts. Enable Docker at boot:

```bash
sudo systemctl enable --now docker
```

`bin/dev` runs `docker compose up -d db` and waits for Postgres before starting Rails.

### Migrating from the old standalone container

If you previously used `docker run --name pl_webpage_postgres ...`:

```bash
docker stop pl_webpage_postgres
docker rm pl_webpage_postgres
docker compose up -d db
bin/rails db:prepare
```

Compose uses a named volume (`postgres_data`) for persistence.

### Docker permissions

If `docker compose` fails without `sudo`, add your user to the `docker` group:

```bash
sudo usermod -aG docker "$USER"
newgrp docker
```

`bin/dev` retries with `sudo` if the first attempt fails.

## Tests

```bash
docker compose up -d db
RAILS_ENV=test bin/rails db:prepare
bundle exec rspec
```

## CI

GitHub Actions runs its own PostgreSQL service; no Docker Compose required in CI.

## Production (Render + Supabase)

The app ships with a [`render.yaml`](render.yaml) blueprint for [Render](https://render.com):

- **Web service**: Docker image from [`Dockerfile`](Dockerfile), health check at `/up`.
- **Database**: [Supabase](https://supabase.com) PostgreSQL. Prefer the **Session pooler** URI (port `5432`) in `DATABASE_URL` so `db:prepare` / migrations work on deploy; the Transaction pooler (`6543`) can break migrations.
- **Uploaded files**: Render **persistent disk** mounted at `/rails/storage` (Active Storage `local` service in production).

### Render environment variables

| Variable | Required | Notes |
|----------|----------|--------|
| `DATABASE_URL` | Yes | Supabase pooler URL (`?sslmode=require` is usually included) |
| `RAILS_MASTER_KEY` | Yes | Contents of `config/master.key` |
| `SECRET_KEY_BASE` | Yes | Can use Render’s generated value |
| `APP_HOST` | Recommended | Public hostname (custom domain or `*.onrender.com`) for mailer URLs and host authorization |
| `SEED_TECHNICAL_ADMIN_EMAIL` | For first deploy | Creates the initial technical admin when running `db:seed` |
| `SEED_TECHNICAL_ADMIN_PASSWORD` | For first deploy | Strong password for that account |

`preDeployCommand` runs `db:prepare` and `db:seed`. Production seeds load only reference data (regions, communes, topics, training categories) and optionally the technical admin—no demo news or users.

### Deploy steps

1. Create a Supabase project and note the pooled `DATABASE_URL`.
2. In Render, **New → Blueprint** and point at this repo (or create a Web Service manually with the same settings as `render.yaml`).
3. Set the env vars above; attach a 1 GB disk at `/rails/storage`.
4. Deploy. Sign in with the seeded technical admin, then create moderators via the admin panel.

### Roles and documents

- New registrations are always **simpatizante** (`sympathizer`).
- Training materials can be marked **visible para simpatizantes**; otherwise only militantes and higher roles can open or download them.
- **Moderadores** manage roles under `/moderation/users` (simpatizante, militante, directiva, moderador).
