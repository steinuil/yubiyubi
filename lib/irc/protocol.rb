require_relative 'message'

module IRC
  module Protocol
    def self.ping srv1, srv2 = nil
      Message::new "PING", [srv1, srv2].compact
    end

    def self.pong srv1, srv2 = nil
      Message::new "PONG", [srv1, srv2].compact
    end

    def self.nick nick
      Message::new "NICK", [nick]
    end

    def self.pass password
      Message::new "PASS", [password]
    end

    def self.user username, realname
      Message::new "USER", [username, "0", "*", realname]
    end

    def self.oper name, password
      Message::new "OPER", [name, password]
    end

    def self.quit msg = nil
      Message::new "QUIT", [msg].compact
    end

    def self.join channel, key = nil
      Message::new "JOIN", [channel, key].compact
    end

    def self.join_many channels
      if channels.is_a? Hash
        channels, keys = channels.to_a.sort_by { |_, v| v || "" }.reverse.transpose
        Message::new "JOIN", [channels.join(","), keys.compact.join(",")]
      elsif channels.is_a? Array
        Message::new "JOIN", [channels.join(",")]
      else
        raise ArgumentError.new("Expected a Hash or Array, got #{channels}")
      end
    end

    def self.part ch, reason = nil
      ch =
        if ch.is_a? Array
          ch.join ","
        elsif ch.is_a? String
          ch
        else
          raise ArgumentError.new("Expected a String or Array, got #{ch}")
        end

      Message::new "PART", [ch, reason].compact
    end

    def self.part_all
      Message::new "JOIN", ["0"]
    end

    def self.topic topic = nil
      Message::new "TOPIC", [topic].compact
    end

    def self.names *ch
      Message::new "NAMES", [ch.join(",")]
    end

    def self.list *ch
      Message::new("LIST", ch.empty ? [] : [ch.join(",")])
    end

    def self.invite nick, channel
      Message::new "INVITE", [nick.to_s, channel]
    end

    def self.privmsg target, text
      Message::new "PRIVMSG", [target.to_s, text]
    end

    def self.notice target, text
      Message::new "NOTICE", [target.to_s, text]
    end

    def self.version target = nil
      Message::new "VERSION", [target].compact
    end

    def self.away reason = nil
      Message::new "AWAY", [reason].compact
    end

    module CTCP
      DELIM = "\001"

      def self.send target, text
        Message::new "PRIVMSG", [target.to_s, DELIM + text + DELIM]
      end

      def self.respond target, text
        Message::new "NOTICE", [target.to_s, DELIM + text + DELIM]
      end
    end
  end
end
