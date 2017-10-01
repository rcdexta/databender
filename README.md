# Databender

Ruby script to generate a database subset driven by configuration based rule-engine

#### Demo

![alt tag](https://github.com/rcdexta/databender/raw/master/assets/demo.gif)

#### Why

If you have to quickly boot up a micro-service or any application in your local machine and you are stuck because the service has dependent seed data that needs to be present in the database before starting up, you have couple options:

* automate data generation using tools like [bobcat](https://github.com/ThoughtWorksStudios/bobcat)
* use the fixtures that power your testing suite to generate the seed data
* generate a subset of the data from one of the working environments (staging, uat)

Databender aims to offer an easy and seamless solution to solve the last option.

#### Features

* configuration driven rule engine
* can add filters at table level or globally at column level
* can resolve sequence of tables to import based on referential integrity (foreign key dependencies)

#### Installation

Install the gem to install the command-line cli

```bash
$ gem install databender
```

and the type 

```shell
$ databender --help
```

to know the list of available commands.

#### Usage

First initialise the configuration for the database you would like to take a subset of

```powershell
$ databender init --db-name=employees
```

> Note: I have taken the MySQL public dataset available here: https://github.com/datacharmer/test_db as the sample dataset to illustrate the gem

This should create a `config` folder and a `database.yml` file. Specify the connection params to the source database in `database.yml` file. Inspect `filters/employees.yml`  to specify the rules for generating the subset. The comments in the file should serve as good documentation to specify the table and column filters. Find a sample filter configuration below.

```yaml
tables:
  # Tables with rows lesser than min_row_count will be fully imported with no filters applied
  min_row_count: 20

  # For tables with no filters, the maximum number of rows to import
  max_row_count: 1000

  # specify table specific filters here
  filters:
    employees: hire_date >= '1994-01-01'
    departments: dept_name in ('d004', 'd005')

columns:
  # specify column filters applicable to all tables that contain that column
  filters:
    birth_date: birth_date >= '1950-01-01'

```

Now you can run the generator using

```shell
$ databender generate --db-name=employees
```

This should generate another database called `employees_subset` with the subset data and also create a dump of the file gzipped.


#### License

MIT