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