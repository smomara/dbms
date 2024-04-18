# dbms - DataBase Management System

## Description

In-progress project.

Currently only supports basic commands such as `insert` to add data, `select` to view data, and `.exit` to exit the program.

Very minimalist right now and only hands insertions with an ID, username, and email.

## Installation

### Build

To buld the database executeable, use `make`:

```bash
make db
```
### Usage

To run the database:

```bash
./db <name>.db
```

You will be prompted to input commands. Currenlty supported commands are:
* `insert <id> <username> <email>`: Inserts a new row with the specified data
* `select`: Displays all rows in the database.
* `.exit`: Exits the databse program.

## Testing

### Setup Tests

To set up RSpec tests (make sure RSpec is installed):

```bash
rspec --init
```

### Run Tests

To run the tests, execute:

```bash
rspec
```

This will run the tests defined in the `spec/` directory.