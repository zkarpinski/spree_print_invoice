Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :orders do
      get :print_packing_labels
    end
  end
end
