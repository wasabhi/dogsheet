user = User.create :name => 'Test', :email => 'test@example.com',
                   :password => 'test', :password_confirmation => 'test'

task = Task.create :name => 'Dummy task', :user => user
