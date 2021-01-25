require 'socket'
require 'openssl'
require_relative 'message'

module IRC
  Config = Struct::new(
    :server,
    :port,
    :server_password,
    :nick,
    :username,
    :realname,
    :channels,
    :quit_message,
    keyword_init: true
  )

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

      send! Message::new("USER", [
          @config.username || @config.nick,
          '0', '*',
          @config.realname || @config.nick
      ])
      send! Message::new("PASS", [@config.server_password]) if @config.server_password
      send! Message::new("NICK", [@config.nick])
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
    rescue => e
      STDERR.puts e.inspect
    end

    def send! msg
      puts "< #{Time.now.to_s} #{msg.to_s}"
      @conn.syswrite(msg.to_s + "\r\n")
    end

    def login!
      send! Message::new("JOIN", [@config.channels.join(',')])

      @ping_thread = Thread.new do
        until @conn.closed?
          # TODO close the connection if the server hasn't responded
          send! Message::new("PING", [Time.now.to_i.to_s])
          sleep 120
        end
      end
    end

    def quit!
      send! Message::new("QUIT", [@config.quit_message].compact)
    end

    def handle msg
      puts "> #{Time.now.to_s} #{msg}"
      msg = Message.parse msg

      case msg.command
      when "PING"
        send! Message::new("PONG", msg.params)
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
