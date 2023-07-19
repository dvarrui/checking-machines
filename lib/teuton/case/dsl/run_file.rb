require_relative "../../utils/project"
require_relative "../../utils/verbose"

module DSL
  def upload(localfile, args = {})
    localfilepath = if File.absolute_path? localfile
      localfile
    else
      File.join(Project.value[:project_path], localfile)
    end

    host = get_host(args[:to])
    if host.protocol == "ssh"
      begin
        remotefilepath = args[:remotefile] || localfile
        Net::SFTP.start(
          host.ip, host.username, password: host.password, port: host.port
        ) { |sftp| sftp.upload!(localfilepath, remotefilepath) }
        verbose(Rainbow("u").green)
      rescue => e
        log("Upload #{localfile} to #{host.ip}:#{remotefilepath}", :warn)
        log(e.to_s, :warn)
        verbose(Rainbow("!").green)
      end
    elsif host.protocol != "local"
      msg = Rainbow("==> [ERROR] run_file: Incorrect protocol(#{host.protocol})").red
      verboseln(msg)
    end
  end

  def run_file(script, args = {})
    items = script.split(" ")
    if items.size < 1
      msg = Rainbow("==> [ERROR] run_file: Incorrect argument(#{command})").red
      verboseln(msg)
      return
    end

    host = get_host(args[:on])
    if host.protocol == "local"
      items[1] = File.join(Project.value[:project_path], items[1])
      command = items.join(" ")
      run(command, args)
    elsif host.protocol == "ssh"
      remotefilepath = "tt_#{items[1].gsub(File::SEPARATOR, "_")}"
      upload items[1], remotefile: remotefilepath, to: host.id
      items[1] = "./#{remotefilepath}"
      command = items.join(" ")
      run(command, args)
    else
      msg = Rainbow("==> [ERROR] run_file: Incorrect protocol(#{host.protocol})").red
      verboseln(msg)
    end
  end
end