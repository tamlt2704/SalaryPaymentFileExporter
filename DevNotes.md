# 1. Init

## 1.1 Generate project
```bash
rails new project_name --api
```

## 1.2 Run server
```bash
rails server -b 0.0.0.0
```

# 2. Create company model
```bash
rails generate model Company name:string
./bin/rails db:migrate

#db is stored in storage/development.sqlite3
```