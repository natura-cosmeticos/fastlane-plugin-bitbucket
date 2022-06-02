module Fastlane
  module Actions
    class IsDiffstatChangingLockedFilesAction < Action

      def self.run(params)
        diffstat = params[:diffstat]
        file_name_prefix = params[:file_name_prefix]

        locked_files = params[:locked_files].split(/,/)
        edited_locked_files = false

        diffstat.each_line do |line|
          if !line.start_with? file_name_prefix
            next
          end

          file_name = line.delete_prefix("#{file_name_prefix} b/").delete_suffix("\n")
          if locked_files.any? { |file| file_name.match? file }
            return true
          end
        end

        false
      end

      def self.description
        "This action returns if a diffstat is changing a forbidden file."
      end

      def self.authors
        ["Igor Matos, Daniel Nazareth"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :diffstat,
            description: "The diffstat between two commits",
            optional: false,
            type: String,
          ),
          FastlaneCore::ConfigItem.new(
            key: :file_name_prefix,
            description: "The prefix keyword that identifies a file name. eg: +++",
            optional: false,
            type: String,
          ),
          FastlaneCore::ConfigItem.new(
            key: :locked_files,
            description: "Files that should not be changed, with extension. eg: myfile.xml",
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
