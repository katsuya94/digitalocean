require "dotenv/load"

def shell(*args)
  puts "shell: #{args}"
  system *args
end

def shell_check(check, *args)
  if check.to_s == "false"
    shell *args
  else
    shell *args, "--check"
  end
end

apps = %w(taskd)

apps.each do |app|
  namespace app do
    repository = "katsuya94/#{app}"
    image = "#{repository}:latest"

    task :build do
      shell "docker", "build", app, "-t", image
    end

    task :push do
      shell "docker", "push", image
    end

    task :deploy, [:user, :private_key_path, :check] do |_t, args|
      args.with_defaults(check: true)
      shell_check args[:check], "ansible-playbook", "-i", "hosts.rb",
        "#{app}/deploy.yml", "--user", args[:user], "--private-key",
        args[:private_key_path], "--ask-become-pass"
    end
  end
end

namespace :taskd do
  task :certificate, [:hostname] do |_t, args|
    fqdn = `./hosts.rb --ip #{args[:hostname]}`.chomp
    key = "files/taskd/#{fqdn}-server.key.pem"
    certificate = "files/taskd/#{fqdn}-server.cert.pem"

    shell "openssl", "req", "-newkey", "rsa:2048", "-nodes", "-keyout", key,
      "-x509", "-out", certificate, "-subj", "/CN=#{fqdn}"

    shell "ansible-vault", "encrypt", key
    shell "ansible-vault", "encrypt", certificate
  end
end

namespace :ca do
  ca_key = "ca/ca.key.pem"
  ca_cert = "ca/ca.cert.pem"

  task :root do
    shell "openssl", "req", "-x509", "-newkey", "rsa:4096", "-keyout",
      ca_key, "-new", "-nodes", "-sha256", "-days", "1024", "-subj",
      "/CN=Adrien Katsuya Tateno", "-out", ca_cert
    
    shell "ansible-vault", "encrypt", ca_cert
  end

  task :sign, [:file, :common_name] do |_t, args|
    key = "files/pki"
    shell "openssl", "req", "-x509", "-newkey", "rsa:4096", "-keyout",
      ca_key, "-new", "-nodes", "-sha256", "-days", "1024", "-subj",
      "/CN=Adrien Katsuya Tateno", "-out", ca_cert
    
    shell "ansible-vault", "encrypt", ca_cert
end

task :setup, [:user, :private_key_path, :check] do |_t, args|
  args.with_defaults(check: true)
  shell_check args[:check], "ansible-playbook", "-i", "hosts.rb", "setup.yml",
    "--user", args[:user], "--private-key", args[:private_key_path],
    "--ask-become-pass"
end

task :default => apps.flat_map { |app| ["#{app}:build", "#{app}:push"] }
