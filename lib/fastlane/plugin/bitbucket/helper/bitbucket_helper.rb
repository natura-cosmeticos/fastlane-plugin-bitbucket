require 'fastlane_core/ui/ui'
require 'json'
require 'net/http'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class BitbucketHelper

      def self.get_auth_header(params)
        if params[:access_token] then
          token = params[:access_token]
          auth_header = "Bearer #{token}".strip
        elsif params[:basic_creds] then
          creds = Base64.strict_encode64(params[:basic_creds])
          auth_header = "Basic #{creds}".strip
        else
          UI.user_error!("Either access_token or basic_creds must be supplied.")
          return
        end
      end

      def self.response_handler(response)
        if response.kind_of? Net::HTTPSuccess
          UI.success "Bitbucket status request has response code: #{response.code}"
        else
          UI.error "Bitbucket status request has response code: #{response.code}"
        end
      end

      def self.perform_get(uri, access_header, params)        
        uri.query = URI.encode_www_form(params)

        req = Net::HTTP::Get.new(uri)
        req['Authorization'] = access_header
        req['Accept'] = 'application/json'

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.instance_of? URI::HTTPS
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        res = http.request(req)
        self.response_handler(res)

        res
      end

      def self.perform_post(uri, access_header, params, query_params={})
        uri.query = URI.encode_www_form(query_params)

        req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
        req['Authorization'] = access_header
        req['Accept'] = 'application/json'
        req.body = params.to_json
        
        http = Net::HTTP.new(uri.host, uri.port)
        
        http.use_ssl = uri.instance_of? URI::HTTPS
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        res = http.request(req)
        self.response_handler(res)

        res
      end

      def self.perform_put(uri, access_header, params, query_params={})
        uri.query = URI.encode_www_form(query_params)

        req = Net::HTTP::Put.new(uri, 'Content-Type' => 'application/json')
        req['Authorization'] = access_header
        req['Accept'] = 'application/json'
        req.body = params.to_json
        
        http = Net::HTTP.new(uri.host, uri.port)
        
        http.use_ssl = uri.instance_of? URI::HTTPS
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        res = http.request(req)
        self.response_handler(res)

        res
      end

      def self.perform_delete(uri, access_header, params, query_params={})
        uri.query = URI.encode_www_form(query_params)

        req = Net::HTTP::Delete.new(uri, 'Content-Type' => 'application/json')
        req['Authorization'] = access_header
        req['Accept'] = 'application/json'
        req.body = params.to_json
        
        http = Net::HTTP.new(uri.host, uri.port)
        
        http.use_ssl = uri.instance_of? URI::HTTPS
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        res = http.request(req)
        self.response_handler(res)

        res
      end

      def self.fetch_pull_request(access_header, baseurl, project_key, repo_slug, request_id)
        pruri = URI.parse("#{baseurl}/2.0/repositories/#{project_key}/#{repo_slug}/pullrequests/#{request_id}")
        prresp = self.perform_get(pruri, access_header, {})
        data = JSON.parse(prresp.body)
        data
      end

      def self.fetch_pull_requests(access_header, baseurl, project_key, repo_slug, query_params)
        pruri = URI.parse("#{baseurl}/2.0/repositories/#{project_key}/#{repo_slug}/pullrequests")
        prresp = self.perform_get(pruri, access_header, query_params)
        data = JSON.parse(prresp.body)
        data
      end

      def self.fetch_diffstat(access_header, baseurl, project_key, repo_slug, request_id, source_commit, destination_commit)
        pruri = URI.parse("#{baseurl}/2.0/repositories/#{project_key}/#{repo_slug}/diffstat/#{project_key}/#{repo_slug}:#{source_commit}%0D#{destination_commit}")
        prresp = self.perform_get(pruri, access_header, { from_pullrequest_id: request_id })
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

        uri = URI.parse("#{baseurl}/2.0/repositories/#{project_key}/#{repo_slug}/pullrequests/#{request_id}/decline")
        res = self.perform_post(uri, access_header, {}, { version: version })
      end

      def self.request_changes_pull_request(access_header, baseurl, project_key, repo_slug, request_id)
        version = self.get_pull_request_version(access_header, baseurl, project_key, repo_slug, request_id)

        uri = URI.parse("#{baseurl}/2.0/repositories/#{project_key}/#{repo_slug}/pullrequests/#{request_id}/request-changes")
        res = self.perform_post(uri, access_header, {}, { version: version })
      end

      def self.remove_request_changes_pull_request(access_header, baseurl, project_key, repo_slug, request_id)
        version = self.get_pull_request_version(access_header, baseurl, project_key, repo_slug, request_id)

        uri = URI.parse("#{baseurl}/2.0/repositories/#{project_key}/#{repo_slug}/pullrequests/#{request_id}/request-changes")
        res = self.perform_delete(uri, access_header, {}, { version: version })
      end

      def self.approve_pull_request(access_header, baseurl, project_key, repo_slug, request_id)
        version = self.get_pull_request_version(access_header, baseurl, project_key, repo_slug, request_id)
        
        uri = URI.parse("#{baseurl}/2.0/repositories/#{project_key}/#{repo_slug}/pullrequests/#{request_id}/approve")
        res = self.perform_post(uri, access_header, {}, { version: version })
      end

      def self.comment_pull_request(access_header, baseurl, project_key, repo_slug, request_id, comment)
        uri = URI.parse("#{baseurl}/2.0/repositories/#{project_key}/#{repo_slug}/pullrequests/#{request_id}/comments")
        self.perform_post(uri, access_header, {
          "content": {
            "raw": comment
          }
        })
      end

      def self.list_pull_request_comments(access_header, baseurl, project_key, repo_slug, request_id, length)
        uri = URI.parse("#{baseurl}/2.0/repositories/#{project_key}/#{repo_slug}/pullrequests/#{request_id}/comments")
        prresp = self.perform_get(uri, access_header, { pagelen: length })
        data = JSON.parse(prresp.body)
        data
      end

      def self.fetch_default_reviewers(access_header, baseurl, project_key, repo_slug)
        uri = URI.parse("#{baseurl}/2.0/repositories/#{project_key}/#{repo_slug}/default-reviewers")
        prresp = self.perform_get(uri, access_header, { })
        data = JSON.parse(prresp.body)
        data
      end

      def self.update_user_status(access_header, baseurl, project_key, repo_slug, request_id, user_slug, status)
        uri = URI.parse("#{baseurl}/2.0/repositories/#{project_key}/#{repo_slug}/pullrequests/#{request_id}/participants/#{user_slug}")
        self.perform_put(uri, access_header, {
          "status": status
        })
      end

      def self.set_commit_status(access_header, baseurl, commit, params)
        uri = URI.parse("#{baseurl}/rest/build-status/1.0/commits/#{commit}")
        self.perform_post(uri, access_header, params)
      end


    end
  end
end
