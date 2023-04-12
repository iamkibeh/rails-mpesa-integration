require "rest-client"
require "base64"
require "byebug"
def generate_access_token_request
  @url =
    "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"
  @consumer_key = ENV["MPESA_CONSUMER_KEY"]
  @consumer_secret = ENV["MPESA_CONSUMER_SECRET"]
  puts @consumer_key
  @access_token = Base64.strict_encode64("#{@consumer_key}:#{@consumer_secret}")
  # byebug
  # puts @access_token
  @headers = { Authorization: "Bearer #{@access_token}" }

  res =
    RestClient::Request.execute(
      url: @url,
      method: :get,
      headers: {
        Authorization: "Basic #{@access_token}"
      }
    )

  res
end

def get_access_token
  res = generate_access_token_request
  raise MpesaError("Error generating access token") if res.status != 200
  body = JSON.parse(res, symbolize_names: true)
  puts body
  token = body[:access_token]
  AccessToken.destroy_all
  AccessToken.create!(token: token)
  byebug
  token
end
puts generate_access_token_request
