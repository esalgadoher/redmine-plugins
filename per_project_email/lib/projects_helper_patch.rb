# To change this template, choose Tools | Templates
# and open the template in the editor.

require_dependency 'projects_helper'

module ProjectsHelperPatch
  
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do

      alias_method_chain :project_settings_tabs, :email_tab
    end
  end
  
  
  module InstanceMethods
    def project_settings_tabs_with_email_tab
      #Añade la pestaña de Email a la pagina de administracion de proyecto
      
      tabs = project_settings_tabs_without_email_tab
      tabs << {:name => 'email', :action => 'view_project_email', :partial => 'projects/settings/email', :label => :project_email }
      tabs.select {|tab| User.current.allowed_to?(tab[:action], @project)}
      return tabs
    end
  end
end

ProjectsHelper.send(:include, ProjectsHelperPatch)