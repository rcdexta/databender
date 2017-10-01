# databender

Ruby script to generate a database subset driven by configuration based rule-engine

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

#### Documentation



#### License

MIT