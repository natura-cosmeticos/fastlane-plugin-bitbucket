require 'fastlane/action'
require_relative '../helper/bitbucket_helper'
require 'base64'

module Fastlane
  module Actions
    class BitbucketCommitStatusAction < Action

      def self.run(params)
        auth_header = Helper::BitbucketHelper.get_auth_header(params)

        payload = {
          "state": params[:commit_status],
          "name": params[:commit_status_name],
          "key": params[:commit_key],
          "url": params[:description_url],
          "description": params[:description]
        }
        Helper::BitbucketHelper.set_commit_status(auth_header, params[:base_url], params[:commit], payload)
      end

      def self.description
        "This action allows fastlane to interact with BitBucket commit status; Set SUCCESSFUL or FAILED  status."
      end

      def self.authors
        ["f100024"]
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
            optional: false,
            type: String,
            verify_block: proc do |value|
              UI.user_error!("Bitbucket Server url should use https") unless !!(value.match"^https://")
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :commit_status,
            env_name: "BITBUCKET_COMMIT_STATUS",
            default_value: "FAILED",
            description: "Build status of set comit. SUCCESSFUL or FAILED",
            optional: false,
            type: String,
            verify_block: proc do |value|
              UI.user_error!("Commit build status does not match ^SUCCESSFUL|FAILED$") unless !!(value.match "^SUCCESSFUL|FAILED$")
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :commit,
            env_name: "BITBUCKET_COMMIT",
            description: "Hash commit for which will be set status",
            optional: false,
            type: String,
            verify_block: proc do |value|
              UI.user_error!("Hash commit value does not match regex  ^[a-f0-9]+$") unless !!(value.match "^[a-f0-9]+$")
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :commit_status_name,
            env_name: "BITBUCKET_COMMIT_STATUS_NAME",
            default_value: "build",
            description: "Bitbucket commit tag name, will be displayed as header of status",
            optional: true,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :commit_key,
            env_name: "BITBUCKET_COMMIT_KEY",
            default_value: "build_key",
            description: "Bitbucket commit status key, used for identify status in case when using multiple statuses (e.g. build and tests)",
            optional: true,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :description,
            env_name: "BITBUCKET_COMMIT_DESCRIPTION",
            description: "Bitbucket commit status description",
            optional: true,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :description_url,
            env_name: "BITBUCKET_COMMIT_STATUS_DESCRIPTION_URL",
            description: "Bitbucket link will added to commit description",
            optional: true,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :access_token,
            env_name: "BITBUCKET_PERSONAL_ACCESS_TOKEN",
            description: "A Personal Access Token from BitBucket for the account used. One of access_token or basic_creds must be specified; if both are supplied access_token is used",
            optional: true,
            sensitive: true,
            type: String,
            conflicting_options: [:basic_creds]
          ),
          FastlaneCore::ConfigItem.new(
            key: :basic_creds,
            env_name: "BITBUCKET_BASIC_AUTH_CREDENTIALS",
            description: "To use Basic Auth for Bitbuket provide a base64 encoded version of \"<username>:<password>\". One of access_token or basic_creds must be specified; if both are supplied access_token is used",
            optional: true,
            sensitive: true,
            type: String,
            conflicting_options: [:access_token]
          )
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
