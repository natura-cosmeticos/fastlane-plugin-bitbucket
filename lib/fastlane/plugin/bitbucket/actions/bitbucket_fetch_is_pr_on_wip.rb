module Fastlane
  module Actions
    module SharedValues
      BITBUCKET_FETCH_IS_PR_ON_WIP_CUSTOM_VALUE = :BITBUCKET_FETCH_IS_PR_ON_WIP_CUSTOM_VALUE
    end

    class BitbucketFetchIsPrOnWipAction < Action
      def self.run(params)
        auth_header = Helper::BitbucketHelper.get_auth_header(params)

        if params[:base_url] then
          base_url = params[:base_url]
        else
          base_url = 'https://api.bitbucket.org'
        end

        if params[:wip_text] then
          wip_text = params[:wip_text]
        else
          wip_text = "WIP"
        end

        pr_details = Helper::BitbucketHelper.fetch_pull_request(auth_header, base_url, params[:project_key], params[:repo_slug], params[:request_id])

        pr_title = pr_details["rendered"]["title"]["raw"]

        pr_title.include? wip_text
      end

      def self.description
        "This action allows fastlane to fetch if a Pull Requests has 'WIP' or a specific custom word on it's title."
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
            key: :wip_text,
            env_name: "BITBUCKET_TITLE_WORK_IN_PROGRESS_KEY",
            description: "A specific key that should be on the Pull Request title in order to identify that it is a Work In Progress",
            optional: true,
            type: String
          )
        ]
      end

      def self.return_value
        "This action returns if the Pull Request title contains the word defined as the 'WIP' trigger"
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
