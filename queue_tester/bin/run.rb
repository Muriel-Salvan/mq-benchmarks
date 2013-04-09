#!env ruby
#--
# Copyright (c) 2013 Muriel Salvan (muriel@x-aeon.com)
# Licensed under the terms specified in LICENSE file. No warranty is provided.
#++

# Main file
# Can be invoked by command line: results will still be updated in the Rails application.

require 'queue_tester/launcher'

QueueTester::Launcher.new.execute(ARGV)

exit 0
