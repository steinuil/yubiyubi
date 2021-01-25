require 'yaml'
require_relative 'connection'
require_relative 'ctcp_handler'
require_relative 'vtuber_handler'

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
    VtuberHandler.new(config['vtubers_path'])
  ]
)
conn.connect!
conn.listen
