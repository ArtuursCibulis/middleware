require 'rails_helper'

RSpec.describe '/api/purchase', type: :request do
  let(:params) { { ref_trade_id: '1', ref_user_id: '1', od_currency: 'KRW', od_price: '100', return_url: 'https://exampleurl.com' } }

  context 'successful response' do
    before do
      stub_request(:post, 'https://api.example.com/paygate/auth').with(body: params.to_json)
        .to_return(status: 200, body: { resultCode: '100', accessToken: 'accessToken', od_id: '1' }.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns an accessToken and od_id' do
      post("/api/purchase", params: params)
      expect(status).to eq 401
      post("/api/purchase", headers: { 'Authorization' => 'Token secret' }, params: params)

      expect(status).to eq 200
      expect(JSON.parse(response.body)).to eq({"accessToken"=>"accessToken", "od_id"=>"1"})
    end
  end

  context 'unsuccessful response' do
    before do
      stub_request(:post, 'https://api.example.com/paygate/auth').with(body: params.to_json)
        .to_return(status: 200, body: { resultCode: 'Failure', Error: 'Something went wrong' }.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns an error message' do
      post("/api/purchase", params: params)
      expect(status).to eq 401
      post("/api/purchase", headers: { 'Authorization' => 'Token secret' }, params: params)

      expect(status).to eq 500
      expect(JSON.parse(response.body)).to eq({'error'=>'Something went wrong'})
    end
  end
end
