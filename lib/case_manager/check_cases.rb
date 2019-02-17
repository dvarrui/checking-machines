
class CaseManager

  private

  def check_cases!
    # Load configurations from yaml file
    configdata = ConfigFileReader.read(@app.config_path)
    @app.global = configdata[:global] || {}
    @app.global[:tt_testname] = @app.global[:tt_testname] || @app.test_name
    @app.global[:tt_sequence] = false if @app.global[:tt_sequence].nil?
    @caseConfigList = configdata[:cases]

    # Create out dir
    @outdir = @app.global[:tt_outdir] || File.join('var', @app.global[:tt_testname], 'out')
    ensure_dir @outdir
    @report.output_dir = @outdir

    # Fill report head
    open_main_report(@app.config_path)

    # create cases
    @caseConfigList.each { |lCaseConfig| @cases << Case.new(lCaseConfig) }
    start_time = Time.now
    if @app.global[:tt_sequence]
      verboseln "[INFO] Running in sequence (#{start_time})"
      @cases.each(&:start) # Process every case in sequence
    else
      verboseln "[INFO] Running in parallel (#{start_time})"
      threads = []
      @cases.each { |c| threads << Thread.new{ c.start } } # Running cases in parallel
      threads.each(&:join)
    end

    # Collect "unique" values from all cases
    uniques = {}
    @cases.each do |c|
      c.uniques.each do |key|
        if uniques[key].nil?
          uniques[key] = [c.id]
        else
          uniques[key] << c.id
        end
      end
    end

    # Close reports for all cases
    threads = []
    @cases.each { |c| threads << Thread.new { c.close uniques } }
    threads.each(&:join)

    # Build Hall of Fame
    @app.options[:case_number] = @cases.size
    @app.hall_of_fame = build_hall_of_fame
    close_main_report(start_time)
  end
end