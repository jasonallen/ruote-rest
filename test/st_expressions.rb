
#
# Testing ruote-rest
#
# John Mettraux at OpenWFE dot org
#
# Mon Apr 14 15:45:00 JST 2008
#

require File.dirname(__FILE__) + '/testbase'


class StExpressionsTest < Test::Unit::TestCase

  include TestBase


  def test_0

    li = OpenWFE::LaunchItem.new <<-EOS
      class TestStExpressions < OpenWFE::ProcessDefinition
        sequence do
          alpha
          bravo
        end
      end
    EOS

    #p OpenWFE::Xml.launchitem_to_xml(li)

    post(
      "/processes",
      OpenWFE::Xml.launchitem_to_xml(li),
      { "CONTENT_TYPE" => "application/xml" })

    fei = OpenWFE::Xml.fei_from_xml @response.body

    sleep 0.350

    get "/expressions/#{fei.wfid}"
    #puts
    #puts @response.body
    #puts
    assert_not_nil @response.body.index(' count="4"')


    get "/expressions/#{fei.wfid}/0_0"

    assert_not_nil @response.body.index(
      '<class>OpenWFE::SequenceExpression</class>')

    get "/expressions/#{fei.wfid}/0e"
    #puts
    #puts @response.body
    #puts
    assert_not_nil(
      @response.body.index('<class>OpenWFE::Environment</class>'),
      "GET /0e --> not an environment")


    get "/expressions/#{fei.wfid}/0"

    assert_not_nil(
      @response.body.index('<class>OpenWFE::DefineExpression</class>'),
      "GET /0e --> not an 'process-definition'")

    #
    # cancel process

    delete "/expressions/#{fei.wfid}/0"

    assert_equal 200, @response.status

    sleep 0.350

    # done.
  end

  def test_1

    li = OpenWFE::LaunchItem.new %{
      class TestStExpressions < OpenWFE::ProcessDefinition
        sequence do
          nada
          surf
        end
      end
    }

    post(
      '/processes',
      OpenWFE::Xml.launchitem_to_xml(li),
      { 'CONTENT_TYPE' => 'application/xml' })

    fei = OpenWFE::Xml.fei_from_xml(@response.body)

    sleep 0.350

    get "/expressions/#{fei.wfid}/0_0_0?format=yaml"

    #puts @response.body
    assert_equal 'application/yaml', @response['Content-Type']

    exp = YAML.load @response.body
    assert_kind_of OpenWFE::FlowExpression, exp

    exp.attributes = { :toto => :surf }

    put(
      "/expressions/#{fei.wfid}/0_0_0",
      exp.to_yaml,
      { 'CONTENT_TYPE' => 'application/yaml' })

    assert_equal 200, @response.status

    # GET expression as yaml

    get(
      "/expressions/#{fei.wfid}/0_0_0",
      nil,
      { 'HTTP_ACCEPT' => 'application/yaml' })

    exp = YAML.load @response.body

    assert_equal :surf, exp.attributes[:toto]

    # GET expression/tree as json

    get(
      "/expressions/#{fei.wfid}/0_0_0/tree",
      nil,
      { 'HTTP_ACCEPT' => 'application/json' })

    #puts @response.body

    assert_equal ['nada', {}, []], json_parse(@response.body)

    # GET some expression not yet active

    get(
      "/expressions/#{fei.wfid}/0_0_1/tree",
      nil,
      { 'HTTP_ACCEPT' => 'application/json' })

    assert_equal 404, @response.status

    # PUT some other expression/tree

    put(
      "/expressions/#{fei.wfid}/0_0/tree",
      '["sequence", {}, [["nada", {}, []], ["surfbis", {}, []]]]',
      { 'CONTENT_TYPE' => 'application/json' })

    #puts @response.body

    assert_equal 200, @response.status

    get(
      "/expressions/#{fei.wfid}/0_0/tree",
      nil,
      { 'HTTP_ACCEPT' => 'application/json' })

    #puts @response.body

    # TODO : add test for form input !!!!!!!!!!!!!!!!!!!!!!!!

    assert_equal(
      ["sequence", {}, [["nada", {}, []], ["surfbis", {}, []]]],
      json_parse(@response.body))

    assert_equal(
      ["process-definition",
       {"name"=>"TestStExpressions", "revision"=>"0"},
        [["sequence", {}, [["nada", {}, []], ["surfbis", {}, []]]]]],
      RuoteRest.engine.process_status(fei.wfid).all_expressions.tree)

    # over.

    RuoteRest.engine.cancel_process(fei)

    sleep 0.350
  end

  class UnreliableParticipant
    include OpenWFE::LocalParticipant

    def consume (workitem)
      @counter ||= 0
      @counter += 1
      reply_to_engine(workitem) if @counter == 2
    end
  end

  def test_reapply

    pdef = OpenWFE.process_definition :name => 'test_reapply' do
      sequence do
        theo
        bravo
      end
    end

    RuoteRest.engine.register_participant :theo, UnreliableParticipant

    fei = RuoteRest.engine.launch(pdef)

    sleep 0.350

    theo = RuoteRest.engine.process_status(fei.wfid).expressions.last.fei

    post(theo.href, '', {})

    #p @response.body
    assert_equal 200, @response.status

    sleep 0.350

    last = RuoteRest.engine.process_status(fei.wfid).expressions.last.fei
    assert_equal 'bravo', last.expname

    RuoteRest.engine.cancel_process(fei)
  end
end

