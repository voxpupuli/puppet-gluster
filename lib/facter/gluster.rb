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
  require 'rexml/document'

  peer_status = REXML::Document.new(Facter::Util::Resolution.exec("#{binary} peer status --xml"))
  peers = REXML::XPath.match(peer_status, '/cliOutput/peerStatus/peer/hostname/text()')
  peer_count = peers.size
  if peer_count > 0
    peer_list = peers.join(',')
    volumes = REXML::Document.new(Facter::Util::Resolution.exec("#{binary} volume info --xml"))
    REXML::XPath.match(volumes, '/cliOutput/volInfo/volumes/volume').each do |vol|
      vol_name = vol.elements['name'].text
      vol_status = vol.elements['statusStr'].text
      bricks = REXML::XPath.match(vol, 'bricks/brick/name/text()')
      volume_bricks[vol_name] = bricks
      options = REXML::XPath.match(vol, 'options/option').map { |option| "#{option.elements['name'].text}: #{option.elements['value'].text}" }
      volume_options[vol_name] = options if options
      next unless vol_status == 'Started'
      status = REXML::Document.new(Facter::Util::Resolution.exec("#{binary} volume status #{vol_name} --xml"))
      volume_ports[vol_name] = REXML::XPath.match(status, "/cliOutput/volStatus/volumes/volume/node[starts-with(hostname/text(), '#{Facter.value('hostname')}')]/port/text()")
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
      # rubocop:disable Metrics/BlockNesting
      if volume_options
        volume_options.each do |vol, opts|
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
    end
  end
end
