require "rubygems"
require "bundler"
Bundler.setup
Bundler.require

task :default => :test

desc 'run all tests (in current ruby)'
task :test do
  skip = ENV['SKIP'] || ENV['skip']
  Dir["./test/**/*_test.rb"].each do |test_file|
    begin
      require test_file unless skip && /#{skip}/ =~ test_file
    rescue Exception => e
      puts "Exception while requiring #{test_file}: #{e.inspect}"
      raise e
    end
  end

#  MiniTest::Unit.new.run  # not needed due to MiniTest::Unit.autorun in test_helper.rb
end

desc 'run all tests (in current ruby) one at a time'
task :suite do
  puts "#{ENV['RUBY_VERSION']} - #{`which ruby`}"
  sh "ruby test/suite.rb"
end

def clear_bundler_env
  # Bundler inherits its environment by default, so clear it here
  %w{BUNDLE_PATH BUNDLE_BIN_PATH BUNDLE_GEMFILE}.each { |var| ENV.delete(var) }
end

namespace :rvm do

  @rubies='1.8.6,1.8.7,1.9.1,1.9.2,jruby'

  def rvm
    rvm = `which rvm`.strip
    raise 'rvm not available; go to http://rvm.beginrescueend.com' unless rvm
    rvm
  end

  def rvm_run(cmd)
    clear_bundler_env
    @rubies.split(',').each do |version|
      puts "\n== Using #{version}"
      using = `#{rvm} use #{version}`
      if using =~ /not installed/
        puts "== #{using}"
      else
        system "#{rvm} #{version} exec bundle check"
        if $?.exitstatus != 0
          puts "try rake rvm:install_bundler or rake rvm:install_gems"
        end

        system "#{rvm} #{version} exec #{cmd}"
        if $?.exitstatus == 7
          puts "try rake rvm:install_gems"
        elsif $?.exitstatus == 1
          # uh...
        end
      end
    end
  end

  desc "run all tests with rvm in #{@rubies}"
  task :test do
    rvm_run "rake test"
    rvm_run "ruby ./test/suite.rb"
    # todo: fail if any test failed
    # todo: figure out a way to run suite with jruby --1.9 (it's harder than you'd think)
  end

  desc "run 'bundle install' with rvm in each of #{@rubies}"
  task :install_gems do
    rvm_run("bundle install")
  end

  desc "run 'gem install bundler' with rvm in each of #{@rubies}"
  task :install_bundler do
    rvm_run("gem install bundler")
  end
end

def load_gemspec(gemspec_name)
  gemspec_file = File.expand_path("../#{gemspec_name}.gemspec", __FILE__)
  gemspec = eval(File.read(gemspec_file), binding, gemspec_file)
end

def gemspecs
  @gemspecs ||= [load_gemspec("siesta")]
end

desc "Build pkg/#{gemspecs.first.full_name}.gem"
task :build => "gemspec:validate" do
  FileUtils.mkdir_p "pkg"
  gemspecs.each do |gemspec|
    sh %{gem build #{gemspec.name}#{"-" + gemspec.platform.to_s unless gemspec.platform == Gem::Platform::RUBY}.gemspec}
    FileUtils.mv gemspec.file_name, "pkg"
  end
end

desc "Install the latest built #{gemspecs.first.name} gem"
task :install => :build do
  sh "gem install --local pkg/#{gemspecs.first.file_name}"
end

namespace :gemspec do
  desc 'Validate the gemspecs'
  task :validate do
    gemspecs.map(&:validate)
  end
end

desc "Release the current branch to GitHub and Gemcutter"
task :release => %w(release:tag release:gem)

namespace :release do
  task :tag do
    gemspec = gemspecs.first
    release_tag = "v#{gemspec.version}"
    sh "git tag -a #{release_tag} -m 'Tagging #{release_tag}'"
    sh "git push origin #{release_tag}"
  end

  task :gem => :build do
    gemspecs.each do |gemspec|
      sh "gem push pkg/#{gemspec.file_name}"
    end
  end
end
