require "sinatra"
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'byebug'
require 'will_paginate'
require 'will_paginate/active_record'
require 'rest_client'
require 'json'


class SimpleApp < Sinatra::Base
  use Rack::Session::Pool, :expire_after => 2592000
  register Sinatra::Flash
  register WillPaginate::Sinatra

  set :environment, :development

  before do
    @current_user = session[:current_user] rescue nil
  end

  helpers do
    def protected!
      return if authorized?
      headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
      halt 401, "Not authorized\n"
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['admin', 'admin']
    end
  end

  get '/admin' do
    protected!
    @products = Product.paginate(:page => params[:page], :per_page => 10)
    erb :'products/index', layout: :admin_layout
  end

  get '/admin/products' do
    protected!
    @products = Product.paginate(:page => params[:page], :per_page => 10)
    erb :'products/index', layout: :admin_layout
  end

  get '/admin/products/new' do
    protected!

    erb :'products/new', layout: :admin_layout
  end

  post '/admin/products' do
    protected!

    product = Product.new params[:product]

    if product.save
      redirect to('/admin/products')
    else
      redirect back
    end
  end

  get '/admin/products/:id/edit' do
    protected!

    @product = Product.find params[:id].to_i

    erb :'products/edit', layout: :admin_layout
  end

  post '/admin/products/:id' do
    protected!

    product = Product.find params[:id].to_i
    product.update_attributes(params[:product])

    redirect to('/admin/products')
  end

  post '/admin/products/:id/delete' do
    protected!

    product = Product.find params[:id].to_i
    product.destroy

    redirect to('/admin/products')
  end

   get '/' do
    @products = Product.all.limit(3)
    erb :home
  end

  get '/home' do
    @products = Product.all.limit(3)
    erb :home
  end

  get '/products' do
    @products = Product.paginate(:page => params[:page], :per_page => 9)
    erb :products
  end


  get '/registration' do
    erb :registration
  end

  get '/login' do
    if @current_user
      flash.now[:info] = "You are already logged in"
      @products = Product.paginate(:page => params[:page], :per_page => 9)
      erb :products
    else
      erb :login
    end
  end

  post '/login' do
    customer = Customer.find_by(email: params[:email])
    if customer
      current_user = customer.authenticate(params[:password])
    else
      current_user = nil
    end

    if current_user
      flash.now[:info] = "You are logged in successfully"
      session[:current_user] = current_user

      @products = Product.paginate(:page => params[:page], :per_page => 9)
      erb :products
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
    if @current_user
      @orders = @current_user.orders.order('id desc').paginate(:page => params[:page], :per_page => 10)
      erb :orders
    else
      flash.now[:error] = "You should be logged in"
      erb :login
    end
  end

  get '/order_items/:id' do
    if @current_user
      @order_items = OrderLine.where(order_id: params[:id].to_i).order('id desc')
      erb :order_items
    else
      flash.now[:error] = "You should be logged in"
      erb :login
    end
  end

  get '/cart' do
    if session.has_key?(:cart) && session[:cart].size > 0
      @cart = session[:cart]
      @products = Product.where(id: session[:cart].keys.map(&:to_i))
    else
      @products = []
    end
    erb :cart
  end

  post '/cart' do
    session[:cart] ||= {}
    session[:cart][params[:id]] = session[:cart].has_key?(params[:id]) ? session[:cart][params[:id]].to_i + 1 : 1
    flash[:info] = "Product added to cart"
    redirect to('/products')
  end

  post '/cart.json' do
    content_type :json
    session[:cart][params[:id]] = params[:qty]
    "{status: 'ok'}"
  end

  get '/cart/:id' do
    session[:cart].delete params[:id].to_s
    redirect to('/cart')
  end

  post '/checkout' do
    if @current_user
      @token = (('a'..'z').to_a + (0..9).to_a).shuffle.take(32).join
      @order =  Order.create_order(@current_user, params[:products], @token)
      session[:cart] = {}

      erb :go_payment
    else
      flash.now[:error] = "You should be logged in"

      erb :login
    end
  end

  post '/payment/status' do
    if params[:token]
      order = Order.find_by(order_no: params[:order_no])
      if params[:token] == order.token
        if params[:status] == "paid"
          order.status = "paid"
          order.save

          flash.now[:info] = "Payment was successful"
        else
          flash.now[:info] = "Payment wasn't successful"
        end
      else
        "Unauthorized access"
      end

      @products = {}

      erb :cart
    else
      "Unauthorized access"
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