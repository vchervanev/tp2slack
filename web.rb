# frozen_string_literal: true

require 'sinatra'
require 'dotenv'

require_relative 'tpclient'
require_relative 'slack_message_escaper'

Dotenv.load

post '/parse' do
  return if ENV['SECURITY_TOKEN'] != params[:token]
  return if params[:user_id] == 'USLACKBOT'
  puts "channel:#{params['channel_id']} service:#{params['service_id']}"

  loader = TPClient.from_env.method(:retrieve).to_proc
  formatter = ->(info) do
    link = "<#{info.url}|#{info.id}>"
    description = SlackMessageEscaper.escape("#{info.type} of #{info.owner} - #{info.name}")

    "#{link}: #{description}"
  end

  text = params[:text]
     .scan(/\bTP(\d{4,})\b/i)
     .uniq()
     .tap { |ids| puts "numbers:#{ids.size} min:#{ids.min} max:#{ids.max}"}
     .map(&loader)
     .reject(&:nil?)
     .map(&formatter)
     .join("\n")

  response = text.empty? ? {} : {text: text}

  response.to_json
end