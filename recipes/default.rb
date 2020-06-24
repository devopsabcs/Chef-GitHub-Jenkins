package 'apache2' do
	   action :install
end
file '/var/www/html/index.html' do
	   action :create
	    
	  content "<h2>This is #{node['name']}</h2><h1>Hello World</h1>"
	        end
service 'apache2' do
	   action [ :enable, :start ]
end
