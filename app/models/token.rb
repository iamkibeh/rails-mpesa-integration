require 'dotenv/load'
require 'faraday'
require 'rest-client'
require "base64"
require "byebug"
require "json"
def generate_access_token_request
  @url = "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"
  @consumer_key = "eqf6I9l5P5AjDE4jF6tsElUqrRDoGgHT"
  @consumer_secret = "sMyU24Z24ZEgle5j"
  # puts @consumer_key
  @access_token = Base64.strict_encode64("#{@consumer_key}:#{@consumer_secret}")

  # byebug
  # puts @access_token
  @headers = { Authorization: "Basic #{@access_token}" }
  json_body = {
    username: @consumer_key,
    password: @consumer_secret
  }.to_json

  # res =
    # RestClient::Request.execute(
    #   url: @url,
    #   method: :post,
    #   headers: {
    #     Authorization: "Basic #{@access_token}"
    #   },
    #   body: {
    #     username: @consumer_key,
    #     password: @consumer_secret
    #   }

    # )

  conn = Faraday.new(url: @url)

  res = conn.post do |req|
    req.headers['Content-Type'] = 'application/json'
    req.headers['Authorization'] = "Basic #{@access_token}"
  end

  # res = conn.post(@url) do |req|
  #   req.headers['Content-Type'] = 'application/json'
  #   req.body = {
  #     username: @consumer_key,
  #     password: @consumer_secret
  #   }.to_json
  # end
  response_body = JSON.parse(res.body, symbolize_names: true)
  puts response_body

  # res.body
end

def get_access_token
  res = generate_access_token_request
  raise MpesaError("Error generating access token") if res.status != 200
  puts "here is the responce #{res.body}"
  # body = JSON.parse(res, symbolize_names: true)
  body = JSON.parse(res.body, symbolize_names: true)
  puts body
  token = body[:access_token]
  AccessToken.destroy_all
  AccessToken.create!(token: token)
  token
end

puts generate_access_token_request
