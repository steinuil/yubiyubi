require_relative 'helper'
require 'minitest/autorun'

describe 'IRC::Message.parse' do
  it 'parses simple messages' do
    _(IRC::Message.parse(
      "PRIVMSG test :Testing!\r\n"
    )).must_equal(
      IRC::Message.new('PRIVMSG', ['test', 'Testing!'])
    )
  end

  it 'parses mssages without the trailing part' do
    _(IRC::Message.parse(
      "PRIVMSG test\r\n"
    )).must_equal(
      IRC::Message.new('PRIVMSG', ['test'])
    )
  end

  it 'parses messages with a nickname' do
    _(IRC::Message.parse(
      ":test!user@host PRIVMSG test :Still testing!\r\n"
    )).must_equal(
      IRC::Message.new(
        'PRIVMSG',
        ['test', 'Still testing!'],
        IRC::Message::Nickname.new('test', 'user', 'host')
      )
    )
  end

  it 'parses messages with tags' do
    _(IRC::Message.parse(
      "@aaa=bbb;ccc;example.com/ddd=eee :test!test@test PRIVMSG test :Testing with tags!\r\n"
    )).must_equal(
      IRC::Message.new(
        'PRIVMSG',
        ['test', 'Testing with tags!'],
        IRC::Message::Nickname.new('test', 'test', 'test'),
        {
          'aaa' => 'bbb',
          'ccc' => nil,
          'example.com/ddd' => 'eee'
        }
      )
    )
  end

  it 'parses messages with just one trailing param correctly' do
    _(IRC::Message.parse(
      "PRIVMSG :test"
    )).must_equal(
      IRC::Message.new("PRIVMSG", ["test"])
    )
  end
end

describe 'Message::to_s' do
  it 'serializes messages with tags and prefix' do
    _(
      IRC::Message.new(
        'PRIVMSG',
        ['test', 'Testing with tags!'],
        IRC::Message::Nickname.new('test', 'test', 'test'),
        {
          'aaa' => 'bbb',
          'ccc' => nil,
          'example.com/ddd' => 'eee'
        },
      ).to_s
    ).must_equal(
      "@aaa=bbb;ccc;example.com/ddd=eee :test!test@test PRIVMSG test :Testing with tags!"
    )
  end

  it 'always puts a colon before the last param' do
    _(
      IRC::Message.new(
        'PRIVMSG',
        ['Still testing!'],
        IRC::Message::Nickname.new('test', 'user', 'host'),
        nil
      ).to_s
    ).must_equal(
      ":test!user@host PRIVMSG :Still testing!"
    )
  end

  it "doesn't put a space at the end if there's no params" do
    _(
      IRC::Message.new(
        "PONG",
        [],
        nil,
        nil
      ).to_s
    ).must_equal(
      "PONG"
    )
  end
end

describe 'IRC::Message::Nickname::to_s' do
  it 'is serialized correctly' do
    _(
      IRC::Message::Nickname.new(
        "test",
        "user",
        "host"
      ).to_s
    ).must_equal("test!user@host")
  end
end
