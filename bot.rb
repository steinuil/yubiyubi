require 'yaml'
require_relative 'lib/irc'
require_relative 'ctcp_handler'
require_relative 'vtuber_handler'
require_relative 'monke_handler'
require_relative 'waifu_handler'
require_relative 'touhou_handler'

config = YAML.safe_load(File.read(ARGV[0]))

conn = IRC::Connection.new(
  IRC::Config.new(
    server: config['server'],
    port: config['port'],
    nick: config['nick'],
    channels: config['channels'],
    quit_message: config['quit_message']
  ), [
    CtcpHandler.new,
    VtuberHandler.new(config['vtubers_path']),
    MonkeHandler.new(config['monke_path']),
    WaifuHandler.new,
    TouhouHandler.new(config['touhous_path'])
  ]
)
conn.connect!
conn.listen

trap 'INT' do
  conn.quit!
  exit
end
