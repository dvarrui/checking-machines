require "terminal-table"
require "rainbow"

require_relative "../utils/project"
require_relative "../utils/configfile_reader"

class Checker
  private

  def verbose(text)
    print text if @verbose
  end

  def verboseln(text)
    puts text if @verbose
  end

  def find_script_vars
    script_vars = [:tt_members]
    @stats[:hosts].each_key do |k|
      next if k == :localhost

      if k.instance_of? Symbol
        script_vars << (k.to_s + "_ip").to_sym
        script_vars << (k.to_s + "_username").to_sym
        script_vars << (k.to_s + "_password").to_sym
      else
        script_vars << k.to_s + "_ip"
        script_vars << k.to_s + "_username"
        script_vars << k.to_s + "_password"
      end
    end
    @gets.each_key { |k| script_vars << k }
    script_vars
  end

  def recomended_config_content
    warn Rainbow("[WARN] Configfile not found").bright.yellow
    warn Rainbow("       #{@path[:config]}").white
    warn Rainbow("[INFO] Recomended content:").bright.yellow
    output = {global: nil, cases: []}
    output[:cases][0] = {}
    script_vars = find_script_vars
    script_vars.each { |i| output[:cases][0][i] = "VALUE" }
    verboseln Rainbow(YAML.dump(output)).white
  end

  def recomended_panelconfig_content
    output = {global: nil, cases: [{}]}
    script_vars = find_script_vars
    # script_vars.each { |i| output[:global][i] = "VALUE" }
    script_vars.each { |i| output[:cases][0][i] = "VALUE" }
    verboseln YAML.dump(output)
  end

  def revise_config_content
    unless File.exist?(@path[:config])
      recomended_config_content
      return
    end

    script_vars = find_script_vars
    config_vars = ConfigFileReader.read(@path[:config])
    config_vars[:global]&.each_key { |k| script_vars.delete(k) }
    config_vars[:alias]&.each_key { |k| script_vars.delete(k) }

    config_vars[:cases].each_with_index do |item, index|
      next if item[:tt_skip] == true

      script_vars.each do |value|
        next unless item[value].nil?

        setted = false
        @stats[:sets].each do |assign|
          setted = true if assign.include?(":#{value}=")
        end

        unless setted
          verbose Rainbow("  * Define ").red
          verbose Rainbow(value).red.bright
          verbose Rainbow(" value for Case[").red
          verbose Rainbow(index).red.bright
          verboseln Rainbow("] or set tt_skip = true").red
        end
      end
    end
  end

  ##
  # Display stats on screen
  def show_stats
    my_screen_table = Terminal::Table.new do |st|
      st.add_row ["DSL Stats", "Count"]
      st.add_separator

      if Project.value[:uses].size.positive?
        st.add_row ["Uses", Project.value[:uses].size]
      end
      if Project.value[:macros].size.positive?
        st.add_row ["Macros", Project.value[:macros].size]
        Project.value[:macros].each_key { st.add_row ["", _1] }
      end
      st.add_row ["Groups", @stats[:groups]]
      st.add_row ["Targets", @stats[:targets]]
      runs = @stats[:hosts].values.inject(0) { |acc, item| acc + item }
      st.add_row ["Runs", runs]
      @stats[:hosts].each_pair { |k, v| st.add_row [" * #{k}", v] }
      if @stats[:uniques].positive?
        st.add_row ["Uniques", @stats[:uniques]]
      end
      if @stats[:logs].positive?
        st.add_row ["Logs", @stats[:logs]]
      end

      if @stats[:gets].positive?
        st.add_row ["Gets", @stats[:gets]]
        if @gets.count > 0
          list = @gets.sort_by { |_k, v| v }
          list.reverse_each { |item| st.add_row [" * #{item[0]}", item[1].to_s] }
        end
      end

      if @stats[:sets].size.positive?
        st.add_row ["Sets", @stats[:sets].size]
        @stats[:sets].each { st.add_row ["", _1] }
      end
      if @stats[:uploads].size.positive?
        st.add_row ["Uploads", @stats[:uploads].size]
        @stats[:uploads].each { st.add_row ["", _1] }
      end
    end
    verboseln my_screen_table.to_s + "\n"
  end
end
