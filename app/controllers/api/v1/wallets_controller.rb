module Api
  module V1
    class WalletsController < ApplicationController
      include StandardResponse
      use Authenticator::Middleware

      def show
        standard_json_response(
          "ok",
          200,
          Wallet.find_by(reference_id: request.env["user"].id, reference_type: "user")&.attributes.except("reference_type")
          )
      end

      def create
        # assume this endpoint for topup wallet
        @params = topup_params
        @payload = TopupProp.new(@params)

        unless @payload.valid?
          render json: { message: "missing parameters" }, status: :bad_request
          return
        end

        code = 200
        message = "ok"
        ActiveRecord::Base.transaction do
          begin
            wallet = Wallet.find_by(reference_id: request.env["user"].id, reference_type: "user")
            raise NotFoundError.new("wallet not found") if wallet.nil?

            wallet.balance += @payload.amount
            raise InternalServerError.new("failed to update entity") unless wallet.save

            raise InternalServerError.new("failed to create entity") unless Transaction.new(
              amount: @payload.amount,
              transaction_type: "debit",
              user_id: request.env["user"].id,
              context: {},
              description: "topup"
            ).save

          rescue HttpError => e
            code = e.status_code
            message = e.message
            raise ActiveRecord::Rollback
            return
          rescue => e
            code = 500
            message = e.message
            raise ActiveRecord::Rollback
            return
          end
        end
        standard_json_response(message, code)
      end

      def topup_params
        params.permit(:amount)
      end
    end
  end
end
