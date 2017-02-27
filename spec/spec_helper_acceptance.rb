require 'puppet'
require 'beaker-rspec'
require 'yaml'

install_puppet_agent_on hosts, {}

RSpec.configure do |c|
  # Project root
  module_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  module_name = module_root.split('-').last

  # Readable test descriptions
  c.formatter = :documentation

  c.before :suite do
    # Install module and dependencies
    puppet_module_install(source: module_root, module_name: module_name)

    modules_fixtures = YAML.load_file(module_root + '/.fixtures.yml')
    modules = modules_fixtures['fixtures']['repositories']

    hosts.each do |host|
      modules.each do |_name, mod_url|
        mod_name = mod_url.split('/').last.sub('.git', '')
        on host, puppet('module', 'install', mod_name), acceptable_exit_codes: [0, 1]
      end
    end
  end
end
