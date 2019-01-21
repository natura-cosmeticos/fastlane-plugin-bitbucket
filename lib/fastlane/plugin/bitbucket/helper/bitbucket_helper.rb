require 'fastlane_core/ui/ui'
require 'json'
require 'net/http'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class BitbucketHelper
      def self.perform_get(uri, access_header, params)        
        uri.query = URI.encode_www_form(params)

        req = Net::HTTP::Get.new(uri)
        req['Authorization'] = access_header
        req['Accept'] = 'application/json'

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.set_debug_output($stdout)

        res = http.request(request)

        res
      end

      def self.perform_post(uri, access_header, params, query_params={})
        uri.query = URI.encode_www_form(query_params)

        req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
        req['Authorization'] = access_header
        req['Accept'] = 'application/json'
        req.body = params.to_json
        
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.set_debug_output($stdout)

        res = http.request(request)

        res
      end

      def self.fetch_pull_request(access_header, baseurl, project_key, repo_slug, request_id)
        pruri = URI.parse("#{baseurl}/rest/api/1.0/projects/#{project_key}/repos/#{repo_slug}/pull-requests/#{request_id}")
        prresp = self.perform_get(pruri, access_header, {})
        data = JSON.parse(prresp.body)
        data
      end

      def self.get_pull_request_version(access_header, baseurl, project_key, repo_slug, request_id)
        data = self.fetch_pull_request(access_header, baseurl, project_key, repo_slug, request_id)
        version = data["version"]
        version
      end

      def self.decline_pull_request(access_header, baseurl, project_key, repo_slug, request_id)
        version = self.get_pull_request_version(access_header, baseurl, project_key, repo_slug, request_id)

        uri = URI.parse("#{baseurl}/rest/api/1.0/projects/#{project_key}/repos/#{repo_slug}/pull-requests/#{request_id}/decline")
        res = self.perform_post(uri, access_header, {}, { version: version })
      end

      def self.approve_pull_request(access_header, baseurl, project_key, repo_slug, request_id)
        version = self.get_pull_request_version(access_header, baseurl, project_key, repo_slug, request_id)
        
        uri = URI.parse("#{baseurl}/rest/api/1.0/projects/#{project_key}/repos/#{repo_slug}/pull-requests/#{request_id}/approve")
        res = self.perform_post(uri, access_header, {}, { version: version })
      end

      def self.comment_pull_request(access_header, baseurl, project_key, repo_slug, request_id, comment)
        uri = URI.parse("#{baseurl}/rest/api/1.0/projects/#{project_key}/repos/#{repo_slug}/pull-requests/#{request_id}/comments")
        self.perform_post(uri, access_header, {
          "text": comment
        })
      end
    end
  end
end
