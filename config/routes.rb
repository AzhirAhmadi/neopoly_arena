# frozen_string_literal: true

Rails.application.routes.draw do

  post 'player', to: 'players#create'
  post 'session', to: 'sessions#create'
  get 'rankings', to: 'players#rankings'

  resources :games, only: %i[index show create] do
    put '/drop_coin', to: 'games#drop_coin'
    put '/join', to: 'games#join'
  end
  
  post '/invite', to: 'games#invite'
end
