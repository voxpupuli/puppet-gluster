peer_count = 0
peer_list = ''
volume_bricks = {}
volume_options = {}
volume_ports = {}

binary = Facter.value('gluster_custom_binary')
if not binary or not File.executable? binary
	# http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby/5471032#5471032
	exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
	ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
		exts.each { |ext|
			exe = File.join(path, "gluster#{ext}")
			binary = exe if File.executable? exe
		}
	end
end

if binary then
	# the Gluster binary command to use
	Facter.add(:gluster_binary) do
		setcode do
			binary
		end
	end
	output = Facter::Util::Resolution.exec("#{binary} peer status")
	peer_count = $1.to_i if output =~ /^Number of Peers: (\d+)$/
	if peer_count > 0 then
		peer_list = output.scan(/^Hostname: (.+)$/).flatten.join(',')
		# note the stderr redirection here
		# `gluster volume list` spits to stderr :(
		output = Facter::Util::Resolution.exec("#{binary} volume list 2>&1")
		if output != "No volumes present in cluster" then
			output.split.each do |vol|
				info = Facter::Util::Resolution.exec("#{binary} volume info #{vol}")
				vol_status = $1 if info =~ /^Status: (.+)$/
				bricks = info.scan(/^Brick[^:]+: (.+)$/).flatten
				volume_bricks[vol] = bricks
				options = info.scan(/^(\w+\.[^:]+: .+)$/).flatten
				if options then
					volume_options[vol] = options
				end
				if vol_status == "Started" then
				  status = Facter::Util::Resolution.exec("#{binary} volume status #{vol}")
				  volume_ports[vol] = status.scan(/^Brick [^\t]+\t+(\d+)/).flatten.uniq.sort
				end
			end
		end
	end

	# Gluster facts don't make sense if the Gluster binary isn't present
	Facter.add(:gluster_peer_count) do
		setcode do
			peer_count
		end
	end

	# these facts doesn't make sense without peers
	if peer_count > 0
		Facter.add(:gluster_peer_list) do
			setcode do
			       	peer_list
			end
		end

		if not volume_bricks.empty? then
			Facter.add(:gluster_volume_list) do
				setcode do
					volume_bricks.keys.join(',')
				end
			end
			volume_bricks.each do |vol,bricks|
				Facter.add("gluster_volume_#{vol}_bricks".to_sym) do
					setcode do
						bricks.join(',')
					end
				end
			end
			if volume_options
				volume_options.each do |vol,opts|
					Facter.add("gluster_volume_#{vol}_options".to_sym) do
						setcode do
							opts.join(',')
						end
					end
				end
			end
			if volume_ports
				volume_ports.each do |vol,ports|
					Facter.add("gluster_volume_#{vol}_ports".to_sym) do
						setcode do
							ports.join(',')
						end
					end
				end
			end
		end
	end
end
