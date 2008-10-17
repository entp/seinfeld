require File.join( File.dirname(__FILE__), "spec_helper" )

module Seinfeld
  describe User, ".process_new_github_user" do
    before do
      User.all.destroy!
    end

    it "creates a new user and updates their progress" do
      User.process_new_github_user("elijah_snow sent you a message") do |user|
        user.stub!(:committed_days_in_feed).and_return([])
      end
      User.first(:login => 'elijah_snow').should_not be_nil
    end

    it "does not create a user from an invalid subject" do
      User.process_new_github_user("elijah_snow wants to be your friend").should be_nil
    end

    it "does not create a duplicate user" do
      User.create :login => 'elijah_snow'
      User.process_new_github_user("elijah_snow sent you a message").should be_nil
    end
  end
end