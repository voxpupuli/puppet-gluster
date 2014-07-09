peer_count = 0
peer_list = ''
volume_bricks = {}

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
	output = Facter::Util::Resolution.exec("#{binary} peer status")
	if output =~ /^Number of Peers: (\d+)$/
		peer_count = $1.to_i
	end
	if peer_count > 0 then
		peer_list = output.scan(/^Hostname: (.+)$/).flatten.join(',')
		# note the stderr redirection here
		# `gluster volume list` spits to stderr :(
		output = Facter::Util::Resolution.exec("#{binary} volume list 2>&1")
		if output != "No volumes present in cluster" then
			output.split.each do |vol|
				output = Facter::Util::Resolution.exec("#{binary} volume info #{vol}")
				bricks = output.scan(/^Brick[^:]+: (.+)$/).flatten
				volume_bricks[vol] = bricks
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
		end
	end
end
