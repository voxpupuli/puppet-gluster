gluster_volumes = {}
peer_count = 0
peer_list = ''
volume_bricks = {}
volume_options = {}
volume_ports = {}

binary = Facter.value('gluster_custom_binary')
# rubocop:disable Style/AndOr
if !binary or !File.executable? binary
  # rubocop:enable Style/AndOr
  # http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby/5471032#5471032
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each do |ext|
      exe = File.join(path, "gluster#{ext}")
      binary = exe if File.executable? exe
    end
  end
end

if binary
  # the Gluster binary command to use
  Facter.add(:gluster_binary) do
    setcode do
      binary
    end
  end
  output = Facter::Util::Resolution.exec("#{binary} peer status")
  peer_count = Regexp.last_match[1].to_i if output =~ %r{^Number of Peers: (\d+)$}
  if peer_count > 0
    peer_list = output.scan(%r{^Hostname: (.+)$}).flatten.join(',')
    other_names = output.scan(%r{^Other names:\n((.+\n)+)}).flatten.join.scan(%r{(.+)\n?}).sort.uniq.flatten.join(',')
    peer_list += ',' + other_names if other_names
  end
  # note the stderr redirection here
  # `gluster volume list` spits to stderr :(
  output = Facter::Util::Resolution.exec("#{binary} volume list 2>&1")
  if output != 'No volumes present in cluster'
    output.split.each do |vol|
      # Create hash entry for each volume in a structured fact.
      gluster_volumes[vol] = {}

      # If a brick has trailing informaion such as (arbiter) remove it
      info = Facter::Util::Resolution.exec("#{binary} volume info #{vol} | sed 's/ (arbiter)//g'")
      vol_status = Regexp.last_match[1] if info =~ %r{^Status: (.+)$}
      gluster_volumes[vol]['status'] = vol_status

      bricks = info.scan(%r{^Brick[^:]+: (.+)$}).flatten
      volume_bricks[vol] = bricks
      gluster_volumes[vol]['bricks'] = bricks

      # Get the volume options.
      options = info.scan(%r{^((?!features\.)\w+\.[^:]+: .+)$}).flatten
      if options
        volume_options[vol] = options
        gluster_volumes[vol]['options'] = {}
        # Convert options into key: value pairs for easy retrieval if needed.
        options.each do |option|
          option_name, set_value = option.split(': ', 2)
          gluster_volumes[vol]['options'][option_name] = set_value
        end
      end

      # Get the volume features. They are handled differently than options.
      features = info.scan(%r{^(features\.[^:]+: .+)$}).flatten
      if features
        gluster_volumes[vol]['features'] = {}
        # Convert features into key: value pairs for easy retrieval if needed.
        features.each do |feature|
          feature_name, set_value = feature.split(': ', 2)
          gluster_volumes[vol]['features'][feature_name] = set_value
        end
      end

      next unless vol_status == 'Started'
      status = Facter::Util::Resolution.exec("#{binary} volume status #{vol} 2>/dev/null")
      if status =~ %r{^Brick}
        volume_ports[vol] = status.scan(%r{^Brick [^\t]+\t+(\d+)}).flatten.uniq.sort
        gluster_volumes[vol]['ports'] = volume_ports[vol]
      end
    end
  end

  # Gluster facts don't make sense if the Gluster binary isn't present
  Facter.add(:gluster_peer_count) do
    setcode do
      peer_count
    end
  end

  Facter.add(:gluster_peer_list) do
    setcode do
      peer_list
    end
  end

  unless volume_bricks.empty?
    Facter.add(:gluster_volume_list) do
      setcode do
        volume_bricks.keys.join(',')
      end
    end
    volume_bricks.each do |vol, bricks|
      Facter.add("gluster_volume_#{vol}_bricks".to_sym) do
        setcode do
          bricks.join(',')
        end
      end
    end
    if volume_options
      volume_options.each do |vol, opts|
        # Create flat facts for each volume
        Facter.add("gluster_volume_#{vol}_options".to_sym) do
          setcode do
            opts.join(',')
          end
        end
      end
    end
    if volume_ports
      volume_ports.each do |vol, ports|
        Facter.add("gluster_volume_#{vol}_ports".to_sym) do
          setcode do
            ports.join(',')
          end
        end
      end
    end
    # Create a new structured fact containing all volume info.
    Facter.add(:gluster_volumes) do
      setcode do
        gluster_volumes
      end
    end
  end
end
