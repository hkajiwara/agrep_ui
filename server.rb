enable :sessions
set :haml, :escape_html => true

# Top page
get "/" do
	haml session[:client] ? :component_type : :guest_home
end

# Login
post "/login" do
	session[:client] = Databasedotcom::Client.new
	begin
		session[:client].host = params[:host]
		session[:client].client_id = params[:client_id]
		session[:client].client_secret = params[:client_secret]
		session[:client].authenticate(:username => params[:username], :password => params[:password])
	rescue Databasedotcom::SalesForceError => err
		session[:client] = nil
		p err.message
	end
	redirect to("/")
end

# Logout
get "/logout" do
	session[:client] = nil
	redirect to("/")
end

# Search
post "/search" do
	p params[:component_type]
	case params[:component_type]
		when 'ApexClass'
			query = 'SELECT ID, Name, Body FROM ApexClass'
		when 'ApexTrigger'
			query = 'SELECT ID, Name, Body FROM ApexTrigger'
		when 'ApexPage'
			query = 'SELECT ID, Name, Markup FROM ApexPage'
		when 'ApexComponent'
			query = 'SELECT ID, Name, Markup FROM ApexComponent'
		else
	end

	begin
		@result = session[:client].query(query)
	rescue Databasedotcom::SalesforceError => err
		session[:client] = nil
		@result = nil
		p err.message
	end

	haml :search

end

# Reference
get "/sobject/:type" do
	@sobject = params[:type]
	@names_or_ids = session[:client].query("SELECT Name,Id FROM #{@sobject}")
	haml :sobject
end

# Create page
get "/sobject/:type/new" do
	@sobject = session[:client].materialize(params[:type])
	@record = @sobject.new
	haml :new_record
end

# Creatoe
post "/sobject/:type/create" do
	owner = params.delete('Owner')
	splat = params.delete('splat')
	captures = params.delete('captures')
	type = params.delete('type')
	@sobject = session[:client].materialize(type)
	params['OwnerId'] = session[:client].user_id
	new_object = session[:client].create(type, params)
	redirect to("/sobject/#{type}/#{new_object.Id}")
end

# Reference page
get "/sobject/:type/:record_id" do
	@sobject = session[:client].materialize(params[:type])
	@record = @sobject.find(params[:record_id])
	haml :record
end
