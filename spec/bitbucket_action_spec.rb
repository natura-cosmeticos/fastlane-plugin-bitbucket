describe Fastlane::Actions::BitbucketAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The bitbucket plugin is working!")

      Fastlane::Actions::BitbucketAction.run(nil)
    end
  end
end
