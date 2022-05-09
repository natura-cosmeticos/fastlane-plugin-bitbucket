module Fastlane
  module Actions
    module SharedValues
      BITBUCKET_PULL_REQUEST_HAS_COMMENT_CUSTOM_VALUE = :BITBUCKET_PULL_REQUEST_HAS_COMMENT_CUSTOM_VALUE
    end

    class BitbucketPullRequestHasCommentAction < Action
      def self.run(params)
        auth_header = Helper::BitbucketHelper.get_auth_header(params)
        message = params[:message]

        if params[:base_url] then
          base_url = params[:base_url]
        else
          base_url = 'https://api.bitbucket.org'
        end

        comments = Helper::BitbucketHelper.list_pull_request_comments(auth_header, base_url, params[:project_key], params[:repo_slug], params[:request_id], 100)

        comments_size = comments["size"]
        has_comment_already = false
      
        if comments_size > 0
          comments["values"].each do |comment|
            comment_text = comment["content"]["raw"]
            if comment_text == params[:message]
              has_comment_already = true
            end
          end
        end
        has_comment_already

      end

      def self.description
        "This action allows fastlane to fetch if a Pull Requests already has a specific comment."
      end

      def self.authors
        ["Daniel Nazareth, Igor Matos"]
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
            key: :request_id,
            description: "The pull request id number",
            type: Integer,
            optional: false
          ),
          FastlaneCore::ConfigItem.new(
            key: :message,
            env_name: "BITBUCKET_COMMENT_MESSAGE",
            description: "A specific message in order to compare if it is already commented",
            optional: false,
            type: String
          )
        ]
      end

      def self.return_value
        "This action returns if the Pull Request already has a specific message"
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
