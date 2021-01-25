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
      @ready = false
      @quit = false
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

      until @quit do
        handle @conn.gets
      end

      @conn.close unless @conn.closed?
    rescue => e
      STDERR.puts e.inspect
    end

    def send! msg
      puts "< #{msg.to_s}"
      @conn.puts msg.to_s
    end

    def login!
      send! Message::new("JOIN", [@config.channels.join(',')])
    end

    def quit!
      send! Message::new("QUIT", [@config.quit_message].compact)
      @quit = true
    end

    def handle msg
      puts "> #{msg}"
      msg = Message.parse msg

      case msg.command
      when "PING"
        send! Message::new("PONG", msg.params)
      when "376", "422"
        @ready = true
        login!
      end

      @handlers.each do |handler|
        resp = handler.handle msg
        send! resp if resp.is_a?(Message)
      rescue => e
        STDERR.puts e
      end
    end

    #def handle_ctcp msg
    #  msg = msg[1..].sub("\001$", '')
    #  cmd, params = msg.split ' ', 2
    #end
  end
end
