
namespace :ruote do

  RUFUSES = %w{ 
    dollar lru mnemo scheduler verbs sixjo treechecker
  }.collect { |e| "rufus-#{e}" }

  #
  # do use either ruote:install or ruote:gem_install
  # but not both
  #

  desc "Installs under vendor/ the latest source of OpenWFEru (and required subprojects)."
  task :install => :get_from_github do

    %w{
      activerecord ruby_parser atom-tools mongrel rack
    }.each do |gem|
      sh "sudo gem install --no-rdoc --no-ri #{gem}"
    end
  end

  task :get_from_github do

    mkdir 'tmp' unless File.exists?('tmp')

    rm_r 'vendor/openwfe' if File.exists?('vendor/openwfe')
    rm_r 'vendor/rufus' if File.exists?('vendor/rufus')
    mkdir 'vendor' unless File.exists?('vendor')

    RUFUSES.each { |e| git_clone(e) }
    git_clone 'ruote'
  end

  def git_clone (elt)

    chdir 'tmp' do
      sh "git clone git://github.com/jmettraux/#{elt}.git"
    end
    cp_r "tmp/#{elt}/lib/.", 'vendor/'
    rm_r "tmp/#{elt}"
  end

  desc "Install Ruote and its dependencies as gems"
  task :gem_install do

    GEMS = RUFUSES.dup

    GEMS << 'ruote'
    GEMS << 'activerecord'
    GEMS << 'atom-tools'
    GEMS << 'rack'
    GEMS << 'mongrel'

    sh "sudo gem install --no-rdoc --no-ri #{GEMS.join(' ')}"

    #puts
    #puts "installed gems  #{GEMS.join(' ')}"
    #puts
  end

  desc "Fetches ruote and all its dependencies, then puts the frozen gems under vendorf/"
  task :freeze do

    require File.dirname(__FILE__) + '/frigo'

    Frigo.verbose = true

    Frigo.fetch_with_dependencies('activerecord', nil, 'vendorf')
    Frigo.fetch_with_dependencies('rack', nil, 'vendorf')
    Frigo.fetch_with_dependencies('atom-tools', nil, 'vendorf')
    Frigo.fetch_with_dependencies('ruote', nil, 'vendorf')
  end
end

