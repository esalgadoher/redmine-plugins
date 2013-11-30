require 'redmine'
require 'projects_helper_patch'
require 'mailer_patch'
require 'project_patch'

Redmine::Plugin.register :per_project_email do
  name 'Per Project Email plugin'
  author 'Enrique Salgado Hernández'
  description 'This is a plugin for Redmine which allows to define a per-project level email address source for redmine email notifications'
  version '1.0.0'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
 
  permission :view_project_email , { :project_email => [ :show, :edit ] }
end
