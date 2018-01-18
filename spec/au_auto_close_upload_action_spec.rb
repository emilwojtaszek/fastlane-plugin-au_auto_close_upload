describe Fastlane::Actions::AuAutoCloseUploadAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The au_auto_close_upload plugin is working!")

      Fastlane::Actions::AuAutoCloseUploadAction.run(nil)
    end
  end
end
