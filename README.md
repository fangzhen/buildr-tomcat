buildr-tomcat
=============

buildr-tomcat provides a plugin for Buildr that allows you to run a war-packaged project in an embedded Tomcat.

It is largely based on the Jetty plugin, but is somewhat simplified.

Installation
------------

	git clone https://github.com/technophobia/buildr-tomcat.git
	cd buildr-tomcat
	./build.sh
	gem install ./buildr-tomcat-0.0.1.gem

Usage
-----
###For embedded tomcat###

	require 'tomcat'
	
	...

	desc 'This is my project'

	define 'MyProject' do

		define "my-webapp" do
			compile.with # some dependencies here
			package(:war)

			task('tomcat') do |task|
				name = 'my-webapp'
				Buildr::Tomcat::explode(self)
				Buildr::Tomcat.new(name, "http://localhost:8084/#{name}", "#{name}/target/#{name}-#{VERSION_NUMBER}").run

				trap 'SIGINT' do
					puts "Stopping Tomcat"
					tomcat.stop
				end
				Thread.stop
			end
		end

		...

	end

###For standalone tomcat###
1. configuration of buildfile

	require 'tomcatSa'
	
	desc 'This is my project'
	...
	define 'MyProject' do

		define "my-webapp" do
			compile.with # some dependencies here
			package(:war)

			task("tomcat-deploy"=>package(:war)) do |task|
			  tomcat = Buildr::TomcatSa.new(self) #
			  tomcat.deploy
			end
			task("tomcat-redeploy"=>package(:war)) do |task|
			  tomcat = Buildr::TomcatSa.new(self)
			  tomcat.redeploy
			end
			task("tomcat-undeploy") do |task|
			  tomcat = Buildr::TomcatSa.new(self)
			  tomcat.undeploy
			end
			...
		end 
		...
	end
2. tomcat settings
add following lines to you settings.yaml in ~/.buildr
	tomcat:
	  username: tomcats #tomcat user who has "manager-script" role
	  password: tomcat
	  url: http://localhost:8080  # url default to http://localhost:8080

Modification
------------
If you need to modify the Java code (in *java/src/main/java*), there's a Buildr *buildfile* in *java/*.
Simply execute '''buildr eclipse''' to generate the necessary Eclipse project files, and import as usual.
(You can do IDEA too, if that's your thing).

You can rebuild the whole thing (including the Java) and repackage as a Gem by running '''build.sh'''.
