require 'fastlane/action'
require_relative '../helper/bitbucket_helper'

module Fastlane
  module Actions
    class BitbucketMergeRequestAction < Action
      def self.run(params)
        action = params[:action]
        request_id = params[:request_id]
        if action == 'comment' then
          UI.message("Should Comment on Request: " << request_id.to_s)
          Helper::BitbucketHelper.comment_pull_request(params[:access_token], params[:base_url], params[:project_key], params[:repo_slug], params[:request_id], params[:message])
        elsif action == 'decline' then
          UI.message("Should Decline Request: " << request_id.to_s)
          Helper::BitbucketHelper.decline_pull_request(params[:access_token], params[:base_url], params[:project_key], params[:repo_slug], params[:request_id])
        elsif action == 'approve' then
          UI.message("Should Approve Request: " << request_id.to_s)
          Helper::BitbucketHelper.approve_pull_request(params[:access_token], params[:base_url], params[:project_key], params[:repo_slug], params[:request_id])
        else
          UI.user_error!("The action must be one of: comment, approve, decline")
        end
      end

      def self.description
        "This action allows fastlane to interact with BitBucket Pull Requests. Currently approve, decline and comments are supported."
      end

      def self.authors
        ["Marcel Ball"]
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
            type: String
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
            description: "A Personal Access Token from BitBucket for the account used",
            optional: false,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :action,
            description: "The action to perform",
            default_value: "comment",
            type: String,
            optional: true,
            verify_block: proc do |value|
              UI.user_error!("Action should be one of the following: approve, decline, comment") unless ["approve", "decline", "comment"].include? value
            end
          ),
          FastlaneCore::ConfigItem.new(
            key: :message,
            description: "The content of the comment; markdown formatted. Only used if action is \"comment\"",
            default_value: "",
            type: String,
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :request_id,
            description: "The pull request id number",
            type: Integer,
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
