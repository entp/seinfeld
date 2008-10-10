require File.join( File.dirname(__FILE__), "spec_helper" )

module Seinfeld
  describe User, ".process_new_github_user" do
    before do
      User.all.destroy!
    end

    it "creates a new user and updates their progress" do
      User.process_new_github_user(mail("elijah_snow sent you a message")) do |user|
        user.stub!(:committed_days_in_feed).and_return([])
      end
      User.first(:login => 'elijah_snow').should_not be_nil
    end

    it "does not create a user from an invalid subject" do
      User.process_new_github_user(mail("elijah_snow wants to be your friend")).should be_nil
    end

    it "does not create a duplicate user" do
      User.create :login => 'elijah_snow'
      User.process_new_github_user(mail("elijah_snow sent you a message")).should be_nil
    end

  protected
    def mail(subject)
      <<-END
Return-Path: <sample@exammple.com>
X-Original-To: hello@tasks.exammple.com
Delivered-To: tasks@exammple.com
Date: Wed, 10 Sep 2008 13:25:55 +0200
From: Ricky Bobby <ricky-bobby@example.com>
MIME-Version: 1.0
To: hello@tasks.exammple.com
Subject: #{subject}
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi There,

I'm saying hello
END
    end
  end
end