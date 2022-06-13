require 'fastlane/action'
require_relative '../helper/bitbucket_helper'
require 'base64'

module Fastlane
  module Actions
    class BitbucketOpenPullRequestAction < Action
      def self.run(params)
        title = params[:title]
        source_branch = params[:source_branch]
        destination_branch = params[:destination_branch]
        
        auth_header = Helper::BitbucketHelper.get_auth_header(params)
        
        if params[:base_url] then
          base_url = params[:base_url]
        else
          base_url = 'https://api.bitbucket.org'
        end

        if params[:close_source_branch] then
          close_source_branch = params[:close_source_branch]
        else
          close_source_branch = true
        end

        Helper::BitbucketHelper.open_pull_request(auth_header, base_url, params[:project_key], params[:repo_slug], title, source_branch, destination_branch, close_source_branch)
      end

      def self.description
        "This action allows fastlane to open BitBucket Pull Requests."
      end

      def self.authors
        ["Daniel Nazareth"]
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
            key: :source_branch,
            description: "The pull request source branch",
            type: String,
            optional: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :destination_branch,
            description: "The pull destination branch",
            type: String,
            optional: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :close_source_branch,
            description: "Should close source branch after pull request merge",
            type: Boolean,
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :title,
            description: "The pull request title",
            type: String,
            optional: false
          )
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
