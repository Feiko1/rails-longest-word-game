Rails.application.routes.draw do
  get 'game', to: 'games#game'
  get 'score', to: 'games#score'

  root 'games#game'
end
