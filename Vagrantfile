# -*- mode: ruby -*-
# vi: set ft=ruby :

$vendor_id  = '0x067b'
$product_id = '0x2303'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"
VM_DISPLAY_NAME = "ESP8266-NodeMCU"
VM_HOSTNAME = "esp8266-nodemcu"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.hostname = VM_HOSTNAME
  config.vm.box = "chef/ubuntu-14.04"
  config.vm.provision :shell, path: "vm-bootstrap.sh", privileged: false

  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--usb', 'on']
    vb.customize ["modifyvm", :id, "--name", VM_DISPLAY_NAME]
    vb.name = VM_DISPLAY_NAME
    vb.customize ['usbfilter', 'add', '0', '--target', :id, '--name', 'USB_to_TTL_converter', '--vendorid', $vendor_id, '--productid', $product_id]
  end

end
