peer_count = 0
peer_list = []
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
    peer_list = output.scan(%r{^Hostname: (.+)$}).flatten
    # note the stderr redirection here
    # `gluster volume list` spits to stderr :(
    output = Facter::Util::Resolution.exec("#{binary} volume list 2>&1")
    if output != 'No volumes present in cluster'
      output.split.each do |vol|
        info = Facter::Util::Resolution.exec("#{binary} volume info #{vol}")
        # rubocop:disable Metrics/BlockNesting
        vol_status = Regexp.last_match[1] if info =~ %r{^Status: (.+)$}
        bricks = info.scan(%r{^Brick[^:]+: (.+)$}).flatten
        volume_bricks[vol] = bricks
        options = info.scan(%r{^(\w+\.[^:]+: .+)$}).flatten
        volume_options[vol] = options if options
        next unless vol_status == 'Started'
        status = Facter::Util::Resolution.exec("#{binary} volume status #{vol} 2>/dev/null")
        if status =~ %r{^Brick}
          volume_ports[vol] = status.scan(%r{^Brick [^\t]+\t+(\d+)}).flatten.uniq.sort
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

    unless volume_bricks.empty?
      Facter.add(:gluster_volume_list) do
        setcode do
          volume_bricks.keys
        end
      end
      volume_bricks.each do |vol, bricks|
        Facter.add("gluster_volume_#{vol}_bricks".to_sym) do
          setcode do
            bricks
          end
        end
      end
      if volume_options
        volume_options.each do |vol, opts|
          Facter.add("gluster_volume_#{vol}_options".to_sym) do
            setcode do
              opts
            end
          end
        end
      end
      if volume_ports
        volume_ports.each do |vol, ports|
          Facter.add("gluster_volume_#{vol}_ports".to_sym) do
            setcode do
              ports
            end
          end
        end
      end
    end
  end
end
