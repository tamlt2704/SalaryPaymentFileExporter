# 1. Init

## 1.1 Generate project
```bash
rails new project_name --api
```

## 1.2 Run server
```bash
rails server -b 0.0.0.0
```

# 2. company model
## 2.1 Create model
```bash
rails generate model Company name:string
./bin/rails db:migrate

#db is stored in storage/development.sqlite3
```

## 2.2 run test
```bash
./bin/rails test
```

# 3. Payment model
rails generate model Payment company:references employee_id:string bank_bsb:string bank_account:string amount_cents:integer currency:string pay_date:date status:integer

# 4. test controller
```bash
curl -X POST http://localhost:3000/payments \
  -H "Content-Type: application/json" \
  -d '{
    "company_id": "abc123",
    "payments": [
      {
        "employee_id": "emp001",
        "bank_bsb": "062000",
        "bank_account": "12345678",
        "amount_cents": 250000,
        "currency": "AUD",
        "pay_date": "2026-01-01"
      }
    ]
  }'
```


# 5. rake tasks 
```bash
./bin/rails --tasks
rake payments:export
```

# 6. 
```bash

#init
bundle exec wheneverize .
whenever --update-crontab

#verify the crontab
crontab -l

# remove crontab
crontab -r

```

# 7. docker compose up
```bash

docker run --name my-postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_USER=postgres -e POSTGRES_DB=salary_payment_development -p 5432:5432 -d postgres:16

# init list of companies
bin/rails companies:init

docker-compose up
```