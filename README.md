mq-benchmarks
=============

Source code used to benchmark a few messaging brokers.

This source code uses hard-coded port values for accessing brokers in [queue_tester/lib/queue_tester/engines](https://github.com/Muriel-Salvan/mq-benchmarks/tree/master/queue_tester/lib/queue_tester/engines) directory. Each plugin is defined in this directory.

It has been developped for a benchmark which results can be accessed [here](http://x-aeon.com/wp/2013/04/10/a-quick-message-queue-benchmark-activemq-rabbitmq-hornetq-qpid-apollo/).

## Components

### MessagingTest

Rails application that administrates messages to be enqueued or dequeued, and display operations performed on brokers.

Run as a normal Rails application:
``` bash
bundle install
rake db:migrate
rails s
```

### queue_tester

Command-line utility that enqueues/dequeues messages from/to a local MySQL database.
This utility is launched by the Rails application, but can also be launched manually. In both cases it will create reports in the database as operations.
It also communicates with the Rails application using websockets (therefore the Rails application has to be running prior to executing this utility).

Run using the Rails application, or by command line:
``` bash
ruby -Ilib bin/run.rb --engine ActiveMQ_STOMP --action enqueue --max_enqueue_nbr 10
```

### zmq_broker

Home-made ZeroMQ broker in memory.

Run from the command line:
``` bash
ruby bin/run.rb
```
