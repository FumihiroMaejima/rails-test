Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  scope '/api' do
    scope '/v1' do
        resources :users, only: [:show]

        # 下記は非リソースフルルート

        # debug
        scope '/debug' do
            get '/test', to: 'users/debug#test'

            get '/users/:id', to: 'users/debug#user'

            get '/coins/:id', to: 'users/debug#coin'

            get '/events/:id', to: 'users/debug#event'

            get '/informations/:id', to: 'users/debug#information'
        end
    end
  end
end
