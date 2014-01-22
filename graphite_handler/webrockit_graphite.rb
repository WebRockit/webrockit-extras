#!/usr/bin/env ruby
require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-handler'
require 'socket'

class Webrockit < Sensu::Handler
  def filter; end

  def handle
    #fire up a udp socket and send this metric off
    s = UDPSocket.new

    #webrockit runner scripts return output seperated by  \n
    lines = @event['check']['output'].split("\n")
    lines.each do |line|

      # carve up the metric into usable parts
      metrics = line.split("\t")
      check_name = @event['check']['name']
      postfix = metrics[0]
      value = metrics[1]
      ts = metrics[2]

      #create the thing being sent to graphite
      prefix = settings['graphite']['prefix']
      message = "#{prefix}#{check_name}.#{postfix} #{value} #{ts}"

      #fire off to graphite server
      server = settings['graphite']['server']
      port = settings['graphite']['port']
      s.send(message, 0, server, port)
    end
  end
end
