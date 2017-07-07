require 'dotenv/load'

require 'active_support/all'
require 'colorize'
require 'open3'

require_relative 'lib/util'

include Util

apps = %w[taskd znc]

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

    task :bounce do
      ansible "#{app}/bounce.yml"
    end
  end
end

namespace :ca do
  conf = 'files/pki/openssl.conf'
  ca_key = 'files/pki/private/cakey.pem'
  ca_cert = 'files/pki/cacert.pem'

  task :root do
    system 'openssl', 'req', '-x509', '-newkey', 'rsa:4096', '-keyout',
      ca_key, '-new', '-nodes', '-sha256', '-subj', '/CN=Adrien Katsuya Tateno',
      '-out', ca_cert

    encrypt ca_key
    encrypt ca_cert
  end

  task :csr, %i[file_root common_name] do |_t, args|
    args.with_defaults(common_name: File.basename(args[:file_root]))
    csr = "#{args[:file_root]}.csr"
    key = "#{args[:file_root]}.key.pem"

    system 'openssl', 'req', '-newkey', 'rsa:4096', '-keyout', key, '-new',
      '-nodes', '-out', csr, '-subj', "/CN=#{args[:common_name]}"
  end

  task :sign, [:file_root] do |_t, args|
    cert = "#{args[:file_root]}.cert.pem"
    csr = "#{args[:file_root]}.csr"

    with_decrypted ca_cert, ca_key do
      system 'openssl', 'ca', '-config', conf, '-in', csr, '-out', cert,
        '-notext', '-batch'
    end

    serial = File.read('files/pki/serial.old').chomp
    serial_cert = "files/pki/newcerts/#{serial}.pem"

    encrypt cert
    encrypt serial_cert
  end

  task :revoke, [:serial] do |_t, args|
    serial_cert = "files/pki/newcerts/#{args[:serial]}.pem"
    crl = 'files/pki/crl.pem'

    with_decrypted ca_cert, ca_key, serial_cert do
      system 'openssl', 'ca', '-config', conf, '-revoke', serial_cert
      system 'openssl', 'ca', '-config', conf, '-gencrl', '-out', crl
    end

    encrypt crl
  end
end

task :setup do
  ansible 'setup.yml'
end

task default: apps.flat_map { |app| ["#{app}:build", "#{app}:push"] }
