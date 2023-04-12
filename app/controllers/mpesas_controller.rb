require "rest-client"
require "base64"
# require "byebug"

class MpesasController < ApplicationController
  rescue_from SocketError, with: :OfflineMode

  # stk push functions
  def stkpush
    phone_number = params[:phoneNumber]
    amount = params[:amount]
    url = "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest"
    timestamp = "#{Time.now.strftime("%Y%m%d%H%M%S")}"
    business_short_code = ENV["MPESA_SHORTCODE"]
    password =
      Base64.strict_encode64(
        "#{business_short_code}#{ENV["MPESA_PASSKEY"]}#{timestamp}"
      )
    payload = {
      BusinessShortCode: business_short_code,
      Password: password,
      Timestamp: timestamp,
      TransactionType: "CustomerPayBillOnline",
      Amount: amount,
      PartyA: phone_number,
      PartyB: business_short_code,
      PhoneNumber: phone_number,
      CallBackURL: "#{ENV["MPESA_CALLBACK_URL"]}/callback_url",
      AccountReference: "ROR Mpesa",
      TransactionDesc: "ROR Mpesa"
    }.to_json
    # debugger
    headers = {
      content_type: "application/json",
      Authorization: "Bearer #{get_access_token}"
    }

    # send request

    response =
      RestClient::Request
        .new({ method: :post, url: url, payload: payload, headers: headers })
        .execute do |response, request|
          #   puts "Response code: #{response} is hcere"
          case response.code
          when 500
            [:error, JSON.parse(response.to_str)]
          when 400
            [:error, JSON.parse(response.to_str)]
          when 200
            [:success, JSON.parse(response.to_str)]
          else
            fail "Invalid response code #{response.to_str} received."
          end
        end
    # byebug

    # puts response

    render json: response
  end

  private

  def generate_access_token_request
    @url =
      "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"
    @consumer_key = ENV["MPESA_CONSUMER_KEY"]
    @consumer_secret = ENV["MPESA_CONSUMER_SECRET"]

    @access_token =
      Base64.strict_encode64("#{@consumer_key}:#{@consumer_secret}")

    # byebug

    # puts @access_token
    @headers = { Authorization: "Basic #{@access_token}" }

    res =
      RestClient::Request.execute(method: :get, url: @url, headers: @headers)
    # puts res
    res
  end

  def get_access_token
    res = generate_access_token_request()
    raise MpesaError("Error generating access token") if res.code != 200
    body = JSON.parse(res, symbolize_names: true)
    # puts body
    token = body[:access_token]
    AccessToken.destroy_all()
    AccessToken.create!(token: token)
    return token
  end

  def OfflineMode
    render json: { errors: ["You are Offline Do Connect to the Internet"] }
  end
end
