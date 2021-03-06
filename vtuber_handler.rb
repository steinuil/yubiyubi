require 'yaml'
require_relative 'lib/irc'

class VtuberHandler
  def initialize file
    @file = file
    reload_list
  end

  def reload_list
    @list = YAML.safe_load(File.read @file)
    @last_mtime = File.mtime(@file)
  end

  def handle msg
    return unless msg.command == "PRIVMSG" && msg.params[1].strip == "'chuuba"
    if File.mtime(@file) != @last_mtime
      reload_list
    end

    vtuber = @list.sample

    IRC::Protocol.privmsg(
      msg.params[0],
      if vtuber["agency"]
        "#{msg.prefix.nick}, your vtuber is #{vtuber["name"]} (#{vtuber["agency"]})"
      else
        "#{msg.prefix.nick}, your vtuber is #{vtuber["name"]}"
      end
    )
  end
end
