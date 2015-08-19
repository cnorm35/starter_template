#Add the current directoy to the path Thor uses to look up files
#(check Thor notes)


#Thor uses source_paths to look up files that are sent to file-based Thor acitons
#https://github.com/erikhuda/thor/blob/master/lib%2Fthor%2Factions%2Ffile_manipulation.rb
#like copy_file and remove_file.

#We're redefining #source_path so we can add the template dir and copy files from it
#to the application


def source_paths
	Array(super)
	[File.expand_path(File.dirname(__FILE__))]
end


#Here we are removing the Gemfile and starting over
#You may want to tap and existing gemset or go this method to make it easier for
#others to check it out.
#Plus, you dont have to remove the comments in the Gemfile
remove_file "Gemfile"
run "touch Gemfile"
#be sure to add source at the top of the file
add_source 'https://rubygems.org'
gem 'rails', '4.2.1'
gem 'sqlite3'
gem 'uglifier'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'turbolinks'
gem 'thin'
gem 'devise'
gem 'bootstrap-sass'
gem 'sass-rails'
gem 'simple_form'
gem 'sdoc', group: :doc
#gem and gem_group will work from Rails Template API
gem_group :development, :test do
	gem 'spring'
	gem 'quiet_assets'
	gem 'pry-rails'
	gem 'byebug'
	gem 'awesome_print'
	gem 'better_errors'
	gem 'binding_of_caller'
end

gem_group :test do
	gem 'guard-rspec'
	gem 'rspec-rails'
end

after_bundle do
	remove_dir 'test'
end

remove_file 'README.rdoc'
create_file 'README.md' do <<-TEXT
	#Markdown Stuff!

	Created with the help of Rails application templates
	TEXT
end

#run 'spring stop'
generate 'rspec:install'
run 'guard init'

generate 'devise:install'
generate 'devise User'
generate 'devise:views'

rake 'db:migrate'

#Add bootstrap to App
create_file 'app/assets/stylesheets/customizations.css.scss' do <<-TEXT
	@import "bootstrap-sprockets";
	@import "bootstrap";

	.center {
		text-align: center;
	}

	/*for Devise Rememver me box*/
	#user_remember_me {
	margin-left: 0px;
}

/*flash*/
.alert-error {
	background-color: #f2dede;
	border-color: #eed3d7;
	color: #b94a48;
	text-align: left;
}

.alert-alert {
	background-color: #f2dede;
	border-color: #eed3d7;
	color: #b94a48;
	text-align: left;
}

.alert-success {
	background-color: #dff0d8;
	border-color: #d6e9c6;
	color: #468847;
	text-align: left;
}

.alert-notice {
	background-color: #dff0d8;
	border-color: #d6e9c6;
	color: #468847;
	text-align: left;
}

TEXT
end

insert_into_file('app/assets/javascripts/application.js', "//= require bootstrap-sprockets\n",
	:before => /\/\/= require_tree ./)

#Creating a home page

generate(:controller, "pages home")

remove_file 'app/views/pages/home.html.erb'

create_file 'app/views/pages/home.html.erb' do <<-TEXT
	<div class="jumbotron center">
	<h1>Tempaltes, Whoop Whoop!</h1>
	<p>Link to my blog and shit.</p>
	<h4><%= link_to 'Sign Up', new_user_registration_path %></h4>
	</div>
	TEXT
end

#Add a nav header for bootstrap
create_file 'app/views/layouts/_header.html.erb' do <<-TEXT
	<nav class="navbar navbar-static-top navbar-default" role="navigation">
	<div class="container">
	<!-- Brand and toggle get grouped for better mobile display -->
	<div class="navbar-header">
	<button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-ex1-collapse">
	<span class="sr-only">Toggle navigation</span>
	<span class="icon-bar"></span>
	<span class="icon-bar"></span>
	<span class="icon-bar"></span>
	</button>
	<%= link_to "APP NAME", root_path, class: "navbar-brand" %>
	</div>

	<!-- Collect the nav links, forms, and other content for toggling -->
	<div class="collapse navbar-collapse navbar-ex1-collapse">
	<ul class="nav navbar-nav navbar-right">
	<li><%= link_to "Home", root_path %></li>
	<% if user_signed_in? %>
		<li><%= link_to current_user.email, edit_user_registration_path %>
		<li><%= link_to "Log out", destroy_user_session_path, method: :delete %></li>
		<% else %>
		<li><%= link_to "Sign in", user_session_path %></li>
		<% end %>
		</ul>
		</div><!-- /.navbar-collapse -->
		</div><!-- /.container -->
		</nav>
		TEXT
	end

# Add meta tags and html5 shim

insert_into_file 'app/views/layouts/application.html.erb', :after => /<%= csrf_meta_tags %>/ do <<-TEXT
	<meta charset='utf-8'>
	<meta http-equiv='X-UA-Compatible' content='IE=edge'>
	<meta name='viewport' content='width=device-width, initial-scale=1'>
	<!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
	<!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
	<!--[if lt IE 9]>
	<script src='https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js'></script&gt;
	<script src='https://oss.maxcdn.com/respond/1.4.2/respond.min.js'></script&gt;
	<![endif]-->
	TEXT
