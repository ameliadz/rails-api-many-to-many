Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope '/authors/:author_id' do
    resources :books
  end

  scope 'books/:book_id' do
    resources :authors
  end
end
