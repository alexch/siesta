module Siesta
  module Log
    def log msg
      puts "#{Time.now} - #{msg}" if Siesta::Config.verbose
    end
  end
end
