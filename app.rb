require "sinatra"
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'byebug'

class SimpleApp < Sinatra::Base
  # use Rack::Session::Pool, :expire_after => 2592000
  enable :sessions
  register Sinatra::Flash

  get '/home' do
    erb :home
  end

  get '/products' do
    @products = Product.all
    erb :products
  end

  get '/products/new' do
    erb :'products/new'
  end

  post '/products' do
    product = Product.new params[:product]

    if product.save
      redirect to('/products')
    else
      redirect back
    end
  end

  get '/products/:id/edit' do
    @product = Product.find params[:id].to_i

    erb :'products/edit'
  end

  patch '/products/:id' do
    product = Product.find params[:id].to_i
    product.update_attributes(params[:product])

    redirect to('/products')
  end

  delete '/products/:id' do
    product = Product.find params[:id].to_i
    product.destroy

    redirect to('/products')
  end

  get '/registration' do
    erb :registration
  end

  get '/login' do
    if session.has_key?(:current_user)
      flash.now[:info] = "You are already logged in"
      @products = Product.all
      erb :'products/index'
    else
      erb :login
    end
  end

  post '/login' do
    customer = Customer.find_by(email: params[:email])
    current_user = customer.authenticate(params[:password])

    if current_user
      flash.now[:info] = "You are logged in successfully"
      session[:current_user] = current_user

      @products = Product.all
      erb :'products/index'
    else
      flash.now[:error] = "Email or password is not correct!"
      erb :login
    end
  end

  get '/logout' do
    session.delete(:current_user)
    flash.now[:info] = "You are logged out successfully"
    erb :login
  end

  post '/customers' do
    customer = Customer.new params[:customer]
    if customer.save
      flash.now[:info] = "You are registered successfully"
      redirect to('/products')
    else
      flash.now[:error] = customer.errors
      @customer = params[:customer]
      erb :registration
    end
  end

  get '/orders' do
    if session.has_key?(:current_user)
      erb :orders
    else
      flash.now[:error] = "You should be logged in"
      erb :login
    end
  end


end

require_relative 'models/init'

module Sinatra
  module Flash
    module Style
      def styled_flash(key=:flash)
        return "" if flash(key).empty?
        id = (key == :flash ? "flash" : "flash_#{key}")
        close = '<a class="close" data-dismiss="alert" href="#">×</a>'
        messages = flash(key).collect {|message| " <div class='alert alert-#{message[0]}'>#{close}\n #{message[1]}</div>\n"}
        "<div id='#{id}'>\n" + messages.join + "</div>"
      end
    end
  end
end