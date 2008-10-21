ActionController::Routing::Routes.draw do |map|
  map.root :controller => "events"
  

  map.resources :events do |events|
    events.resources :registrations, :member => {:mark_paid => :post}
  end
  
  map.connect 'account/:action/:id', :controller => 'account'
  map.resources :users
end
