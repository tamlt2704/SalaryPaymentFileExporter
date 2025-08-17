# SalaryPaymentFileExporter

## Requirements

- Ruby 3.x
- Rails 8.x
- PostgreSQL (for development and production)
- Docker & Docker Compose (optional, recommended)

## Setup

### 1. Clone the repository

```bash
git clone <repo_url>
cd SalaryPaymentFileExporter
```

### 2. Install dependencies

```bash
bundle install
```

### 3. Database setup

#### Using Docker (recommended)

Start PostgreSQL and the Rails app:

```bash
docker run --name my-postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_USER=postgres -e POSTGRES_DB=salary_payment_development -p 5432:5432 -d postgres:16
```

#### Or manually

- Ensure PostgreSQL is running.

#### Create and migrate the database:

```bash
bin/rails db:create
bin/rails db:migrate
```

### 4. Initialize data (optional)

```bash
bin/rails companies:init
bin/rails employees:init
bin/rails payments:init
```

### 5. Run the application

```bash
bin/rails server -b 0.0.0.0
```

Visit [http://localhost:3000](http://localhost:3000).

## Running Tests

```bash
bin/rails test
```

## Useful Rake Tasks

- Export payments:  
  ```bash
  bin/rails payments:export
  ```

## API Endpoints

- `GET /companies` — List companies
- `GET /employees` — List employees
- `GET /audits` — List audit exports
- `POST /payments` — Create payments

## Notes

- Default export files are saved in the `outbox` directory.
- You can configure export settings in `config/export.yml`.
- For scheduled exports, see the Sidekiq or cron job configuration.
