require_relative "../utils/project"
require_relative "../utils/configfile_reader"
require_relative "../case/result/result"
require_relative "../version"
require_relative "dsl"
require_relative "lang"

def use(filename)
  filename += ".rb"
  rbfiles = File.join(Project.value[:project_path], "**", filename)
  files = Dir.glob(rbfiles)
  use = []
  files.sort.each { |f| use << f if f.include?(filename) }
  require_relative use[0]
  Project.value[:uses] << use[0]
end

def define_macro(name, *args, &block)
  puts "macro: #{name}"
  Project.value[:macros][name] = {args: args, block: block}
end

def group(name, &block)
  Project.value[:groups] << {name: name, block: block}
end
alias task group

def start(&block)
  # don't do nothing
end
# alias_method "play", "start" # REVISE THIS
alias play start

class Readme
  # Creates README.md file from RB script file
  attr_reader :result
  attr_reader :data

  def initialize(script_path, config_path)
    # script_path Path to main rb file (start.rb)
    # config_path Path to main config file (config.yaml)
    @path = {}
    @path[:script] = script_path
    @path[:dirname] = File.dirname(script_path)
    @path[:filename] = File.basename(script_path, ".rb")
    @path[:config] = config_path
    reset
  end

  def show
    process_content
    show_head
    show_content
    show_tail
  end

  private

  def reset
    # app = Application.instance
    @config = ConfigFileReader.read(Project.value[:config_path])
    @verbose = Project.value[:verbose]
    @result = Result.new
    @data = {}
    @data[:macros] = []
    @data[:logs] = []
    @data[:groups] = []
    @data[:play] = []
    reset_action
    @setted_params = {}
    @cases_params = []
    @global_params = {}
    @required_hosts = {}
  end

  def process_content
    Project.value[:groups].each do |g|
      @current = {name: g[:name], readme: [], actions: []}
      @data[:groups] << @current
      reset_action
      instance_eval(&g[:block])
    end
  end

  def reset_action
    @action = {readme: []}
  end

  def show_head
    puts "```"
    puts format(Lang.get(:testname), Project.value[:test_name])
    puts format(Lang.get(:date), Time.now)
    puts format(Lang.get(:version), Teuton::VERSION)
    puts "```"
    puts "\n"
    puts "# #{Project.value[:test_name]}\n"

    i = 1
    unless @required_hosts.empty?
      puts Lang.get(:hosts)
      puts "\n"
      puts "| ID | Host | Configuration |"
      puts "| --- | --- | --- |"
      @required_hosts.each_pair do |k, v|
        c = []
        v.each_pair { |k2, v2| c << "#{k2}=#{v2}" }
        puts "| #{i} | #{k.upcase} | #{c.join(", ")} |"
        i += 1
      end
      puts "\n> NOTE: SSH Service installation is required on every host."
    end

    unless @cases_params.empty?
      @cases_params.sort!
      puts Lang.get(:params)
      @cases_params.uniq.each { |i| puts format("* %s", i) }
      puts "\n> NOTE: Save every 'param: value' into config file."
    end
  end

  def show_content
    @data[:groups].each do |group|
      next if group[:actions].empty?

      puts "\n## #{group[:name].capitalize}\n\n"
      group[:readme].each { |line| puts "#{line}\n" }
      previous_host = nil
      group[:actions].each_with_index do |item, index|
        if item[:host].nil? && index.positive?
          item[:host] = group[:actions][0][:host]
        end
        if previous_host.nil? || item[:host] != previous_host
          previous_host = item[:host] || "null"
          puts format(Lang.get(:goto), previous_host.upcase)
        end

        weight = ""
        weight = "(x#{item[:weight]}) " if item[:weight].to_i != 1
        last = (item[:target].end_with?(".") ? "" : ".")
        puts "* #{weight}#{item[:target]}#{last}"
        item[:readme].each { |line| puts "    * #{line}\n" }
      end
    end
  end

  def show_tail
    return if @global_params.empty?

    puts "\n---"
    puts "# ANEXO"
    puts "\n## Global params"
    puts Lang.get(:global)
    puts "\n"
    puts "| Global param | Value |"
    puts "| --- | --- |"
    @global_params.each_pair { |k, v| puts "|#{k}|#{v}|" }
    puts "\n## Created params"
    puts Lang.get(:created)
    puts "\n"
    puts "| Created params | Value |"
    puts "| --- | --- |"
    @setted_params.each_pair { |k, v| puts "|#{k}|#{v}|" }
  end
end
