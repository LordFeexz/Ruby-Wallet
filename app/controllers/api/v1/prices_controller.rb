require_relative "../../../../../Ruby-Wallet/lib/latest_stock_price.rb"

module Api
  module V1
    class PricesController < ApplicationController
      def show
        latest_stock_price = LatestStockPrice.instance

        begin
          standard_json_response("ok", 200, latest_stock_price.price_all)
        rescue => e
          standard_json_response(e&.message || "something went wrong", e&.status_code || 500)
        end
      end
    end
  end
end
