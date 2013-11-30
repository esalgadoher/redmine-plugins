class Project_email < ActiveRecord::Base
  include Redmine::SafeAttributes
  
  safe_attributes 'email'
  validates_format_of :start_page, :with => /^*@\.*$/
end
