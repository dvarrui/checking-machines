require "rainbow"
require_relative "default/colored_text"
require_relative "default/html"
require_relative "default/json"
require_relative "default/txt"
require_relative "default/xml"
require_relative "default/yaml"
require_relative "resume/colored_text"
require_relative "resume/html"
require_relative "resume/json"
require_relative "resume/txt"
require_relative "resume/yaml"
require_relative "moodle_csv_formatter"

module Formatter
  def self.call(report, options, filename)
    klass = get(options[:format])
    if klass.nil?
      puts Rainbow("[ERROR] Unkown format: #{options[:format]}").red
      puts Rainbow("        export format: FORMAT").red
      exit 1
    end
    formatter = klass.new(report)
    formatter.init(filename)
    formatter.process(options)
  end

  def self.get(format)
    list = {
      colored_text: ColoredTextFormatter,
      html: HTMLFormatter,
      json: JSONFormatter,
      txt: TXTFormatter,
      xml: XMLFormatter,
      yaml: YAMLFormatter,
      moodle_csv: MoodleCSVFormatter,
      resume_html: ResumeHTMLFormatter,
      resume_json: ResumeJSONFormatter,
      resume_txt: ResumeTXTFormatter,
      resume_xml: ResumeTXTFormatter, # TODO
      resume_yaml: ResumeYAMLFormatter
    }
    list[format]
  end

  def self.hide_feedback(report)
    report2 = report.clone
    report2.groups.each do |group|
      group.each do |item|
        puts item.to_s
      end
    end
  end
end
