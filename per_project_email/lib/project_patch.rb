# To change this template, choose Tools | Templates
# and open the template in the editor.
# To change this template, choose Tools | Templates
# and open the template in the editor.

require_dependency 'project'

module ProjectPatch
  
  def self.included(base)
        base.extend(ClassMethods)
        
        base.class_eval do
          validates_format_of :email, :with => /[\w\W]+@([a-z]+.[a-z]+.?){1,}|^$/
          safe_attributes 'email'
        end
  end
  
   module ClassMethods
   end
end

Project.send(:include, ProjectPatch)
