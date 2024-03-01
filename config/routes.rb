# frozen_string_literal: true

Rails.application.routes.draw do

  post 'player', to: 'players#create'
  post 'session', to: 'sessions#create'
  get 'rankings', to: 'players#rankings'
end
