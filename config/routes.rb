Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  resource :progress_bar, only: [:show]

  root 'static_pages#home'

  match '/help',          to: 'static_pages#help',    via: 'get'
  match '/home',          to: 'static_pages#home',    via: 'get'
  match '/dev',           to: 'static_pages#dev',     via: 'get'
  match '/about',         to: 'static_pages#about',   via: 'get'

  match '/import',        to: 'import#create',        via: 'post'
  match '/import',        to: 'import#new',           via: 'get'

  match '/email',         to: 'debts#preview_email',  via: 'get'
  match '/email/send',    to: 'debts#send_email',     via: 'post'

  resources :debtors
  match 'debtor/search', to: 'debtors#search', via: 'get', as: 'search'

  resources :debts, except: :destroy do
    # resources :mail_logs, except: :destroy
  end
end
