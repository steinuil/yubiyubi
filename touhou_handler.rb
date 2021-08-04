require 'yaml'
require_relative 'lib/irc'

class TouhouHandler
  def initialize file
    @file = file
    reload_list
  end

  def reload_list
    @list = YAML.safe_load(File.read @file)
    @last_mtime = File.mtime(@file)
  end

  def handle msg
    return unless msg.command == "PRIVMSG" && msg.params[1].strip == "'touhou"
    if File.mtime(@file) != @last_mtime
      reload_list
    end

    touhou = @list.sample

    IRC::Protocol.privmsg(
      msg.params[0],
      "#{msg.prefix.nick}, you found #{touhou}"
    )
  end
end
