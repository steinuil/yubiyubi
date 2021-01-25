require_relative 'lib/irc'

class MonkeHandler
  def initialize file
    @file = file
  end

  def reload_list
    @list = File.readlines @file, chomp: true
    p @list
    @last_mtime = File.mtime(@file)
  end

  def handle msg
    return unless msg.command == "PRIVMSG" && msg.params[1].strip == "'monke"
    if File.mtime(@file) != @last_mtime
      reload_list
    end

    video = @list.sample

    IRC::Protocol.privmsg(msg.params[0], video)
  end
end
