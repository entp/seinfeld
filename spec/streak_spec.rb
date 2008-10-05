require File.join( File.dirname(__FILE__), "spec_helper" )

module Seinfeld
  describe Streak do
    before :all do
      @now   = Time.now.utc
      @today = Time.utc(@now.year, @now.month, @now.day)
    end

    describe "with neither bounds set" do
      before { @streak = Streak.new }

      it "has 0 days" do
        @streak.days.should == 0
      end

      it "should not include outside date" do
        @streak.should_not include(@now)
      end

      it "knows if it is current" do
        @streak.should_not be_current
      end
    end

    describe "with @ended set" do
      before { @streak = Streak.new(nil, Time.utc(2008, 1, 5)) }

      it "has 0 days" do
        @streak.days.should == 0
      end

      it "should not include outside date" do
        @streak.should_not include(@now)
      end

      it "knows if it is current" do
        @streak.should_not be_current
      end
    end

    describe "with @started and @ended set" do
      before { @streak = Streak.new(Time.utc(2008, 1, 1), Time.utc(2008, 1, 5)) }

      it "has 5 days" do
        @streak.days.should == 5
      end

      it "should not include outside date" do
        @streak.should_not include(@now)
      end

      it "should start date" do
        @streak.should include(Time.utc(2008, 1, 1))
      end

      it "should end date" do
        @streak.should include(Time.utc(2008, 1, 5))
      end

      it "should middle date" do
        @streak.should include(Time.utc(2008, 1, 3))
      end

      it "knows if it is current" do
        @streak.should_not be_current
      end
    end

    describe "with @started and @ended set, ending today" do
      before { @streak = Streak.new(@today - (4 * Streak::SECONDS_IN_DAY), @today) }

      it "has 5 days" do
        @streak.days.should == 5
      end

      it "knows if it is current" do
        @streak.should be_current
      end
    end

    describe "with @started and @ended set, ending yesterday" do
      before { @streak = Streak.new(@today - (5 * Streak::SECONDS_IN_DAY), @today - (1 * Streak::SECONDS_IN_DAY)) }
    
      it "has 5 days" do
        @streak.days.should == 5
      end
    
      it "knows if it is current" do
        @streak.should be_current
      end
    end

    describe "with @started and @ended set, ending 2 days ago" do
      before { @streak = Streak.new(@today - (6 * Streak::SECONDS_IN_DAY), @today - (2 * Streak::SECONDS_IN_DAY)) }
    
      it "has 5 days" do
        @streak.days.should == 5
      end
    
      it "knows if it is current" do
        @streak.should_not be_current
      end
    end
  end
end