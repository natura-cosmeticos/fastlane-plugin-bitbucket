require 'fastlane/action'
require_relative '../helper/bitbucket_helper'
require 'base64'

module Fastlane
  module Actions
    class BitbucketAction < Action
      def self.run(params)
        action = params[:action]
        request_id = params[:request_id]
        auth_header = Helper::BitbucketHelper.get_auth_header(params)
        
        if action == 'comment' then
          Helper::BitbucketHelper.comment_pull_request(auth_header, params[:base_url], params[:project_key], params[:repo_slug], params[:request_id], params[:message])
        elsif action == 'decline' then
          Helper::BitbucketHelper.decline_pull_request(auth_header, params[:base_url], params[:project_key], params[:repo_slug], params[:request_id])
        elsif action == 'approve' then
          Helper::BitbucketHelper.approve_pull_request(auth_header, params[:base_url], params[:project_key], params[:repo_slug], params[:request_id])
        elsif action == 'fetch' then
          Helper::BitbucketHelper.fetch_pull_request(auth_header, params[:base_url], params[:project_key], params[:repo_slug], params[:request_id])
        elsif action == 'update_user_status' then
          Helper::BitbucketHelper.update_user_status(auth_header, params[:base_url], params[:project_key], params[:repo_slug], params[:request_id], params[:user_slug], params[:status])
        else
          UI.user_error!("The action must be one of: comment, approve, decline, fetch, or update_user_status")
        end
      end

      def self.description
        "This action allows fastlane to interact with BitBucket Pull Requests; Currently approve, decline and comments are supported"
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
            key: :action,
            description: "The action to perform",
            default_value: "fetch",
            type: String,
            optional: true,
            verify_block: proc do |value|
              UI.user_error!("Action should be one of the following: approve, decline, comment") unless ["approve", "decline", "comment", "fetch", "update_user_status"].include? value
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
          ),
          FastlaneCore::ConfigItem.new(
            key: :user_slug,
            env_name: "BITBUCKET_USER_SLUG",
            description: "The user slug to update status for",
            type: String,
            optional: true
          ),
          FastlaneCore::ConfigItem.new(
            key: :status,
            description: "The status to set for the user (used in update_user_status request)",
            type: String,
            optional: true,
            default_value: "NEEDS_WORK",
            verify_block: proc do |value|
              UI.user_error!("Status should be one of UNAPPROVED, NEEDS_WORK, APPROVED") unless ["UNAPPROVED", "APPROVED", "NEEDS_WORK"].include? value
            end
          )
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
