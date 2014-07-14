require 'json'
require 'rubygems'
require 'active_record'
require 'httparty'

ActiveRecord::Base.establish_connection(
    :adapter => 'postgresql',
    :database =>  'homeauto',
    :user => 'postgres',
    :password => 'postgres',
    :host => 'localhost',
    :pool => 5
)

class Task < ActiveRecord::Base
end

class Message < ActiveRecord::Base
end
