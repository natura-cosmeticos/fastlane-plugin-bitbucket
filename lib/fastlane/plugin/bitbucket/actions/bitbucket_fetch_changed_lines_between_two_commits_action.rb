require 'fastlane/action'
require_relative '../helper/bitbucket_helper'
require 'base64'


module Fastlane
  module Actions
    class BitbucketFetchChangedLinesBetweenTwoCommitsAction < Action
      def self.run(params)
        auth_header = Helper::BitbucketHelper.get_auth_header(params)
        
        if params[:base_url] then
          base_url = params[:base_url]
        else
          base_url = 'https://api.bitbucket.org'
        end
    
        changed_lines = Helper::BitbucketHelper.compare_two_commits(auth_header, base_url, params[:project_key], params[:repo_slug], params[:source_commit], params[:destination_commit])

        
        if params[:prefix] then
          prefix = params[:prefix]
        else
          prefix = ''
        end

        lines_with_prefix = Fastlane::Actions::FilterStringLineByPrefixAction.run(
          prefix: prefix,
          text: changed_lines
        )

        lines_with_prefix
      end

      def self.description
        "This action allows fastlane to filter two commits diff by a specific prefix"
      end

      def self.authors
        ["Daniel Nazareth"]
      end

      def self.return_value
        "The return value is a string with the diff that start with a specifc prefix between two commits"
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
            key: :source_commit,
            env_name: "BITBUCKET_DIFFSTAT_SOURCE_COMMIT",
            description: "The hash of commit from origin branch",
            optional: false,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :destination_commit,
            env_name: "BITBUCKET_DIFFSTAT_DESTINATION_COMMIT",
            description: "The hash of commit from destination branch",
            optional: false,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :prefix,
            env_name: "BITBUCKET_COMMIT_CHANGE_PREFIX",
            description: "The prefix that indicate the desired change on a commit",
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