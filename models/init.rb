ActiveRecord::Base.establish_connection(
  :adapter  => 'mysql2',
  :host     => 'localhost',
  :username => 'root',
  :password => '',
  :database => 'test_app',
  :encoding => 'utf8'
)

require_relative 'product'
require_relative 'customer'
require_relative 'order'
require_relative 'order_line'