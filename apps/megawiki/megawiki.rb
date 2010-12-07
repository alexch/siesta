# sample read-write app with top-level resources
require 'bundler'
Bundler.setup

require 'erector'
require 'siesta'
require 'active_record'

########## Megawiki Domain

class Article < ActiveRecord::Base
  include Siesta::Resource
end

########## Megawiki Views

# The abstract page class for all Megawiki web pages.
# Subclasses should override #main.
class MegawikiPage < Erector::Widgets::Page
  external :style, <<-CSS
  body { margin: 0;}
  .nav { float: left; margin: .5em; padding: 1em; }
  .nav ul { list-style: none; }
  .main { padding: 0 1em 1em 12em; border-left: 1px solid black; }
  .header { border-bottom: 1px solid black; text-align: center; }
  .footer { clear: both; border-top: 1px solid black; text-align: center; }
  CSS

  needs :main_widget => nil

  def page_title
    "Megawiki: #{super}"
  end

  def body_content
    h1 "Megawiki", :class => "header"

    div :class => 'nav' do
      nav
    end

    div :class => 'main' do
      main
    end

    div :class => 'footer' do
      footer
    end
  end

  def nav
    ul do
      li { a "Home", :href => Home.path }
#      li { a "Create", :href => Article.path }
#      li { a "Edit", :href => Editorial.path }
#      li { a "Search", :href => Home.path }
    end
  end

  def main
    text "Please override "
    code "main"
    text " in "
    code self.class.name
  end

  def footer
    p do
      text "Copyright "
      rawtext "&copy;"
      text " 2010 by Alex Chaffee."
    end
    p "Feel free to copy this site or use it as insipration for your own apps."
  end

end

###########################################################################

class Home < MegawikiPage
  include Siesta::Resource
  resource :root

  def main_content
    text "TBD"
  end
end

###########################################################################

class ArticlePage < MegawikiPage
  include Siesta::Resource

  def main_content
    text "TBD"
  end
end

######################################################

# Helpful microframework stuff
require 'logger'
require 'fileutils'

module DB
  def self.config_for(environment)
    if ActiveRecord::Base.configurations.empty?
      dbconfig = YAML.load(File.read('config/database.yml'))
      ActiveRecord::Base.configurations = dbconfig
    end
    config = ActiveRecord::Base.configurations[environment.to_s]
    raise "Couldn't find database configuration for #{environment}" if config.nil?
    config
  end

  def self.connect_to(db_environment)
    puts "Connecting to #{db_environment} database"
    FileUtils.mkdir_p("log")
    ActiveRecord::Base.logger = Logger.new("log/#{db_environment}.log")
    ActiveRecord::Base.establish_connection config_for(db_environment)
  end

  def self.setup
    ActiveRecord::Base.connection.increment_open_transactions
    ActiveRecord::Base.connection.begin_db_transaction
  end

  def self.teardown
    if ActiveRecord::Base.connection.open_transactions != 0
      ActiveRecord::Base.connection.rollback_db_transaction
      ActiveRecord::Base.connection.decrement_open_transactions
    end
    ActiveRecord::Base.clear_active_connections!
  end

  def self.create(environment)
    config = config_for(environment)
    begin
      if config['adapter'] =~ /sqlite/
        if File.exist?(config['database'])
          $stderr.puts "#{config['database']} already exists"
        else
          begin
            # Create the SQLite database
            ActiveRecord::Base.establish_connection(config)
            ActiveRecord::Base.connection
          rescue
            $stderr.puts $!, *($!.backtrace)
            $stderr.puts "Couldn't create database for #{config.inspect}"
          end
        end
        return # Skip the else clause of begin/rescue
      else
        ActiveRecord::Base.establish_connection(config)
        ActiveRecord::Base.connection
      end
    rescue
      case config['adapter']
        when 'mysql'
          @charset = ENV['CHARSET'] || 'utf8'
          @collation = ENV['COLLATION'] || 'utf8_general_ci'
          begin
            ActiveRecord::Base.establish_connection(config.merge('database' => nil))
            ActiveRecord::Base.connection.create_database(config['database'], :charset => (config['charset'] || @charset), :collation => (config['collation'] || @collation))
            ActiveRecord::Base.establish_connection(config)
          rescue
            $stderr.puts "Couldn't create database for #{config.inspect}, charset: #{config['charset'] || @charset}, collation: #{config['collation'] || @collation} (if you set the charset manually, make sure you have a matching collation)"
          end
        when 'postgresql'
          @encoding = config[:encoding] || ENV['CHARSET'] || 'utf8'
          begin
            ActiveRecord::Base.establish_connection(config.merge('database' => 'postgres', 'schema_search_path' => 'public'))
            ActiveRecord::Base.connection.create_database(config['database'], config.merge('encoding' => @encoding))
            ActiveRecord::Base.establish_connection(config)
          rescue
            $stderr.puts $!, *($!.backtrace)
            $stderr.puts "Couldn't create database for #{config.inspect}"
          end
      end
    else
      $stderr.puts "#{config['database']} already exists"
    end
  end

  def self.migrate
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migrate", nil)
  end

end

DB.create(:development)
DB.connect_to(:development)
DB.migrate
