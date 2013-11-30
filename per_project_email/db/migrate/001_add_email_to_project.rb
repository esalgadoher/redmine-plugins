class AddEmailToProject < ActiveRecord::Migration
	def self.up
    unless Project.column_names.include? "email"
        add_column :projects, :email, :string, :null => true
    end
  end
   
  def self.down
    remove_column :projects, :email
  end
end