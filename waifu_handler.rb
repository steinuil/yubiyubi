require_relative "lib/irc"

class WaifuHandler
  def should_respond? msg
    msg.command == "PRIVMSG" &&
      msg.params[1].strip == "'waifu"
  end

  def handle msg
    return unless should_respond? msg
    IRC::Protocol.privmsg(msg.params[0], "#{msg.prefix.nick}, you're waifu is shit")
  end
end
