#!/usr/bin/env ruby
#
require 'rbvmomi'
require 'optparse'

hash_options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: your_app [options]"
  opts.on('-n [ARG]', '--name [ARG]', "Specify the argument name") do |v|
    hash_options[:name] = v
  end
  opts.on('-l', '--list', "Liste toutes les vm avec IP associé") do |v|
    hash_options[:list] = v
  end
  opts.on('-h', '--help', 'Display this help') do 
    puts opts
    exit
  end
end.parse!

#p hash_options
#p ARGV

vim = RbVmomi::VIM.connect ssl: true, insecure: true, host: '%%dns_vcenter%%', user: '%%user%%', password: '%%password%%'
dc = vim.serviceInstance.find_datacenter("ADUNEO Datacenter") or fail "datacenter not found"
rootFolder = vim.serviceInstance.content.rootFolder
#vm=vim.serviceInstance.find_datacenter.find_vm("Glendale") or abort ("VM Not Found!")
#puts vm

$ip_list = {}

def ip_search(folder)
   folder.childEntity.each do |x|
      name, junk = x.to_s.split('(')
      case name
      when "Folder"
         ip_search(x)
      when "VirtualMachine"
        #puts x.name,x.guest_ip
        $ip_list["#{x.name}"] = x.guest_ip
      end
   end
end

# on lance la fonction ip_search
ip_search(dc.vmFolder)

vm_name = hash_options[:name]
puts $ip_list[vm_name]

def vms(folder) # recursively go thru a folder, dumping vm info
   folder.childEntity.each do |x|
      name, junk = x.to_s.split('(')
      case name
      when "Folder"
         vms(x)
         puts "=== dossier #{x.name}"
      when "VirtualMachine"
         puts x.name,x.guest_ip 
      else
         puts "# Unrecognized Entity " + x.to_s
      end
   end
end

# on list les vm
if hash_options.has_key?(:list) 
    puts vms(dc.vmFolder)
end

#puts vms(dc.vmFolder)
