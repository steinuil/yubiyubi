module IRC
  Message = Struct.new(
    :command,
    :params,
    :prefix,
    :tags
  )

  class Message
    Nickname = Struct.new(:nick, :user, :host) do
      def to_s
        nick +
          (user ? ?! + user : '') +
          ?@ + host
      end
    end

    ServerName = Struct.new(:name) do
      def to_s
        name
      end
    end

    def self.parse line
      l = line.sub /\r?\n?$/, ''

      tags =
        if l.start_with? ?@
          t, l = l.split /\s+/, 2
          Hash[
            t[1..].split(?;).map do |tag|
              tag.split(?=, 2)
            end
          ]
        end

      prefix =
        if l.start_with? ?:
          p, l = l.split /\s+/, 2
          p, host = p[1..].split ?@, 2
          if host
            nick, user = p.split ?!, 2
            Nickname.new nick, user, host
          else
            ServerName.new p
          end
        end

      command, l = l.split /\s+/, 2
      l = ' ' + l

      trailing =
        if l.include? ' :'
          l, trailing = l.split ' :', 2
          [trailing]
        else
          []
        end

      params =
        if l.strip.empty?
          trailing
        else
          l.strip.split(/\s+/) + trailing
        end

      Message.new command, params, prefix, tags
    end

    def to_s
      out = ''

      if tags
        out += ?@
        out += tags.each.map do |k, v|
          if v then
            k + ?= + v
          else 
            k
          end
        end.join ';'
        out += ' '
      end

      if prefix
        out += ?:
        out += prefix.to_s
        out += ' '
      end

      out += command
      out += ' ' if params.size > 0

      if params.size > 1
        out += params[0..-2].join ' '
        out += ' :'
        out += params[-1]
      elsif params.size > 0
        out += ':'
        out += params[0]
      end

      out
    end
  end
end
