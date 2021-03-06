
require 'openwfe/engine'
require 'openwfe/engine/fs_engine'
require 'openwfe/extras/expool/db_history'
require 'openwfe/representations'


module RuoteRest

  def self.engine
    @engine
  end
  def self.engine= (e)
    @engine = e
  end

  configure do

    log_dir = File.join( RUOTE_BASE_DIR, 'logs' )
    FileUtils.mkdir log_dir unless File.exist?( log_dir )

    ac = {}

    ac[:engine_name] = 'ruote_rest'

    ac[:work_directory] = File.join( RUOTE_BASE_DIR, "work_#{$env}" )

    ac[:logger] = Logger.new "#{log_dir}/ruote_#{$env}.log", 10, 1024000
    ac[:logger].level = ($env == 'production') ? Logger::INFO : Logger::DEBUG

    ac[:remote_definitions_allowed] = true
      #
      # are [remote] process definitions pointed at via a URL allowed ?

    ac[:definition_in_launchitem_allowed] = true
      #
      # are process definitions embedded in the launchitem allowed ?
      #
      # (this is a dangerous, you really have to trust the clients)

    #
    # instantiating the workflow / BPM engine

    #engine_class = OpenWFE::Engine
      #
      # a transient, in-memory engine

    engine_class = OpenWFE::FsPersistedEngine
      #
      # file system based persistence

    engine = engine_class.new(ac)

    #engine.init_service(:s_history, OpenWFE::Extras::DbHistory)
    engine.init_service(:s_history, OpenWFE::Extras::QueuedDbHistory)
      #
      # tracking history

    #engine.reload; sleep 0.350
      #
      # let the engine reschedule/repause stuff in the expool
      # (now done at the end of conf/participants.rb)

    RuoteRest.engine = engine
  end
end

