# frozen_string_literal: true

require_relative '../../application'
require_relative '../../case_manager/case/result'
require_relative 'dsl'

def group(name, &block)
  Application.instance.groups << { name: name, block: block }
end
alias task group

def start(&block)
  # don't do nothing
end
alias play start

# Creates README.md file from RB script file
class Readme
  attr_reader :result
  attr_reader :data

  def initialize(script_path, config_path)
    @path = {}
    @path[:script]   = script_path
    @path[:dirname]  = File.dirname(script_path)
    @path[:filename] = File.basename(script_path, '.rb')
    @path[:config]   = config_path
    reset
  end

  def reset
    @verbose = Application.instance.verbose
    @result = Result.new
    @data = {}
    @data[:logs] = []
    @data[:groups] = []
    @data[:play] = []
    @action = nil
  end

  def process_content
    Application.instance.groups.each do |g|
      @current = { name: g[:name], actions: []}
      @data[:groups] << @current
      instance_eval(&g[:block])
    end
  end

  def show
    process_content
    app = Application.instance
    puts '```'
    puts "Test name : #{app.test_name}"
    puts '```'
    puts '---'
    puts '# README.md'
    @data[:groups].each do |group|
      puts "\n## #{group[:name]}\n\n"
      host = nil
      group[:actions].each do |i|
        if i[:host] != host
          host = group[:actions][0][:host]
          puts "Go to host #{host.upcase}, and do next:"
        end
        puts "* #{i[:target]}"
      end
    end
  end
end