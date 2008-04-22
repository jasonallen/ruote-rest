#
#--
# Copyright (c) 2008, John Mettraux, OpenWFE.org
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are met:
# 
# . Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.  
# 
# . Redistributions in binary form must reproduce the above copyright notice, 
#   this list of conditions and the following disclaimer in the documentation 
#   and/or other materials provided with the distribution.
# 
# . Neither the name of the "OpenWFE" nor the names of its contributors may be
#   used to endorse or promote products derived from this software without
#   specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
#++
#

#
# "made in Japan"
#
# John Mettraux at openwfe.org
#


#
# PROCESSES

def render_processes_xml (ps)

    builder do |xml|
        xml.instruct!
        xml.processes :count => ps.size do
            ps.each do |fei, process_status|
                _render_process_xml xml, process_status
            end
        end
    end
end

def render_processes_html (ps)

    builder do |html|

        html.div :class => "proc_processes" do

            html.h3 "Processes"

            if ps.size == 0
                html.p "none."
            else
                ps.each do |fei, process_status|
                    _render_process_html html, process_status
                end
            end
        end

        html.div :class => "proc_launch" do

            html.h4 "POST /processes"
            html.p "launch a new process instance"
            html.form :action => request.link(:processes) do
                html.div do
                    html.label "process definition URL", :for => "pdef_url"
                    html.input :type => "text", :name => "pdef_url", :id => "pdef_url"
                end
                html.div do
                    html.label "process definition", :for => "pdef"
                    html.textarea :cols => 50, :rows => 10 do
                        html.cdata! \
                        <<-EOS
                        <process-definition name="Test" revision="0">
                            <sequence>
                                <participant ref="alice" />
                                <participant ref="bob" />
                            </sequence>
                        </process-definition>
                        EOS
                    end
                end
            end
        end
    end
end

#
# PROCESS

# html

def render_process_html (p)

    builder do |html|
        _render_process_html html, p
    end
end

def _render_process_html (html, p, detailed=false)

    html.div :class => "proc_process" do
        html.h4 "Process #{p.wfid}"
    end
end

# xml

def render_process_xml (p)

    builder do |xml|
        xml.instruct!
        _render_process_xml xml, p, true
    end
end

def _render_process_xml (xml, p, detailed=false)

    xml.process do

        xml.wfid p.wfid
        xml.wfname p.wfname
        xml.wfrevision p.wfrevision

        xml.launch_time p.launch_time
        xml.paused p.paused

        xml.tags do
            p.tags.each { |t| xml.tag t }
        end

        xml.branches p.branches

        if detailed

            xml.variables do

                #OpenWFE::Xml.object_to_xml xml, p.variables
                    # too nested

                p.variables.each do |k, v|
                    xml.entry do
                        xml.string k.to_s
                        xml.string v.to_json
                    end
                end
            end

            xml.expressions :link => request.link(:expressions, p.wfid) do

                p.expressions.each do |fexp|

                    fei = fexp.fei

                    xml.expression(
                        "#{fei.to_s}", 
                        :short => fei.to_web_s,
                        :link => request.link(
                            :expressions, fei.wfid, swapdots(fei.expid)))
                end
            end

            xml.errors :count => p.errors.size do
                p.errors.each do |k, v|
                    xml.error do
                        #xml.stacktrace do
                        #    xml.cdata! "\n#{v.stacktrace}\n"
                        #end
                        xml.fei v.fei.to_s
                        xml.message v.stacktrace.split("\n")[0]
                    end
                end
            end
        else
            xml.errors :count => p.errors.size
        end
    end
end

