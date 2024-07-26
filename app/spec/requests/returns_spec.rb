require 'rails_helper'

RSpec.describe '/customer/returns', type: :request do
  let(:params) do
    {
      od_id: '1',
      ref_trade_id: '1',
      ref_user_id: '1',
      od_currency: 'KRW',
      od_price: '100',
      od_tno: '123',
      od_status: '10',
      api_result_send: '1',
      api_result_send_date: '24.07.2024',
      resultCode: '100',
      return_url: 'https://exampleurl.com'
    }
  end

  context 'payment completion successful' do
    before do
      stub_request(:get, 'https://api.example.com/paygate/check').with(query: params.slice(:od_id, :ref_trade_id, :ref_user_id, :od_currency, :od_price).merge(grantType: 'AuthorizationCode'))
        .to_return(status: 200, body: { resultCode: '100', Msg: 'OK' }.to_json)

      stub_request(:put, 'http://testpayments.com/api/purchase/1').with(body: { status: 'paid' }.to_json)
    end

    it 'sends request to the partner with status = paid' do
      post("/customer/returns", params: params)
      expect(status).to eq 401

      post("/customer/returns", headers: { 'Authorization' => 'Token secret' }, params: params)

      expect(WebMock).to have_requested(:put, 'http://testpayments.com/api/purchase/1').with(body: { status: 'paid' }.to_json)

      expect(response.location).to eq "#{params.delete(:return_url)}?#{params.to_query}"
    end
  end

  context 'payment completion not successful' do
    before do
      stub_request(:get, 'https://api.example.com/paygate/check').with(query: params.slice(:od_id, :ref_trade_id, :ref_user_id, :od_currency, :od_price).merge(grantType: 'AuthorizationCode'))
        .to_return(status: 200, body: { resultCode: 'Failure', Msg: 'Something went wrong' }.to_json)

      stub_request(:put, 'http://testpayments.com/api/purchase/1').with(body: { status: 'failed' }.to_json)
    end

    it 'sends request to the partner with status = failed' do
      post("/customer/returns", params: params)
      expect(status).to eq 401

      post("/customer/returns", headers: { 'Authorization' => 'Token secret' }, params: params)

      expect(WebMock).to have_requested(:put, 'http://testpayments.com/api/purchase/1').with(body: { status: 'failed' }.to_json)

      expect(response.location).to eq "#{params.delete(:return_url)}?#{params.to_query}"
    end
  end
end