end

create_file 'app/views/layouts/_messages.html.erb' do <<-HTML
<% flash.each do |key, value| %>
<div class="alert alert-<%= key %>">
	<a href="#" data-dismiss="alert" class="close">×</a>
	<ul>
		<li>
			<%= value %>
		</li>
	</ul>
</div>
<% end %>
HTML
end

remove_file 'app/views/devise/registrations/edit.html.erb'
remove_file 'app/views/devise/registrations/new.html.erb'

create_file 'app/views/devise/registrations/edit.html.erb' do <<-TEXT
	<div class="panel panel-default">
	<div class="panel-heading">
	<div class="panel-title">
	<h1>Edit <%= resource_name.to_s.humanize %></h1>
	</div>
	</div>
	<div class="panel-body">
	<%= form_for(resource, :as => resource_name, :url => registration_path(resource_name), :html => { :method => :put }) do |f| %>
		<%= devise_error_messages! %>

		<div class="form-group">
		<%= f.label :email %>
		<%= f.email_field :email, class: "form-control", :autofocus => true %>
		</div>


		<div class="form-group">
		<%= f.label :password %> <i>(leave blank if you don't want to change it)</i>
		<%= f.password_field :password, class: "form-control", :autocomplete => "off" %>
		</div>

		<div class="form-group">
		<%= f.label :current_password %> <i>(we need your current password to confirm your changes)</i>
		<%= f.password_field :current_password, class: "form-control" %>
		</div>

		<div class="form-group">
		<%= f.submit "Update", class: "btn btn-primary" %>
		</div>
		<% end %>
		</div>
		<div class="panel-footer">
		<h3>Cancel my account</h3>

		<p>Unhappy? <%= button_to "Cancel my account", registration_path(resource_name), :data => { :confirm => "Are you sure?" }, :method => :delete, class: "btn btn-warning" %></p>

		<%= link_to "Back", :back %>
		</div>
		</div>

		TEXT
	end

	create_file 'app/views/devise/registrations/new.html.erb' do <<-TEXT
		<div class="panel panel-default">
		<div class="panel-heading">
		<h1>Sign up</h1>
		</div>

		<div class="panel-body">
		<%= form_for(resource, :as => resource_name, :url => registration_path(resource_name)) do |f| %>
			<%= devise_error_messages! %>

			<div class="form-group">
			<%= f.label :email %>
			<%= f.email_field :email, autofocus: true, class: "form-control" %>
			</div>

			<div class="form-group">
			<%= f.label :password %>
			<%= f.password_field :password, class: "form-control" %>
			</div>

			<div class="form-group">
			<%= f.submit "Sign up", class: "btn btn-primary" %>
			</div>
			<% end %>
			</div>

			<div class="panel-footer">
			<%= render "devise/shared/links" %>
			</div>
			</div>
			TEXT
		end

		remove_file 'app/views/devise/sessions/new.html.erb'
		create_file 'app/views/devise/sessions/new.html.erb' do <<-TEXT
			<div class="panel panel-default">
			<div class="panel-heading">
			<div class="panel-title">
			<h1>Sign in</h1>
			</div>
			</div>
			<div class="panel-body">
			<%= form_for(resource, :as => resource_name, :url => session_path(resource_name)) do |f| %>
				<%= devise_error_messages! %>
				<div class="form-group">
				<%= f.label :email %>
				<%= f.email_field :email, class: "form-control", :autofocus => true %>
				</div>

				<div class="form-group">
				<%= f.label :password %>
				<%= f.password_field :password, class: "form-control" %>
				</div>

				<div class="form-group">
				<div class="checkbox">
				<%= f.check_box :remember_me %>
				<%= f.label :remember_me %>
				</div>
				</div>

				<div class="form-group">
				<%= f.submit "Sign in", class: "btn btn-primary" %>
				</div>
				<% end %>
				</div>
				<div class="panel-footer">
				<%= render "devise/shared/links" %>
				</div>
				</div>
				TEXT
			end

			insert_into_file 'app/views/layouts/application.html.erb',
			"\n<%= render 'layouts/header' %>\n <%= render 'layouts/messages'%>", :after => /<body>/


			route "root 'pages#home'"

			create_file 'app/helpers/devise_helper.rb' do <<-TEXT
				module DeviseHelper
					def devise_error_messages!
						return '' if resource.errors.empty?

						messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
						html = <<-HTML
						<div class="alert alert-error alert-danger"> <button type="button"
						class="close" data-dismiss="alert">x</button>
							{messages}
							</div>
							HTML

							html.html_safe
						end
					end

					TEXT
				end

#Janky ass solution
insert_into_file('app/assets/javascripts/application.js', "//= require bootstrap-sprockets\n",
	:before => /\/\/= require_tree ./)

insert_into_file('app/helpers/devise_helper.rb', '#', :before => /{messages}/)


git :init
git add: '.'
git commit: "-a -m 'Initial commit'"
