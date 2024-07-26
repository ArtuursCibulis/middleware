class PaymentService
  def self.purchase(params)
    uri = URI.parse('https://api.example.com/paygate/auth')
    request = Net::HTTP::Post.new(uri)
    request.content_type = 'application/json'

    request.body = params.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end

    response.is_a?(Net::HTTPSuccess) ? JSON.parse(response.body) : {}
  end

  def self.check_payment_completion(params)
    query_params = {
      grantType: 'AuthorizationCode',
      od_id: params[:od_id],
      ref_trade_id: params[:ref_trade_id],
      ref_user_id: params[:ref_user_id],
      od_currency: 'KRW',
      od_price: params[:od_price]
    }
    uri = URI("https://api.example.com/paygate/check?#{query_params.to_query}")
    res = Net::HTTP.get_response(uri)

    res.is_a?(Net::HTTPSuccess) ? JSON.parse(res.body) : {}
  end

  def self.process_return(status)
    uri = URI.parse('http://testpayments.com/api/purchase/1')
    request = Net::HTTP::Put.new(uri)

    request.body = { status: status }.to_json

    Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end
  end
end
