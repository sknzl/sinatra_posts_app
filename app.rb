require "sinatra"
require "sinatra/reloader" if development?
require "pry-byebug"
require "better_errors"
configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path('..', __FILE__)
end

require_relative "config/application"

set :views, (proc { File.join(root, "app/views") })
set :bind, '0.0.0.0'

enable :sessions


get '/' do
  # TODO
  # 1. fetch posts from database.
  # 2. Store these posts in an instance variable
  # 3. Use it in the `app/views/posts.erb` view
  @posts = Post.all.order(votes: :desc)
  erb :posts # Do not remove this line
end

# TODO: add more routes to your app!

get '/user/:id' do
  id = params["id"]
  user = User.find(id)
  posts_user = Post.all.joins(:user).where("users.id = #{id}").order(votes: :desc)
  @view_data = { user: user, posts: posts_user }
  erb :user
end

get '/delete/:id' do
  id = params["id"]
  post = Post.find(id)
  post.destroy
  redirect back
end

get '/upvote/:id' do
  id = params["id"]
  post = Post.find(id)
  post.votes += 1
  post.save
  redirect back
end

get '/register' do
  erb :register
end

post '/post' do
  post = Post.new(name: params[:title], url: params[:url], user_id: session[:id])
  post.save
  redirect '/'
end

post '/login' do
  user = User.find_by username: params[:username]
  if user.password == params[:password]
    session[:id] = user.id
    session[:user] = user
  else
    session[:id] = nil
  end
  redirect '/'
end

post '/createuser' do
  user = User.new(username: params[:username], password: params[:password], email: params[:email])
  user.save
  redirect '/'
end

get "/logout" do
  session[:id] = nil
  session[:user] = nil
  redirect '/'
end

