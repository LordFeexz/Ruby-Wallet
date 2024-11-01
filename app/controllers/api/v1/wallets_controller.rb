module Api
  module V1
    class WalletsController < ApplicationController
      use Authenticator::Middleware

      def show
        render json: {
          data: Wallet.find_by(reference_id: request.env["user"].id, reference_type: "user")&.
          attributes.except("reference_type")
          },
          status: :ok
      end

      def create
        # assume this endpoint for topup wallet
        @params = topup_params
        payload = TopupProp.new(@params)

        unless payload.valid?
          render json: { message: "missing parameters" }, status: :bad_request
          return
        end

        status = :ok
        message = "ok"
        ActiveRecord::Base.transaction do
          begin
            wallet = Wallet.find_by(reference_id: request.env["user"].id, reference_type: "user")
            raise NotFoundError.new("wallet not found") if wallet.nil?

            wallet.balance += payload.amount
            raise InternalServerError.new("failed to update entity") unless wallet.save

            raise InternalServerError.new("failed to create entity") unless Transaction.new(
              amount: payload.amount,
              transaction_type: "debit",
              user_id: request.env["user"].id,
              context: {},
              description: "topup"
            ).save

          rescue HttpError => e
            status = e.status
            message = e.message
            raise ActiveRecord::Rollback
            return
          rescue => e
            puts e
            status = :internal_server_error
            message = e.message
            raise ActiveRecord::Rollback
            return
          end
        end
        render json: { message: message }, status: status
      end

      def topup_params
        params.permit(:amount)
      end
    end
  end
end
