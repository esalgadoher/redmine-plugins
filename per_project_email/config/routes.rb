# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get 'project_email/:id/', :to => 'project_email#show'
get 'project_email/:id/', :to => 'project_email#edit'
post 'project_email/:id/', :to => 'project_email#edit'
match 'projects/:id/project_email', :to => 'project_email#edit', :via => [:post]


