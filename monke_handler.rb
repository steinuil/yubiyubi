require_relative 'lib/irc'

class MonkeHandler
  def initialize file
    @file = file
    reload_list
  end

  def reload_list
    @list = File.readlines @file, chomp: true, encoding: "UTF-8"
    @last_mtime = File.mtime(@file)
  end

  def should_respond? msg
    msg.command == "PRIVMSG" && msg.params[1].strip == "'monke"
  end

  def handle msg
    return unless should_respond? msg
    if File.mtime(@file) != @last_mtime
      reload_list
    end

    video = @list.sample

    IRC::Protocol.privmsg(msg.params[0], video)
  end
end
