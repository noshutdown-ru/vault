# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :projects do
    resources :keys
  get '/key_files/:id/download', to: 'key_files#download', as: 'download_key_file'
  get '/keys/:id/copy', to: 'keys#copy', as: 'copy_key'
end

resources :vault_settings do
  collection do
    get :autocomplete_for_user
    post :backup, to: 'vault_settings#backup'
    post :restore, to: 'vault_settings#restore'
  end
end