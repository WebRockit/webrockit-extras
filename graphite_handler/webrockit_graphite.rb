#!/usr/bin/env ruby
require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-handler'
require 'socket'
require 'timeout'

class Webrockit < Sensu::Handler
  def filter; end

  def handle

    #give the user the option to do udp vs tcp
    if settings['graphite']['protocol'] == 'tcp'
      s = TCPSocket.new(settings['graphite']['server'], settings['graphite']['port'])
    else
      #fire up a udp socket and send this metric off
      s = UDPSocket.new
    end

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
      message = "#{prefix}.#{check_name}.#{postfix} #{value} #{ts}"

      if settings['graphite']['protocol'] == 'tcp'
        timeout(3) do
          s.puts message
          s.flush
        end
      else
        #fire off to graphite server
        server = settings['graphite']['server']
        port = settings['graphite']['port']
        s.send(message, 0, server, port)
      end
    end

    if settings['graphite']['protocol'] == 'tcp'
      s.close
    end

  end
end
