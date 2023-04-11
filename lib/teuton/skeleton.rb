require "fileutils"
require "rainbow"

class Skeleton
  def create(project_dir)
    project_name = File.basename(project_dir)
    puts "\nCreating #{Rainbow(project_name).bright} project"
    source_basedir = File.dirname(__FILE__)
    create_dir project_dir
    create_main_dir_and_files(project_dir, source_basedir)
  end

  private

  def create_main_dir_and_files(project_dir, source_basedir)
    # Directory and files: Ruby script, Configfile, gitignore
    items = [
      {source: "files/config.yaml", target: "config.yaml"},
      {source: "files/start.rb", target: "start.rb"}
    ]
    items.each do |item|
      source = File.join(source_basedir, item[:source])
      target = File.join(project_dir, item[:target])
      copyfile(source, target)
    end
  end

  def create_dir(dirpath)
    if Dir.exist? dirpath
      puts "* Exists dir!       => #{Rainbow(dirpath).yellow}"
    else
      begin
        FileUtils.mkdir_p(dirpath)
        puts "* Create dir        => #{Rainbow(dirpath).green}"
      rescue
        puts "* Create dir  ERROR => #{Rainbow(dirpath).red}"
      end
    end
  end

  def copyfile(source, dest)
    if File.exist? dest
      puts "* Exists file!      => #{Rainbow(dest).yellow}"
    else
      puts "* File not found!   => #{Rainbow(source).yellow}" unless File.exist? source
      begin
        FileUtils.cp(source, dest)
        puts "* Create file       => #{Rainbow(dest).green}"
      rescue
        puts "* Create file ERROR => #{Rainbow(dest).red}"
      end
    end
  end
end
