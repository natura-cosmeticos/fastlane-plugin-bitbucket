module Fastlane
  module Actions
    class StringContainsKeywordsAction < Action

      def self.run(params)
        text = params[:text]
        keywords = params[:keywords].split(/,/)
        has_keyword = keywords.any? { |keyword| text.include?(keyword) }
        
        has_keyword
      end

      def self.description
        "This action returns if a string contains any of the defined keywords."
      end

      def self.authors
        ["Igor Matos, Daniel Nazareth"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :text,
            description: "The base text that will look for keywords on each line",
            optional: false,
            type: String,
          ),
          FastlaneCore::ConfigItem.new(
            key: :keywords,
            description: "Keywords to be looked for. eg: @Supress",
            type: String,
            optional: false,
          )
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
