module Api
  module V1
    class TransactionsController < ApplicationController
      include StandardResponse
      use Authenticator::Middleware

      def create
        @params = transaction_params

        payload = TransferProp.new(@params)
        unless payload.valid?
          standard_json_response("missing parameters", 400)
          return
        end

        to, amount, text = payload.values_at(:to, :amount, :text)
        if to == request.env["user"].id
          standard_json_response("cannot transfer to yourself", 400)
          return
        end

        code = 200
        message = "ok"
        ActiveRecord::Base.transaction do
          begin
            current_wallet = Wallet.find_by(reference_id: request.env["user"].id, reference_type: "user")
            raise NotFoundError.new("current wallet not found") if current_wallet.nil?

            raise BadRequestError.new("insufficient balance") if current_wallet.balance < amount

            target_wallet = Wallet.find_by(reference_id: to, reference_type: "user")
            raise NotFoundError.new("target wallet not found") if target_wallet.nil?

            current_wallet.balance -= amount
            target_wallet.balance += amount

            raise InternalServerError.new("failed to update entity") unless current_wallet.save && target_wallet.save

            [ "credit", "debit" ].each do |val|
              transaction = Transaction.new(
                amount: amount,
                transaction_type: val,
                description: val == "credit" ? text : nil,
                context: { from: session[:user_session_id], to: to },
                user_id: val == "credit" ? session[:user_session_id] : to
              )
              raise InternalServerError.new("failed to create entity") unless transaction.save
            end

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

      private

      def transaction_params
        params.permit(:to, :amount, :text)
      end
    end
  end
end