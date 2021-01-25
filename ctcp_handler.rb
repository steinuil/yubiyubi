require_relative 'lib/irc'

class CtcpHandler
  def is_ctcp msg
    msg.command == "PRIVMSG" &&
      msg.params[1][0] == IRC::Protocol::CTCP::DELIM &&
      msg.prefix.is_a?(IRC::Message::Nickname)
  end

  def handle msg
    return unless is_ctcp msg

    m = msg.params[1][1..]
    m = m[0..-2] if m.end_with? IRC::Protocol::CTCP::DELIM

    command, rest = m.split ' ', 2
    resp = handle_ctcp command, rest
    if resp
      IRC::Protocol::CTCP.respond(msg.prefix.nick, resp)
    end
  end

  def handle_ctcp command, msg
    case command
    when "ACTION"
    when "CLIENTINFO"
      "CLIENTINFO ACTION CLIENTINFO PING SOURCE TIME VERSION"
    when "PING"
      "PING #{msg}"
    when "SOURCE"
      "SOURCE https://github.com/steinuil/yubiyubi"
    when "TIME"
      "TIME #{Time.now.strftime("%a, %d %b %Y %H:%M:%S %z")}"
    when "VERSION"
      "VERSION yubiyubi #{IRC::VERSION}"
    end
  end
end
