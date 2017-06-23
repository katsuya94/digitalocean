module Util
  def info(msg)
    puts '[info] '.green + msg
  end

  def fatal(msg)
    puts '[fatal] '.red + msg
    exit 1
  end

  def system(*args)
    puts '[system] '.green + format_command(*args, :green)

    exit_status = nil

    Open3.popen3(*args) do |_, stdout, stderr, wait_thr|
      out_thr = Thread.new do
        while line = stdout.gets
          puts color_line(line)
        end
      end

      err_thr = Thread.new do
        while line = stderr.gets
          puts line.red
        end
      end

      out_thr.join
      err_thr.join
      exit_status = wait_thr.value.to_i
    end

    return if exit_status.zero?

    fatal format_command(*args, :red) + " exited with status #{exit_status}"
  end

  def ansible(playbook)
    %w[PB_USER PB_PRIVATE_KEY].each do |env|
      fatal "#{env} not present" unless ENV[env].present?
    end

    *args = 'ansible-playbook', '-i', 'hosts.rb', playbook, '--user',
      ENV['PB_USER'], '--private-key', ENV['PB_PRIVATE_KEY'],
      '--ask-become-pass'

    if ENV['PB_CHECK'] == 'false'
      system *args
    else
      info 'running in check mode (run with PB_CHECK=false to disable)'
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

  private

  def color_line(line)
    case line
    when /^ok:/ then color_first_word(line, :green)
    when /^skipping:/ then color_first_word(line, :blue)
    when /^fatal:/ then color_first_word(line, :red)
    when /^changed:/ then color_first_word(line, :yellow)
    else line
    end
  end

  def color_first_word(line, color)
    colored_word = /(^\w+)/.match(line)[0].send(color)
    colored_word + line.gsub(/(^\w+)/, '')
  end

  def format_command(*args, color)
    quote = '"'.send(color)
    args.map { |s| quote + s.inspect[1..-2] + quote }.join(' ')
  end
end
