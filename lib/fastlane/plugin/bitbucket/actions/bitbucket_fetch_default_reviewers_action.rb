module Fastlane
  module Actions
    module SharedValues
      BITBUCKET_FETCH_REVIEWERS_ACTION_CUSTOM_VALUE = :BITBUCKET_FETCH_REVIEWERS_ACTION_CUSTOM_VALUE
    end

    class BitbucketFetchDefaultReviewersAction < Action
      def self.run(params)
        auth_header = Helper::BitbucketHelper.get_auth_header(params)
        
        if params[:base_url] then
          base_url = params[:base_url]
        else
          base_url = 'https://api.bitbucket.org'
        end

        Helper::BitbucketHelper.fetch_default_reviewers(auth_header, base_url, params[:project_key], params[:repo_slug])

      end

      def self.description
        "This action allows fastlane to fetch the list of default reviewrs for a repository"
      end

      def self.authors
        ["Ana Ludmila, Daniel Nazareth, Igor Matos"]
      end

      def self.return_value
        "This action returns the the list of default reviewrs for a repository."
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
          )
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
