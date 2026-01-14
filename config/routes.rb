# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :projects do
  resources :keys do
    member do
      get :download
    end
    resources :tags, only: [:index, :create, :update, :destroy], controller: 'tags'
  end
  get '/keys/:id/copy', to: 'keys#copy', as: 'copy_key'
end

get 'keys/all', to: 'keys#all', as: 'keys_all'
get 'keys/:id/edit_orphaned', to: 'keys#edit_orphaned', as: 'edit_orphaned_key'
patch 'keys/:id/update_orphaned', to: 'keys#update_orphaned', as: 'update_orphaned_key'
delete 'keys/:id', to: 'keys#destroy_orphaned', as: 'orphaned_key'

resources :vault_settings do
  collection do
    get :autocomplete_for_user
    post :backup, to: 'vault_settings#backup'
    post :restore, to: 'vault_settings#restore'
    post :save, to: 'vault_settings#save'
  end
end
