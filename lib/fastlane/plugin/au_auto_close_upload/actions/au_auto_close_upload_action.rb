module Fastlane
  module Actions
  
    class AuAutoCloseUploadAction < Action
      def self.run(params)
        #check params
        check_params(params)

        # message
        UI.message("Archiving files...")

        # ipa zip
        # ipa = File.basename(params[:ipa_path])
        command = "tar -zcvf ipa.tgz #{params[:ipa_path]}"
        Fastlane::Actions.sh command, log: :verbose

        # dzym zip
        # dsym = File.basename(params[:dsym_path])
        command = "tar -zcvf dsym.tgz #{params[:dsym_path]}"
        Fastlane::Actions.sh command, log: :verbose

        # uploading
        UI.message("Uploading artifacts to auto-close service...")

        # upload artifacts
        command = "python tools/upload.py --token #{params[:token]} "
        command << "--final " if params[:final]
        command << "--build-name #{params[:build_name]} ipa.tgz dsym.tgz "
        Fastlane::Actions.sh command, log: :verbose
      end

      def self.description
        "Upload artifacts to AppUnite's auto-close service"
      end

      def self.check_params(params)
        if params[:ipa_path].nil?
          Helper.log.error "Missing :ipa_path Parameter"  
        end

        if params[:dsym_path].nil?
          Helper.log.error "Missing :ipa_path Parameter"  
        end

        if params[:token].nil?
          Helper.log.error "Missing :token Parameter"  
        end

      end

      def self.available_options

        # paths        
        ipa_path_default = Dir["*.ipa"].last
        dsym_path_default = Dir["*.dsym"].last

        # generate build name string
        build_name = `echo ${CI_BUILD_ID}-$(git rev-parse --short HEAD)-$(git rev-parse --abbrev-ref HEAD)`

        [
          FastlaneCore::ConfigItem.new(key: :build_name,
                                       description: "Build name unique description",
                                       default_value: build_name.shellescape,
                                       optional: false),

          FastlaneCore::ConfigItem.new(key: :verbose,
                                       description: "User verbose mode",
                                       default_value: false,
                                       optional: false),

          FastlaneCore::ConfigItem.new(key: :ipa_path,
                                       env_name: "AU_IPA_PATH",
                                       description: "Path to your IPA file. Optional if you use the `gym` or `xcodebuild` action",
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] || ipa_path_default,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find ipa file at path '#{value}'") unless File.exist?(value)
                                       end),

          FastlaneCore::ConfigItem.new(key: :dsym_path,
                                       env_name: "AU_DSYM_PATH",
                                       description: "Path to your dSYM file. Optional if you use the `gym` or `xcodebuild` action",
                                       default_value: Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH] || dsym_path_default,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find dsym file at path '#{value}'") unless File.exist?(value)
                                       end),

          FastlaneCore::ConfigItem.new(key: :token,
                                       env_name: "AUTO_CLOSE_TOKEN",
                                       description: "Auto-Close access token",
                                       optional: false),

          FastlaneCore::ConfigItem.new(key: :final,
                                       description: "Mark this artifacts and final",
                                       default_value: true,
                                       optional: true),
        ]
      end

      def self.authors
        ["emilwojtaszek"]
      end

      def self.details
        # Optional:
        "Upload artifacts to AppUnite's auto-close service"
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end