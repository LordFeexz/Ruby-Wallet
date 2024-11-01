module Api
  module V1
    class TeamsController < ApplicationController
      use Authenticator::Middleware

      def create
        @payload = CreateTeamProp.new(team_params)

        unless @payload.valid?
          render json: { message: "name #{@payload.errors[:name][0]}" }, status: :bad_request
          return
        end

        if Team.where(owner_id: request.env["user"].id).count >= 10
          render json: { message: "maximum number of teams reached" }, status: 409
          return
        end

        status = :created
        message = "created"

        ActiveRecord::Base.transaction do
          begin
            team = Team.new(name: @payload.name, owner_id: request.env["user"].id)
            raise InternalServerError.new("failed to create entity") unless team.save

            raise InternalServerError.new("failed to create entity") unless TeamMember.new(
              team_id: team.id,
              user_id: request.env["user"].id,
              role: 0
            ).save

          rescue HttpError => e
            status = e.status
            message = e.message
            raise ActiveRecord::Rollback
            return
          rescue => e
            status = :internal_server_error
            message = e.message
            raise ActiveRecord::Rollback
            return
          end
        end

        render json: { message: message }, status: status
      end

      private

      def team_params
        params.permit(:name)
      end
    end
  end
end
