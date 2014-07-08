require 'jumpstart_auth'
require 'klout'
require 'bitly'

Bitly.use_api_version_3

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing"
    @client = JumpstartAuth.twitter
    Klout.api_key = 'xu9ztgnacmjx3bu82warbr3h'
    @bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
  end

  def tweet(message)
    if message.length <= 140
      @client.update(message)
    else
      puts "Message is longer than 140 characters. Try again."
    end
  end

  def run
    puts "Welcome to the JSL Twitter Client!"
    all_friends_latest_tweets
    command = ""
    while command != "q"
      printf "enter command:"
      input = gets.chomp
      parts = input.split
      command = parts[0]
      case command
        when "q" then puts "goodbye!"
        when "t" then tweet(parts[1..-1].join(' '))
        when "dm" then dm(parts[1], parts[2..-1].join(' '))
        when "spam" then spam_my_followers(parts[1..-1].join(' '))
        when "turl" then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
        when "klout" then klout_scores
        else
          puts "Sorry, I don't know how to do #{command}."
      end
    end
  end

  def followers_list
    @client.followers.collect { |follower| follower.screen_name }
  end

  def dm(target, message)
    if followers_list.include?(target)
      puts "Sending #{target} a direct message."
      message = "d @#{target} #{message}"
      tweet(message)
    else
      puts "You cannot send a direct message to #{target} because they do not follow you."
    end
  end

  def spam_my_followers(message)
    followers_list.each do |follower|
      dm(follower, message)
    end
  end

  def all_friends
    @client.friends.sort_by { |friend| friend.screen_name.downcase }
  end

  def all_friends_latest_tweets
    all_friends.each do |friend|
      puts "#{friend.screen_name} said: #{friend.status.text} on #{friend.status.created_at.strftime("%A, %b %d")}"
    end
  end

  def shorten(original_url)
    shortened_url = @bitly.shorten('http://jumpstartlab.com/courses/').short_url
  end

  def klout_scores
    all_friends.collect { |friend| friend.screen_name }.each do |friend|
      identity = Klout::Identity.find_by_screen_name(friend)
      user = Klout::User.new(identity.id)
      puts "#{friend}'s Klout Score: #{user.score.score.round(2)}\n\n"
    end
  end
end

blogger = MicroBlogger.new
blogger.run
