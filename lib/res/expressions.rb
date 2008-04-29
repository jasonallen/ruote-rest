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


get "/expressions/:wfid" do

    wfid = params[:wfid]
    es = $engine.process_stack wfid, true

    throw :halt, [ 404, "no process #{wfid}" ] unless es

    rrender :expressions, es
end

put "/expressions/:wfid/:expid" do

    expression = rparse :expression

    $engine.update_expression expression

    header "Location" => expression.link(request)
    rrender :expression, find_expression
end

get "/expressions/:wfid/:expid" do

    rrender :expression, find_expression
end

delete "/expressions/:wfid/:expid" do

    e = find_expression

    $engine.cancel_expression e

    response.status = 204
end


#
# some helper methods

helpers do

    def find_expression

        wfid = params[:wfid]
        expid = swapdots params[:expid]

        env = false

        if expid[-1, 1] == "e"
            expid = expid[0..-2]
            env = true
        end

        es = $engine.process_stack wfid, true

        es.find { |e| 

            (e.fei.expid == expid) and (env == e.is_a?(OpenWFE::Environment))

        } or throw :halt, [ 404, "no expression #{expid} in process #{wfid}" ]
    end
end

