require File.join( File.dirname(__FILE__), "spec_helper" )

module Seinfeld
  describe User do
    before :all do
      @feed = OpenStruct.new
      @feed.entries = [
        OpenStruct.new(:title => "bob committed something", :updated_at => Time.utc(2008, 1, 1, 22)),
        OpenStruct.new(:title => "bob watched something"),
        OpenStruct.new(:title => "bob committed something", :updated_at => Time.utc(2008, 1, 1, 23)),
        OpenStruct.new(:title => "bob committed something", :updated_at => Time.utc(2008, 1, 2, 23)),
        ]
    end

    before do
      @user = Seinfeld::User.new :login => 'bob'
    end

    describe "#scan_for_progress" do
      before do
        @user.stub!(:get_feed).and_return(@feed)
      end
      
      it "returns array" do
        @user.scan_for_progress.should be_kind_of(Array)
      end

      it "returns unique days" do
        @user.scan_for_progress.should == [Time.utc(2008, 1, 1), Time.utc(2008, 1, 2)]
      end

      it "matches against login name" do
        @user.login = 'not bob'
        @user.scan_for_progress.should be_empty
      end
    end

    describe "#update_progress" do
      before do
        @user.stub!(:get_feed).and_return(@feed)
        User.transaction do
          User.all.destroy!
          Progression.all.destroy!
        end
      end

      it "saves record if necessary" do
        @feed.stub!(:entries).and_return([])
        @user.update_progress
        @user.id.should_not be_nil
      end

      it "inserts progression records" do
        lambda { @user.update_progress }.should change { Progression.all(:user_id => @user.id).size }.by(2)
      end

      it "inserts only unique progression records" do
        Progression.create! :user_id => @user.id, :created_at => @feed.entries.first.updated_at
        lambda { @user.update_progress }.should change { Progression.all(:user_id => @user.id).size }.by(1)
      end
    end
  end
end