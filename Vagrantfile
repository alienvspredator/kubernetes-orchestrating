# frozen_string_literal: true

# -*- mode: ruby -*-
# vi: set ft=ruby :

# Virtual Machine configuration
class VmConfig
  attr_reader :name, :cpus, :memory

  # @param name [String]
  # @param cpus [Integer]
  # @param memory [Integer]
  def initialize(name:, cpus:, memory:)
    @name = name
    @cpus = cpus
    @memory = memory
  end
end

Vagrant.configure(2) do |config|
  config.vm.box = 'bento/ubuntu-20.04'
  config.vm.hostname = 'kubernetes'
  config.vm.provision 'shell', path: './provision.sh', privileged: false

  config.vm.synced_folder './data', '/home/vagrant/data'

  # Cockroachdb
  config.vm.network 'forwarded_port', {
    id: 'cockroach grpc',
    guest: 26_257,
    host: 26_257,
    auto_correct: true,
    host_ip: '127.0.0.1'
  }
  config.vm.network 'forwarded_port', {
    id: 'cockroach web-ui',
    guest: 8080,
    host: 8080,
    auto_correct: true,
    host_ip: '127.0.0.1'
  }

  # ElasticSearch stack
  # Kibana
  config.vm.network 'forwarded_port', {
    id: 'kibana',
    guest: 5601,
    host: 5601,
    auto_correct: true,
    host_ip: '127.0.0.1'
  }

  # kubectl proxy (for kubectl proxy --address 0.0.0.0 --disable-filter --port 8001)
  config.vm.network 'forwarded_port', {
    id: 'kubectl proxy',
    guest: 8001,
    host: 8001,
    auto_correct: true,
    host_ip: '127.0.0.1'
  }

  config.vm.network 'forwarded_port', {
    id: 'tgbot metrics',
    guest: 9090,
    host: 9090,
    auto_correct: true,
    host_ip: '127.0.0.1'
  }

  vm_config = VmConfig.new name: 'kubernetes', cpus: 4, memory: 1024 * 8

  # Increase memory for Parallels Desktop
  config.vm.provider 'parallels' do |p, _o|
    p.name = vm_config.name
    p.memory = vm_config.memory
    p.cpus = vm_config.cpus
  end

  # Increase memory for Virtualbox
  config.vm.provider 'virtualbox' do |vb|
    vb.name = vm_config.name
    vb.memory = vm_config.memory
    vb.cpus = vm_config.cpus
  end

  # Increase memory for VMware
  %w[vmware_fusion vmware_workstation].each do |p|
    config.vm.provider p do |v|
      v.vmx['memsize'] = vm_config.memory
      v.vmx['numvcpus'] = vm_config.cpus
    end
  end
end
