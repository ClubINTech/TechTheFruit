#!/usr/bin/ruby -I../lib

$in = ARGV[0]
$out = ARGV[1]

require "Log"

Logger.instance.level = Logger::UNKNOWN

require "TestDecisions"
require "TestStrategie"
# require "TestInterfaceEvitement"
# require "TestInterfaceAsservissement"
