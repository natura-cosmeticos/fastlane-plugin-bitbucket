require 'fastlane/action'

module Fastlane
  module Actions
    class FilterStringLineByPrefixAction < Action
      def self.run(params)
        
        lines_with_prefix = ""
        
        prefix = params[:prefix]
        text = params[:text]
        
        text.each_line do |line|
          if line.start_with?(prefix)
            lines_with_prefix.concat(line)
          end
        end

        lines_with_prefix
      end

      def self.description
        "This action allows fastlane to filter a string by a specific prefix"
      end

      def self.authors
        ["Daniel Nazareth, Igor Matos"]
      end

      def self.return_value
        "The return value is a string with the diff that starts with a specifc prefix"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :prefix,
            description: "The prefix to be filtered on a string",
            optional: false,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :text,
            description: "The string that will be used to search a specific prefix",
            optional: false,
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