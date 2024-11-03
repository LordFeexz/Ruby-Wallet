Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :api do
    namespace :v1 do
      scope "auth" do
        post "sign", to: "auths#sign"
        post "signout", to: "auths#signout"
      end

      scope "team-member" do
        post ":id", to: "team_members#join"
        delete ":id", to: "team_members#leave"
      end

      resource :transaction, only: [ :create ]

      resource :wallet, only: [ :create, :show ]

      resource :team, only: [ :create, :show, :destroy ] do # i dont know why but def index is not working to /api/v1/teams but def show is working
        member do
          get ":id", to: "teams#detail"
          patch ":id", to: "teams#update"
          delete ":id", to: "teams#destroy"
        end
      end

      resource :price, only: [ :show ]
    end
  end
end
