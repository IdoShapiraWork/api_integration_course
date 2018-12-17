Rails.application.routes.draw do
  root to: 'login#login'

  get '/login' => 'login#login'

  post '/login' => 'login#login'

  get '/api_admin' => 'api_admin#api_admin'

  get 'api_admin/api_admin'
  get 'api_user/user_requests'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
