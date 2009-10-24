# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)
User.create(:login => 'admin', 
            :email => 'admin@admin.com',
            :password => 'oupsnow',
            :password_confirmation => 'oupsnow',
            :global_admin => true)
Function.create(:name => 'Admin', :project_admin => true)
Function.create(:name => 'Developper', :project_admin => false)
State.create(:name => 'new')
State.create(:name => 'open')
State.create(:name => 'resolved', :closed => true)
State.create(:name => 'hold', :closed => true)
State.create(:name => 'closed', :closed => true)
State.create(:name => 'invalid', :closed => true)
Priority.create(:name => 'Low')
Priority.create(:name => 'Normal')
Priority.create(:name => 'High')
Priority.create(:name => 'Urgent')
