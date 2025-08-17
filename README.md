# SalaryPaymentFileExporter


## Description

**SalaryPaymentFileExporter** is a backend service for a payroll company. At 5:00 PM daily (configurable in ```config/export.yml``` or can be simulated via manual command ```bin/rails payments:export```) the system will:

- Select all pending payments where pay_date <= today
- Generate a .txt file with one line per payment, in the following format:
```
COMPANY_ID,EMPLOYEE_ID,BSB,ACCOUNT,AMOUNT_CENTS,CURRENCY,PAY_DATE
```

Example Output: 
```
abc123,emp001,062000,12345678,250000,AUD,2025-07-09 
abc123,emp002,082003,98765432,300000,AUD,2025-07-09 
```
After export: 
- Mark all included payments as exported 
- Save a reference to the exported file in the DB (Audit table or http://localhost:3000/audits)

## Quick setup with docker
### 1. Start the application
```bash
docker-compose build
docker-compose up
```

### 2. Example API Usage (with curl)

### Add a Company
```bash
curl -X POST http://localhost:3000/companies \
  -H "Content-Type: application/json" \
  -d '{"company": {"name": "abc_123"}}'
```

### get list of companies
```bash
curl http://localhost:3000/companies   
```

### Add an Employee
```bash
curl -X POST http://localhost:3000/employees \
  -H "Content-Type: application/json" \
  -d '{"employee": {"employee_id": "emp001", "name": "John Doe", "company_id": 1}}'
```

### Add Payments (batch)
```bash
curl -X POST http://localhost:3000/payments \
  -H "Content-Type: application/json" \
  -d '{
    "company_id": 1,
    "payments": [
      {
        "employee_id": "emp001",
        "bank_bsb": "062000",
        "bank_account": "12345678",
        "amount_cents": 250000,
        "currency": "AUD",
        "pay_date": "2025-08-19"
      }
    ]
  }'
```

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
- For scheduled exports, see crontab -l