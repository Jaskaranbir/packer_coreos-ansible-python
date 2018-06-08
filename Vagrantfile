# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'

Vagrant.require_version ">= 1.6.0"

# CoreOS doesn't support vboxsf annd guest-additions for virtualbox
# So we need to use NFS, and Vagrant NFS doesn't work without this
plugin_dependencies = [
  "vagrant-winnfsd"
]

needsRestart = false

# Install plugins if required
plugin_dependencies.each do |plugin_name|
  unless Vagrant.has_plugin? plugin_name
    system("vagrant plugin install #{plugin_name}")
    needsRestart = true
    puts "#{plugin_name} installed"
  end
end

# Restart vagrant if new plugins were installed
if needsRestart === true
  exec "vagrant #{ARGV.join(' ')}"
end

# Defaults for config options
$num_instances = 1
$instance_name_prefix = "core"
$enable_serial_logging = false
$share_home = false
$vm_gui = false
$vm_memory = 1024
$vm_cpus = 1
$vb_cpuexecutioncap = 80
$user_home_path = "/home/core"
$forwarded_ports = []
$shared_folders = [
  {
    host_path: "./",
    guest_path: "/vagrant"
  }
]

# Attempt to apply the deprecated environment variable NUM_INSTANCES to
# $num_instances while allowing config.rb to override it
if ENV["NUM_INSTANCES"].to_i > 0 && ENV["NUM_INSTANCES"]
  $num_instances = ENV["NUM_INSTANCES"].to_i
end

# Use old vb_xxx config variables when set
def vm_gui
  $vb_gui.nil? ? $vm_gui : $vb_gui
end

def vm_memory
  $vb_memory.nil? ? $vm_memory : $vb_memory
end

def vm_cpus
  $vb_cpus.nil? ? $vm_cpus : $vb_cpus
end

Vagrant.configure("2") do |config|
  # always use Vagrants insecure key
  config.ssh.insert_key = false
  # forward ssh agent to easily ssh into the different machines
  config.ssh.forward_agent = true

  config.vm.box = "jaskaranbir/coreos-ansible"

  config.vm.provider :virtualbox do |v|
    # On VirtualBox, we don't have guest additions or a functional vboxsf
    # in CoreOS, so tell Vagrant that so it can be smarter.
    v.check_guest_additions = false
    v.functional_vboxsf     = false
  end

  # plugin conflict
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

  (1..$num_instances).each do |i|
    config.vm.define vm_name = "%s-%02d" % [$instance_name_prefix, i] do |config|
      config.vm.hostname = vm_name

      # Automatically set current-dir to /vagrant on vagrant ssh
      config.vm.provision :shell,
          inline: "echo 'cd /vagrant' >> #{$user_home_path}/.bashrc"

      if $enable_serial_logging
        logdir = File.join(File.dirname(__FILE__), "log")
        FileUtils.mkdir_p(logdir)

        serialFile = File.join(logdir, "%s-serial.txt" % vm_name)
        FileUtils.touch(serialFile)

        config.vm.provider :virtualbox do |vb, override|
          vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
          vb.customize ["modifyvm", :id, "--uartmode1", serialFile]
        end
      end

      # $expose_docker_tcp should be the number representing
      # host port to forward docker_tcp to
      if $expose_docker_tcp
        config.vm.network "forwarded_port",
            guest: 2375,
            host: ($expose_docker_tcp + i - 1),
            host_ip: "127.0.0.1",
            auto_correct: true
      end

      $forwarded_ports.each do |port|
        config.vm.network "forwarded_port",
            port[:host_port],
            port[:guest_port],
            auto_correct: true
      end

      config.vm.provider :virtualbox do |vb|
        vb.gui = vm_gui
        vb.memory = vm_memory
        vb.cpus = vm_cpus
        vb.customize [
          "modifyvm", :id,
          "--cpuexecutioncap", "#{$vb_cpuexecutioncap}"
        ]
      end

      ip = "172.17.8.#{i+100}"
      config.vm.network :private_network, ip: ip

      $shared_folders.each_with_index do |share, index|
        config.vm.synced_folder share[:host_path], share[:guest_path],
            id: "core-share%02d" % index,
            nfs: true,
            mount_options: ['nolock,vers=3,udp']
      end

      if $share_home
        config.vm.synced_folder ENV['HOME'],
            ENV['HOME'],
            id: "home",
            :nfs => true,
            :mount_options => ['nolock,vers=3,udp']
      end
    end
  end
end
