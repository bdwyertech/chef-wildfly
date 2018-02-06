# Encoding: UTF-8

#
# Cookbook:: wildfly
# Library:: ApiClient
#
# Copyright:: 2018, Brian Dwyer - Intelligent Digital Services
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'cgi'
require 'net/http'
require 'net/http/digest_auth'
require 'socket'
require 'uri'

module WildFly
  class ApiClient
    #
    # => WildFly Management API Client
    #
    attr_accessor :url, :user, :password

    def initialize(url = nil, user = nil, password = nil)
      @url      = url      || 'http://127.0.0.1:9990/management'
      @user     = user     || 'wildfly'
      @password = password || 'wildfly'
      yield self if block_given?

      # => HTTP Client
      @uri = URI.parse @url
      @uri.user = CGI.escape(@user)
      @uri.password = CGI.escape(@password)
      ssl_opts = {}
      if @uri.scheme == 'https'
        ssl_opts[:use_ssl] = true
        ssl_opts[:verify_mode] = OpenSSL::SSL::VERIFY_NONE
      end

      @http_client = Net::HTTP.start(@uri.host, @uri.port, ssl_opts)
    end

    #
    # => HTTP Client
    #
    def client(request)
      request.content_type = 'application/json'
      # => Chef::Log.warn(request.path) # => DEBUG
      response = api_retry do
        response = @http_client.request(request)
        # => Handle Message Digest Authentication
        if response['www-authenticate'] && response.code == '401'
          if response['www-authenticate'] =~ /digest/i
            # => Message Digest Authentication
            digest_auth = Net::HTTP::DigestAuth.new
            auth = digest_auth.auth_header @uri, response['www-authenticate'], request.method
            sleep 0.05 # => Wait before using the auth header to avoid a 401
            request['Authorization'] = auth
          else
            # => Basic Authentication
            request.basic_auth @uri.user, @uri.password
          end
          # => Do the Request
          response = @http_client.request(request)
          if response.is_a?(Net::HTTPServiceUnavailable)
            raise Net::HTTPFatalError.new(response.msg, response)
          end
        end
        response
      end
      parsed = Chef::JSONCompat.parse(response.read_body) rescue nil # rubocop: disable RescueModifier
      return parsed if parsed
      Chef::Log.warn('WildFly API: Unknown Response: ' + response.read_body.inspect)
      response
    end

    # => API Retry Error Handler
    def api_retry
      tries ||= 0
      yield
    rescue => e
      raise e unless (tries += 1) < 11
      Chef::Log.warn("WildFly API: Retrying Request - #{tries}/10")
      sleep 5
      retry
    end

    def can_connect?
      resp = cli(':read-attribute(name=server-state)')
      return true if resp['outcome']
    end

    #
    # => Management API Interface
    #
    def do(operation, path = [], params = {}, op_headers = {})
      request = Net::HTTP::Post.new('/management')
      request.body = {
        'operation' => operation,
        'address' => path,
        'recursive' => true,
        'json.pretty' => true,
      }.merge(params).merge(op_headers).to_json
      client(request)
    end

    #
    # => CLI Converter
    #

    def cli(cmd)
      request = Net::HTTP::Post.new('/management')
      request.body = self.class.build(cmd).to_json
      resp = client(request)
      resp
    end

    # => CLI
    # => /subsystem=undertow/server=default-server:read-resource(include-runtime=true,recursive=true)

    # => JSON
    # => {
    # =>   "address": [
    # =>     "subsystem",
    # =>     "undertow",
    # =>     "server",
    # =>     "default-server"
    # =>   ],
    # =>   "json.pretty": true,
    # =>   "operation": "read-resource",
    # =>   "include-runtime": true,
    # =>   "recursive": true
    # => }

    def self.build(cmd)
      cmd = cmd.split(':')
      body = {}
      body['address'] = address(cmd[0])
      body['json.pretty'] = true
      operation(cmd[1]).each do |k, v|
        body[k] = v
      end
      body
    end

    # => Transforms read-attribute(recursive)
    def self.operation(operation)
      resp = {}
      return resp unless operation
      operation = operation.split('(')
      resp['operation'] = operation[0]
      return resp unless operation[1]
      operation[1].tr(')', '').split(',').each do |o|
        o = o.split('=')
        resp[o[0]] = o[1] || true
      end
      resp
    end

    def self.address(address)
      address.tr('=', '/').split('/').reject(&:empty?)
    end
  end
end
