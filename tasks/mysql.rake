
namespace :mysql do

  desc "setting up the mysql database for ruote-rest"
  task :setup do

    #
    # created on a Shinkansen train ride to Tokyo (Nozomi)
    # (just before Shinagawa)
    #

    stage = ENV['stage']

    stage = 'development' \
      unless [ 'test', 'development', 'production' ].include?(stage)

    db = "ruoterest_#{stage}"
    dbadmin = ENV['dbadmin'] || "root"

    # drop

    sh "mysql -u #{dbadmin} -p -e \"drop database if exists #{db}\""

    # create

    sh "mysql -u #{dbadmin} -p -e \"create database #{db} CHARACTER SET utf8 COLLATE utf8_general_ci\""

    # run the migrations

    gem 'activerecord'
    require 'active_record'

    ActiveRecord::Base.establish_connection(
      :adapter => "mysql",
      :database => db,
      #:username => 'toto',
      #:password => 'secret',
      :encoding => "utf8")

    $:.unshift RUOTE_LIB

    require 'openwfe/extras/participants/activeparticipants'
    OpenWFE::Extras::WorkitemTables.up

    require 'openwfe/extras/expool/dbhistory'
    OpenWFE::Extras::HistoryTables.up

    #OpenWFE::Extras::ProcessErrorTables.up
    #OpenWFE::Extras::ExpressionTables.up
  end

end
