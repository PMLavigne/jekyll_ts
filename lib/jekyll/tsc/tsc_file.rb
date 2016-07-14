
require 'jekyll'
require 'open3'

require_relative 'tsc_env.rb'

module Jekyll
    module TSC
        class TsFile < StaticFile
            def initialize(site, base, dir, name, jsroot, tsc, opts, env)
                super(site, base, dir, name, nil)

                @tspath = File.join(base, dir, name)
                @jsdir = jsroot
                @tsc = tsc
                @opts = opts
                @env = env
            end

            def write(dest)
                # js name
                ts_ext = /\.ts$/i
                js_name = @name.gsub(ts_ext, '.js')

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
                            Jekyll.logger.error(PLUGIN_NAME, "  #{v}")
                        end
                        Jekyll.logger.abort_with(PLUGIN_NAME, 'Compilation failed.')
                    end

                    Jekyll.logger.debug(PLUGIN_NAME, "Compiled #{@tspath} to #{js}")
                end
            end
        end
    end
end
