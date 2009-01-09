require File.join( File.dirname(__FILE__), "spec_helper" )

module Seinfeld
  describe User do
    before :all do
      @feed = OpenStruct.new
      @feed.entries = [
        OpenStruct.new(:item_id => 'a', :title => "BOB committed something", :updated_at => Time.utc(2008, 1, 1, 22)),
        OpenStruct.new(:item_id => 'b', :title => "bob watched something"),
        OpenStruct.new(:item_id => 'c', :title => "bob pushed something", :updated_at => Time.utc(2008, 1, 1, 23)),
        OpenStruct.new(:item_id => 'd', :title => "bob applied fork commits to something", :updated_at => Time.utc(2008, 1, 2, 23)),
        ]
    end

    before do
      @user = Seinfeld::User.new :login => 'bob'
    end

    describe "#committed_days_in_feed" do
      before do
        @user.stub!(:get_feed).with(1).and_return(@feed)
        @user.stub!(:get_feed).with(2).and_return(OpenStruct.new(:entries => []))
      end
      
      it "returns array" do
        @user.committed_days_in_feed.should be_kind_of(Array)
      end

      it "returns unique days" do
        @user.committed_days_in_feed.should == [Date.civil(2008, 1, 2), Date.civil(2008, 1, 1)]
      end

      it "matches against login name" do
        @user.login = 'not bob'
        @user.committed_days_in_feed.should be_empty
      end

      it "sets #last_entry_id from the feed" do
        @user.committed_days_in_feed
        @user.last_entry_id.should == @feed.entries.first.item_id
      end

      it "leaves #last_entry_id if page > 2" do
        @user.committed_days_in_feed(2)
        @user.last_entry_id.should be_nil
      end
      
      it "accepts 'created branch' as a valid feed title" do
        @user.stub!(:get_feed).with(1).and_return(OpenStruct.new(:entries => 
          [OpenStruct.new(:item_id => 'a', 
                          :title => "bob created branch something/branch", 
                          :updated_at => Time.utc(2008, 1, 1, 22)),]))
        @user.committed_days_in_feed.should_not be_empty
      end

      describe "with #last_entry_id set" do
        before do
          @user.last_entry_id = @feed.entries[2].item_id
        end

        it "returns unique days" do
          @user.committed_days_in_feed.should == [Date.civil(2008, 1, 1)]
        end

        it "sets #last_entry_id from the feed" do
          @user.committed_days_in_feed
          @user.last_entry_id.should == @feed.entries.first.item_id
        end

         it "leaves #last_entry_id if page > 2" do
          @user.committed_days_in_feed(2)
          @user.last_entry_id.should == @feed.entries[2].item_id
        end
      end

      describe "with multiple pages" do
        before :all do
          @feed2 = OpenStruct.new
          @feed2.entries = [
            OpenStruct.new(:item_id => 'e', :title => "bob committed something", :updated_at => Time.utc(2008, 1, 4, 22)),
            OpenStruct.new(:item_id => 'f', :title => "bob watched something"),
            OpenStruct.new(:item_id => 'g', :title => "bob committed something", :updated_at => Time.utc(2008, 1, 5, 23))
            ]
        end

        before do
          @user.stub!(:get_feed).with(2).and_return(@feed2)
          @user.stub!(:get_feed).with(3).and_return(OpenStruct.new(:entries => []))
        end

        it "returns unique days" do
          @user.committed_days_in_feed.should == [Date.civil(2008, 1, 2), Date.civil(2008, 1, 1), Date.civil(2008, 1, 4), Date.civil(2008, 1, 5)]
        end

        it "sets #last_entry_id from the feed" do
          @user.committed_days_in_feed
          @user.last_entry_id.should == @feed.entries.first.item_id
        end
      end
    end

    describe "#clear_progress" do
      before :all do
        Seinfeld::User.transaction do
          @existing = Seinfeld::User.create :login => 'bob', 
            :streak_start => Date.civil(2007, 12, 30), :streak_end => Date.civil(2007, 12, 31), :current_streak => 2,
            :longest_streak_start => Date.civil(2007, 12, 30), :longest_streak_end => Date.civil(2007, 12, 31), :longest_streak => 2, 
            :last_entry_id => 'abc'
          @existing.progressions.create(:created_at => Date.civil(2007, 12, 30))
          @existing.progressions.create(:created_at => Date.civil(2007, 12, 31))
        end
        @existing.clear_progress
        @existing.reload
      end

      it "clears progression records" do
        @existing.should have(0).progressions
      end

      it "clears #streak_start" do
        @existing.streak_start.should == nil
      end

      it "clears #streak_end" do
        @existing.streak_end.should == nil
      end

      it "clears #current_streak" do
        @existing.current_streak.should == nil
      end

      it "clears #longest_streak_start" do
        @existing.longest_streak_start.should == nil
      end

      it "clears #longest_streak_end" do
        @existing.longest_streak_end.should == nil
      end

      it "clears #longest_streak" do
        @existing.longest_streak.should == nil
      end

      it "clears #last_entry_id" do
        @existing.last_entry_id.should == nil
      end
    end

    describe "#reset_progress" do
      before :all do
        Seinfeld::User.transaction do
          @existing = Seinfeld::User.create :login => 'bob', 
            :streak_start => Date.civil(2007, 12, 15), :streak_end => Date.civil(2007, 12, 16), :current_streak => 1,
            :longest_streak_start => Date.civil(2007, 12, 15), :longest_streak_end => Date.civil(2007, 12, 16), :longest_streak => 1, 
            :last_entry_id => 'abc'
          @existing.progressions.create(:created_at => Date.civil(2007, 12, 15))
          @existing.progressions.create(:created_at => Date.civil(2007, 12, 16))
        end
        @existing.stub!(:committed_days_in_feed).and_return [Date.civil(2007, 12, 30), Date.civil(2007, 12, 31), Date.civil(2008, 1, 1), Date.civil(2008, 1, 2)]
        Date.stub!(:today).and_return(Date.civil(2008, 1, 3))
        @existing.reset_progress
        @existing.reload
      end

      it "resets progression records" do
        @existing.progressions.map { |p| p.created_at }.should == [Date.civil(2008, 1, 2), Date.civil(2008, 1, 1), Date.civil(2007, 12, 31), Date.civil(2007, 12, 30)]
      end

      it "resets #streak_start" do
        @existing.streak_start.should == Date.civil(2007, 12, 30)
      end

      it "resets #streak_end" do
        @existing.streak_end.should == Date.civil(2008, 1, 2)
      end

      it "resets #current_streak" do
        @existing.current_streak.should == 4
      end

      it "resets #longest_streak_start" do
        @existing.longest_streak_start.should == Date.civil(2007, 12, 30)
      end

      it "resets #longest_streak_end" do
        @existing.longest_streak_end.should == Date.civil(2008, 1, 2)
      end

      it "resets #longest_streak" do
        @existing.longest_streak.should == 4
      end
    end

    describe "#update_progress" do
      before do
        @user.stub!(:committed_days_in_feed).and_return [Date.civil(2008, 1, 1), Date.civil(2008, 1, 2)]
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

      it "calculates current streak" do
        @user.update_progress
        @user.current_streak.should == 0
      end

      it "calculates longest streak" do
        @user.update_progress
        @user.longest_streak.should == 2
      end

      it "calculates streak start" do
        @user.update_progress
        @user.streak_start.should == Date.civil(2008, 1, 1)
      end

      it "calculates streak end" do
        @user.update_progress
        @user.streak_end.should == Date.civil(2008, 1, 2)
      end

      it "inserts only unique progression records" do
        Progression.create :user_id => @user.id, :created_at => @feed.entries.first.updated_at
        lambda { @user.update_progress }.should change { Progression.all(:user_id => @user.id).size }.by(1)
      end
      
      describe "(with multiple streaks and an existing streak)" do
        before do
          @user.streak_start   = Date.civil(2007, 12, 30)
          @user.streak_end     = Date.civil(2007, 12, 31)
          @user.longest_streak = 3
          @user.current_streak = 2
          @user.stub!(:committed_days_in_feed).and_return [Date.civil(2008, 1, 1), Date.civil(2008, 1, 2), Date.civil(2008, 1, 3), Date.civil(2008, 1, 5), Date.civil(2008, 1, 6), Date.civil(2008, 1, 7), Date.civil(2008, 1, 8)]
          Time.stub!(:now).and_return Time.utc(2008, 1, 8)
          User.transaction do
            User.all.destroy!
            Progression.all.destroy!
          end
        end

        it "calculates current streak" do
          @user.update_progress
          @user.current_streak.should == 4
        end
        
        it "calculates longest streak" do
          @user.update_progress
          @user.longest_streak.should == 5
        end
        
        it "calculates streak start" do
          @user.update_progress
          @user.streak_start.should == Date.civil(2008, 1, 5)
        end
        
        it "calculates streak end" do
          @user.update_progress
          @user.streak_end.should == Date.civil(2008, 1, 8)
        end
        
        it "calculates longest streak start" do
          @user.update_progress
          @user.longest_streak_start.should == Date.civil(2007, 12, 30)
        end
        
        it "calculates longest streak end" do
          @user.update_progress
          @user.longest_streak_end.should == Date.civil(2008, 1, 3)
        end
      end
      
      describe "(with an existing streak being broken)" do
        before do
          @user.streak_start   = Date.civil(2007, 12, 30)
          @user.streak_end     = Date.civil(2007, 12, 31)
          @user.longest_streak = 2
          @user.current_streak = 2
          @user.stub!(:committed_days_in_feed).and_return []
          Time.stub!(:now).and_return Time.utc(2008, 1, 2)
          User.transaction do
            User.all.destroy!
            Progression.all.destroy!
          end
        end

        it "calculates current streak" do
          @user.update_progress
          @user.current_streak.should == 0
        end
        
        it "calculates longest streak" do
          @user.update_progress
          @user.longest_streak.should == 2
        end
        
        it "calculates streak start" do
          @user.update_progress
          @user.streak_start.should == Date.civil(2007, 12, 30)
        end
        
        it "calculates streak end" do
          @user.update_progress
          @user.streak_end.should == Date.civil(2007, 12, 31)
        end
      end
    end

    describe "#progress_for(year, month)" do
      it "finds progress for given calendar month" do
        @progressions.should include(Date.new(2008, 2, 1))
        @progressions.should include(Date.new(2008, 2, 2))
        @progressions.should_not include(Date.new(2008, 2, 3))
        @progressions.should_not include(Date.new(2008, 1, 1))
        @progressions.should_not include(Date.new(2008, 3, 1))
      end

      before :all do
        User.transaction do
          @user = User.create(:login => 'bob')
          @user.progressions.create(:created_at => Date.new(2008, 1, 1))
          @user.progressions.create(:created_at => Date.new(2008, 2, 1))
          @user.progressions.create(:created_at => Date.new(2008, 2, 2))
          @user.progressions.create(:created_at => Date.new(2008, 3, 1))
          @progressions = @user.progress_for 2008, 2
        end
      end

      after :all do
        User.transaction do
          User.all.destroy!
          Progression.all.destroy!
        end
      end
    end
  end
end