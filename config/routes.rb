Rails.application.routes.draw do
  root 'home#index'
  get 'share', to: 'home#share', as: :share_home
  scope 'trump' do
    get 'index', to: 'trump#index', as: :trump_index  # ゲームの最初の画面
    post 'start_game', to: 'trump#start_game' # ゲーム開始
    get 'show', to: 'trump#show'
    post 'player_choice', to: 'trump#player_choice' # プレイヤーのカード選択
    get 'reveal_card', to: 'trump#reveal_card'
  end
  resources :users, only: %i[new create]
  get 'login', to: 'user_sessions#new'
  post 'login', to: 'user_sessions#create'
  delete 'logout', to: 'user_sessions#destroy'
  resources :boards, only: %i[index new create show destroy]
  resources :skills, only: %i[index] do
    member do
      get :buy
    end
  end
end
