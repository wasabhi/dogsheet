ActionController::Routing::Routes.draw do |map|
  map.resources :tasks do |task|
    task.resources :timeslices
  end

  map.resources :users
  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  map.resources :user_sessions

  map.resources :timeslices
  map.timesheet '/timesheet/:date', :controller => 'timeslices',
    :requirements => { :date => /\d{4}-\d{2}-\d{2}/ }
  map.timesheet_multiday '/timesheet/:date/:end_date', :controller => 'timeslices',
    :requirements => { 
      :date => /\d{4}-\d{2}-\d{2}/, :end_date => /\d{4}-\d{2}-\d{2}/
    }
  map.timesheet_add '/timesheet/:date/add', :controller => 'timeslices', :action => 'create'
  map.connect '/timesheet/:date.:format', :controller => 'timeslices'
  map.connect '/timesheet/:date/:end_date.:format', :controller => 'timeslices'

  map.root :controller => "timeslices"

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
