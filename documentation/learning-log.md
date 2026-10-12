# FundTracker Rails — Learning Log

## 12 October 2026 — Rails Project Structure, Database Design and Authentication

### 1. Project Setup and Git

What I studied:
- How to maintain separate Git repositories for my Django and Ruby on Rails projects.
- How `git add`, `git commit`, `git push`, Git branches and Git remotes work.
- Why meaningful commit messages and regular documentation are important when developing a project.

What I implemented:
- Created a separate Git repository for FundTracker Rails.
- Made an initial commit and pushed the Rails project to GitHub.
- Moved the Rails project outside the Django project directory to keep the projects independent.

### 2. Understanding the Rails MVC Structure

What I studied:
- How Rails separates models, views and controllers.
- The difference between Django views and Rails controllers.
- How `config/routes.rb` maps URLs and HTTP requests to controller actions.
- Why separating responsibilities makes an application easier to maintain.

What I implemented:
- Organised the dashboard logic into a dashboard controller and a dashboard overview service.
- Created separate controllers for members, installments, payments and collection periods.
- Added routes for the corresponding fund management operations.

### 3. Active Record Models and Database Migrations

What I studied:
- The difference between an Active Record model and a database migration.
- How Rails uses migrations to create tables, columns, foreign keys and indexes.
- How model associations represent relationships between database records.
- Why database constraints are important for maintaining data integrity.

What I implemented:
- Created models for members, installments, payments and collection periods.
- Added associations between users, members, installments and payments.
- Configured decimal columns with precision and scale for monetary amounts.
- Added unique indexes to prevent duplicate member IDs within a user's account, duplicate monthly installments, duplicate collection periods and multiple payments for one installment.
- Ran the Rails database migrations successfully.

### 4. Password Authentication

What I studied:
- How Rails' `has_secure_password` uses BCrypt to hash passwords and verify login credentials.
- Why passwords should not be stored in plain text.
- How sessions can identify a logged-in user across requests.
- How `Current.user` can make the current user available to application components.
- Why protected controllers must check whether a user is authenticated.

What I implemented:
- Added the BCrypt dependency.
- Configured the User model for secure password handling.
- Implemented login, registration and logout controller actions.
- Added session handling and a helper to redirect unauthenticated users.
- Investigated and resolved a Ruby syntax error and a BCrypt loading error.

### 5. Debugging and Problem Solving

What I learned:
- How to read Rails error pages and use terminal commands to investigate application problems.
- How to check Ruby syntax, inspect routes, verify installed dependencies and inspect database columns.
- Why code examples must be copied without presentation-only formatting.
- Why a Rails server may need to be restarted after changes to its dependency environment.

### 6. Current Status and Next Steps

- The Rails database migrations have run successfully.
- The registration page loads after resolving the BCrypt loading error.
- The dashboard service and fund management controllers have been structured.
- The complete registration, login and logout flow still needs end-to-end testing.
- The dashboard queries, forms, model associations and fund management operations need to be verified together.
- The next step is to test authentication, connect the dashboard service to the models, and verify member, installment and payment operations.