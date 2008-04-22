
require 'openwfe/engine'
#require 'openwfe/engine/file_persisted_engine'
require 'openwfe/util/xml'

configure do

    ac = {}
    ac[:remote_definitions_allowed] = true
    ac[:definition_in_launchitem_allowed] = true

    # further configuration goes here

    $engine = OpenWFE::Engine.new ac
    #$engine = OpenWFE::FilePersistedEngine.new ac
end

