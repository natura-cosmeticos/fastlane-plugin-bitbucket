require 'fastlane/action'
require_relative '../helper/bitbucket_helper'
require 'base64'


module Fastlane
  module Actions
    class BitbucketFetchPullrequestsAction < Action
      def self.run(params)
        auth_header = Helper::BitbucketHelper.get_auth_header(params)
        
        puts "paramssss"
        puts params.to_s
        puts "paramssss"

        if params[:base_url] then
          base_url = params[:base_url]
        else
          base_url = 'https://api.bitbucket.org'
        end

       if params[:status] then
          query_params = { status: params[:status] }
       else
          query_params = { }
       end
      #  def self.fetch_pull_requests(access_header, baseurl, project_key, repo_slug, query_params)
        Helper::BitbucketHelper.fetch_pull_requests(auth_header, base_url, params[:project_key], params[:repo_slug], query_params)
      end

      def self.description
        "This action allows fastlane to list BitBucket Pull Requests."
      end

      def self.authors
        ["Marcel Ball, Daniel Nazareth, Igor Matos"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details

      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :base_url,
            env_name: "BITBUCKET_BASE_URL",
            description: "The base URL for your BitBucket Server, including protocol",
            optional: true,
            type: String,
            verify_block: proc do |value|
              UI.user_error!("Bitbucket Server url should use https") unless !!(value.match"^https://")
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :project_key,
            env_name: "BITBUCKET_PROJECT_KEY",
            description: "The Project Key for your repository",
            optional: false,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :repo_slug,
            env_name: "BITBUCKET_REPO_SLUG",
            description: "The repository slug for your repository",
            optional: false,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :access_token,
            env_name: "BITBUCKET_PERSONAL_ACCESS_TOKEN",
            description: "A Personal Access Token from BitBucket for the account used. One of access_token or basic_creds must be specified; if both are supplied access_token is used",
            optional: true,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :basic_creds,
            env_name: "BITBUCKET_BASIC_AUTH_CREDENTIALS",
            description: "To use Basic Auth for Bitbuket provide a base64 encoded version of \"<username>:<password>\". One of access_token or basic_creds must be specified; if both are supplied access_token is used",
            optional: true,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :status,
            env_name: "BITBUCKET_FETCH_PULL_REQUESTS_STATUS",
            description: "Filter pull requests by status, e.g: OPEN, MERGED or DECLINED",
            optional: true,
            type: String
          )
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end