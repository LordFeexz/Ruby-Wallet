module Api
  module V1
    class TransactionController < ApplicationController
      use Authenticator::Middleware

      def create
        @params = transaction_params

        payload = TransferProp.new(@params)
        unless payload.valid?
          render json: { message: "missing parameters" }, status: :bad_request
          return
        end

        to, amount, text = payload.values_at(:to, :amount, :text)
        if to == request.env["user"].id
          render json: { message: "cannot transfer to yourself" }, status: :bad_request
          return
        end

        status = :ok
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

      def topup
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
              transaction_type: "credit",
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

      private

      def transaction_params
        params.permit(:to, :amount, :text)
      end

      def topup_params
        params.permit(:amount)
      end
    end
  end
end
