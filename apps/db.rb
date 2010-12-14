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
