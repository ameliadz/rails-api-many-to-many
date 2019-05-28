Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope '/movies/:movie_id' do
    resources :actors
  end

  scope '/actors/:actor_id' do
    resources :movies
  end

end
