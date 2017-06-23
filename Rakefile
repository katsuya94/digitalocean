require 'dotenv/load'

require 'active_support/all'
require 'colorize'
require 'open3'

require_relative 'lib/util'

include Util

apps = %w[taskd]

apps.each do |app|
  namespace app do
    repository = "katsuya94/#{app}"
    image = "#{repository}:latest"

    task :build do
      system 'docker', 'build', app, '-t', image
    end

    task :push do
      system 'docker', 'push', image
    end

    task :deploy do
      ansible "#{app}/deploy.yml"
    end
  end
end

namespace :taskd do
  task :certificate, [:hostname] do |_t, args|
    fqdn = `./hosts.rb --ip #{args[:hostname]}`.chomp
    key = "files/taskd/#{fqdn}-server.key.pem"
    certificate = "files/taskd/#{fqdn}-server.cert.pem"

    system 'openssl', 'req', '-newkey', 'rsa:2048', '-nodes', '-keyout', key,
      '-x509', '-out', certificate, '-subj', "/CN=#{fqdn}"

    system 'ansible-vault', 'encrypt', key
    system 'ansible-vault', 'encrypt', certificate
  end
end

namespace :ca do
  ca_key = 'files/pki/ca.key.pem'
  ca_cert = 'files/pki/ca.cert.pem'

  task :root do
    system 'openssl', 'req', '-x509', '-newkey', 'rsa:4096', '-keyout',
      ca_key, '-new', '-nodes', '-sha256', '-subj', '/CN=Adrien Katsuya Tateno',
      '-out', ca_cert

    encrypt ca_key
    encrypt ca_cert
  end

  task :csr, [:file_root] do |_t, args|
    csr = "#{args[:file_root]}.csr"

    system 'openssl', 'req', '-newkey', 'rsa:4096', '-keyout', key, '-new',
      '-nodes', '-out', csr
  end

  task :sign, [:file_root] do |_t, args|
    cert = "#{args[:file_root]}.cert.pem"
    csr = "#{args[:file_root]}.csr"

    with_decrypted ca_cert do
      system 'openssl', 'ca', '-in', csr, '-cert', ca_cert, '-keyfile', ca_key,
        '-out', cert
    end

    system 'ansible-vault', 'encrypt', cert
  end
end

task :setup do
  ansible 'setup.yml'
end

task default: apps.flat_map { |app| ["#{app}:build", "#{app}:push"] }
