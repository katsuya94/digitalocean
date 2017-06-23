module Util
  def info(msg)
    puts '[info] '.green + msg
  end

  def fatal(_msg)
    puts '[fatal] '.red + args.map(&:inspect).join(' ') + ' exited with '\
      "status #{exit_status}"
    exit 1
  end

  def system(*args)
    puts '[system] '.green + args
      .map { |s| '"'.green + s.inspect[1..-2] + '"'.green }.join(' ')

    exit_status = nil

    Open3.popen3(*args) do |_, stdout, stderr, wait_thr|
      out_thr = Thread.new do
        while line = stdout.gets
          puts line
        end
      end

      err_thr = Thread.new do
        while line = stderr.gets
          puts line.red
        end
      end

      out_thr.join
      err_thr.join
      exit_status = wait_thr.value
    end

    return if exit_status.to_i.zero?

    fatal args.map(&:inspect).join(' ') + " exited with status #{exit_status}"
  end

  def ansible(playbook)
    %w[PB_USER PB_PRIVATE_KEY].each do |env|
      fatal "#{env} not present" unless ENV[env].present?
    end

    *args = 'ansible-playbook', '-i', 'hosts.rb', playbook, '--user',
      ENV['PB_USER'], '--private-key', ENV['PB_PRIVATE_KEY'],
      '--ask-become-pass'

    if ENV['PB_CHECK'] == 'false'
      info 'running in check mode (run with PB_CHECK=false to disable)'
      system *args
    else
      system *args, '--check'
    end
  end

  def encrypt(path)
    system 'ansible-vault', 'encrypt', path
  end

  def with_decrypted(path)
    system 'ansible-vault', 'decrypt', path
    yield
  ensure
    system 'ansible-vault', 'encrypt', path
  end
end
