module Api
  module V1
    class TeamsController < ApplicationController
      include Pagination
      use Authenticator::Middleware

      def show
        render json: {
          data: Team
            .where(owner_id: request.env["user"].id)
            .limit(per_page).offset(paginate_offset),
          page: page_no,
          limit: per_page
          }, status: :ok
      end

      def detail
        team = Team.find_by(id: params[:id])
        if team.nil?
          render json: { message: "team not found" }, status: :not_found
          return
        end
        render json: { data: team }, status: :ok
      end

      def create
        @payload = CreateTeamProp.new(team_params)

        unless @payload.valid?
          render json: { message: "name #{@payload.errors[:name][0]}" }, status: :bad_request
          return
        end

        if Team.where(owner_id: request.env["user"].id).count >= AppConstant::MAX_TEAM_OWNED
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
