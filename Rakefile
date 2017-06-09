require "dotenv/load"
require "tempfile"

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
  end
end

namespace :taskd do
  task :certificate, [:fqdn] do |_t, args|
    key = "files/taskd/#{args[:fqdn]}-server.key.pem"
    certificate = "files/taskd/#{args[:fqdn]}-server.cert.pem"

    shell "openssl", "req", "-newkey", "rsa:2048", "-nodes", "-keyout", key,
      "-x509", "-out", certificate, "-subj", "/CN=#{args[:fqdn]}"

    shell "ansible-vault", "encrypt", key
    shell "ansible-vault", "encrypt", certificate
  end
end

namespace :ansible do
  task :setup, [:user, :private_key_path, :check] do |_t, args|
    args.with_defaults(check: true)
    shell_check args[:check], "ansible-playbook", "-i", "hosts.rb", "setup.yml",
      "--user", args[:user], "--private-key", args[:private_key_path],
      "--ask-become-pass"
  end

  task :app, [:user, :private_key_path, :check] do |_t, args|
    args.with_defaults(check: true)
    shell_check args[:check], "ansible-playbook", "-i", "hosts.rb", "app.yml",
      "--user", args[:user], "--private-key", args[:private_key_path],
      "--ask-become-pass"
  end
end

task :default => apps.flat_map { |app| ["#{app}:build", "#{app}:push"] }
