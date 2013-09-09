enable :sessions
set :haml, :escape_html => true

configure do
	set :selected_component, 'ApexClass'
	set :records, ''
end

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

# Retrieve
post "/search" do
	settings.selected_component = params[:component_type]
	case settings.selected_component
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
		settings.records = session[:client].query(query)
	rescue Databasedotcom::SalesforceError => err
		session[:client] = nil
		settings.records = nil
		p err.message
	end
	haml :search
end

# Search
post "/result" do
	reg = Regexp.compile(params[:keyword])
	if settings.selected_component == 'ApexClass' || settings.selected_component == 'ApexTrigger'
		settings.records.each do |record|
			if reg =~ record.Body
				p record.class
			end
		end
	else
		settings.records.each do |record|
			if reg =~ record.Markup
				p record.Name
			end
		end
	end
	haml :result
end
