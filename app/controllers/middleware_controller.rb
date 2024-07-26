require 'net/http'
require 'uri'
require 'json'

class MiddlewareController < ApplicationController
  def purchase
    results = PaymentService.purchase(purchase_params)

    if results['resultCode'] == '100'
      render json: { accessToken: results['accessToken'], od_id: results['od_id'] }, status: :ok
    else
      render json: { error: results['Error'] }, status: :internal_server_error
    end
  end

  def returns
    payment_completion_data = PaymentService.check_payment_completion(returns_params.to_h)
    PaymentService.process_return(payment_completion_data['resultCode'] == '100' ? 'paid' : 'failed')

    redirect_to "#{returns_params[:return_url]}?#{redirect_params.to_query}", allow_other_host: true
  end

  private

  def returns_params
    params.permit(:od_id, :ref_trade_id, :ref_user_id, :od_currency, :od_price, :od_tno, :od_status, :api_result_send, :api_result_send_date, :resultCode, :return_url)
  end

  def purchase_params
    params.permit(:ref_trade_id, :ref_user_id, :od_currency, :od_price, :return_url)
  end

  def redirect_params
    returns_params.except(:return_url)
  end
end
