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
end
