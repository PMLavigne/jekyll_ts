# Converts typescript files to javascript
#
# Uses the following configs
#    tsc           => Path of typescript compiler
#    js_dest       => Output of js files after compilation, relative to site root (usually "_site")
#    environment   => Build environment, either "production" (default) or "development".
#                     Overridden by environment variable "JEKYLL_ENV"
#    tsc_opts      => Options applied to every build regardless of environment. Defaults to "-t ES5" for
#                     backwards-compatability
#    tsc_dev_opts  => Options added to builds when environment is "development". No default
#    tsc_prod_opts => Options added to builds when environment is "production". No default

# Written by Matt Sheehan, 2015
# Updated by Patrick Lavigne, 2016

require 'open3'

# Friendly name to show in logs
PLUGIN_NAME = "Compile Typescript:"

module Jekyll

	class TsGenerator < Generator
		safe true
		priority :low

		def generate(site)
            Jekyll.logger.debug(PLUGIN_NAME, "Initializing")
			# location of typescript compiler
			# defaults to tsc assuming in system env path
			tsc = site.config["tsc"] || "tsc"

			# js destination
			js_dest = site.config["js_dest"] || "/"


            # Environment can be optionally set in an environment variable or site config. Default to "production" to
            # maintain old behavior if not found
            jekyll_env = ENV["JEKYLL_ENV"] || site.config["environment"] || "production"

            # Extra options to always pass to tsc
            opts = site.config["tsc_opts"] || "-t ES5"
            case jekyll_env
                # Extra options to pass to tsc only for prod builds
            when "production"
                opts += " " + site.config["tsc_prod_opts"]

                # Extra options to pass to tsc only for dev builds
            when "development"
                opts += " " + site.config["tsc_dev_opts"]
            end

            Jekyll.logger.debug(PLUGIN_NAME, "Will compile typescript in #{jekyll_env} mode with options: #{opts}")

			ts_files = Array.new;

			site.static_files.delete_if do |sf|
				next if not File.extname(sf.path) == ".ts"

				# get the dirname of file, but we don't need the site source
				ts_dir = File.dirname(sf.path.gsub(site.source, ""))
				ts_name = File.basename(sf.path)

				# add ts file
				ts_files << TsFile.new(site, site.source, ts_dir, ts_name, js_dest, tsc, opts, jekyll_env)

                # return true so this file gets removed from static_files
				# we'll replace it with our own tsfile that implements
				# it's own write
				true
			end

			# concat new tsfiles with static files
			site.static_files.concat(ts_files)
		end
	end


	class TsFile < StaticFile
		def initialize(site, base, dir, name, jsroot, tsc, opts, env)
			super(site, base, dir, name, nil)

			@tspath = File.join(base, dir, name)
			@jsdir = jsroot
			@tsc = tsc
            @opts = opts;
            @env = env;
		end

		def write(dest)
			# js name
			ts_ext = /\.ts$/i
			js_name = @name.gsub(ts_ext, ".js")

			# js full path
			js_path = File.join(dest, @jsdir)
			js = File.join(js_path, js_name)

			# make sure dir exists
			FileUtils.mkdir_p(js_path)
			# execute shell command
			begin
				command = "#{@tsc} #{@opts} --out \"#{js}\" \"#{@tspath}\" >&1"

				stdout, result = Open3.capture2(command)

                unless result.success?
                    lines = stdout.split("\n")
                    Jekyll.logger.error(PLUGIN_NAME, "Error: #{lines[0]}")
                    first = true
                    lines.each do |v|
                        if first
                            first = false
                            next
                        end
                        Jekyll.logger.error(PLUGIN_NAME, "  #{v}");
                    end
                    Jekyll.logger.abort_with(PLUGIN_NAME, "Compilation failed.")
                end

                Jekyll.logger.debug(PLUGIN_NAME, "Compiled #{@tspath} to #{js}")
			end
		end
	end

end
