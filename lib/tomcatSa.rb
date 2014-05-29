require 'net/http'
module Buildr

	# Buildr plugin for Standalone tomcat. It provides tools to (re)deploy/undeploy web apps
	class TomcatSa
		attr_accessor :url
		attr_accessor :managerApp
		attr_accessor :deployPath
		attr_accessor :warName
		attr_accessor :targetDir

		# :call-seq:
		#   instance() => TomcatSa
		#
		# Returns an instance of TomcatSa.
		def initialize(webapp=nil)
			@username, @password, @url = Buildr.settings.user['tomcat'].values_at('username', 'password', 'url')
			@url ||= 'http://localhost:8080'
			@managerApp = '/manager/text'
			@webapp = webapp
			pname = @webapp.name.split(':').last #project name without parent project, e.g. bar
			qname = @webapp.name.gsub(':', '-') #project name with parent name, e.g. foo-bar
			version = @webapp.version
			@warName = qname + '-' + @webapp.version
			@targetDir= @webapp.path_to('target')
			@deployPath = pname
		end

		# Deploy 
		def deploy(*deps, &block)
			command = '/deploy'
			uri = URI(@url);
			uri.path = @managerApp + command
			uri.query="path=/#{@deployPath}&war=file:#{@targetDir}/#{@warName}.war"
			if (block_given?)
				yield uri
			end
			res = request uri
			puts res.body
		end

		#undeploy
		def undeploy()
			command='/undeploy'
			uri = URI(@url)
			uri.path = @managerApp + command
			uri.query='path=/' + @deployPath
			res = request uri
			puts res.body
		end

		#redeploy
		def redeploy(*deps, &block)
			deploy {|uri|
				uri.query << '&update=true'
			}
		end

		protected
		def request(uri)
			req = Net::HTTP::Get.new(uri)
			req.basic_auth @username, @password
			res = Net::HTTP.start(uri.hostname, uri.port) {|http|
				http.request(req)
			}
		end

	end
end
#tomcat = Buildr::TomcatSA.new('tomcat', 'tomcat', 'ode');
#tomcat.undeploy();

