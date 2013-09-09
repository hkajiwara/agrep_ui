require 'rubygems'
require 'databasedotcom'
require 'sinatra'
require 'sinatra/reloader'
require 'haml'
require './server.rb'

run Sinatra::Application
