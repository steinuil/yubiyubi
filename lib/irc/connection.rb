require 'socket'
require 'openssl'
require_relative 'message'
require_relative 'protocol'
require_relative 'config'

module IRC
  class Connection
    def initialize config, handlers
      @config = config
      @handlers = handlers
    end

    def connect!
      sock = TCPSocket.new(@config.server, @config.port)
      sock.sync = true
      @conn = OpenSSL::SSL::SSLSocket.new(sock).connect
      @conn.sync_close = true
      @conn.sync = true

      send! Protocol.user(
        @config.username || @config.nick,
        @config.realname || @config.nick
      )
      send! Protocol.pass @config.server_password if @config.server_password
      send! Protocol.nick @config.nick
    end

    def listen
      raise unless @conn

      trap :SIGINT do
        quit!
      end

      loop do
        resp = @conn.gets
        break unless resp
        handle resp
      end

      @conn.close unless @conn.closed?
      @ping_thread.kill if @ping_thread
    end

    def send! msg
      puts "< #{Time.now.to_s} #{msg.to_s}"
      @conn.syswrite(msg.to_s + "\r\n")
    end

    def login!
      send! Protocol.join_many @config.channels

      @ping_thread = Thread.new do
        until @conn.closed?
          # TODO close the connection if the server hasn't responded
          send! Protocol.ping Time.now.to_i.to_s
          sleep 120
        end
      end
    end

    def quit!
      send! Protocol.quit @config.quit_message
    end

    def handle msg
      puts "> #{Time.now.to_s} #{msg}"
      msg = Message.parse msg

      case msg.command
      when "PING"
        send! Protocol.pong *msg.params
      when "376", "422"
        login!
      end

      @handlers.each do |handler|
        resp = handler.handle msg
        send! resp if resp.is_a?(Message)
      rescue => e
        STDERR.puts e
      end
    end
  end
end
