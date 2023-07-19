# frozen_string_literal: true

require_relative "../utils/project"
require_relative "../case/dsl/macro"
require_relative "../case/result/result"
require_relative "show"
require_relative "dsl/all"
require_relative "builtin"

class Checker
  include DSL # Include case/DSL/macro functions only
  include CheckDSL

  attr_reader :result

  def initialize(script_path, config_path)
    @path = {}
    @path[:script] = script_path
    @path[:dirname] = File.dirname(script_path)
    @path[:filename] = File.basename(script_path, ".rb")
    @path[:config] = config_path
    reset
  end

  def reset
    @result = Result.new
    @targetid = 0
    @stats = {
      groups: 0,
      targets: 0,
      hosts: {},
      uniques: 0,
      logs: 0,
      gets: 0,
      sets: [],
      uploads: []
    }
    @gets = {}
    @sets = {}
    @uploads = {}
    @verbose = Project.value[:verbose]
    @target_begin = nil
  end
end
