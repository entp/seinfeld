require File.join( File.dirname(__FILE__), "spec_helper" )

module Seinfeld
  describe Streak do
    before :all do
      @today = Date.today
    end

    describe "with neither bounds set" do
      before { @streak = Streak.new }

      it "has 0 days" do
        @streak.days.should == 0
      end

      it "should not include outside date" do
        @streak.should_not include(@today)
      end

      it "knows if it is current" do
        @streak.should_not be_current
      end
    end

    describe "with @started and @ended set on the same day" do
      before { @streak = Streak.new(Date.civil(2008, 1, 5)) }

      it "has 0 days" do
        @streak.days.should == 1
      end

      it "should not include outside date" do
        @streak.should_not include(@today)
      end

      it "knows if it is current" do
        @streak.should_not be_current
      end
    end

    describe "with @started and @ended set" do
      before { @streak = Streak.new(Date.civil(2007, 12, 31), Date.civil(2008, 1, 5)) }

      it "has 5 days" do
        @streak.days.should == 6
      end

      it "should not include outside date" do
        @streak.should_not include(@today)
      end

      it "should start date" do
        @streak.should include(Date.civil(2007, 12, 31))
      end

      it "should end date" do
        @streak.should include(Date.civil(2008, 1, 5))
      end

      it "should middle date" do
        @streak.should include(Date.civil(2008, 1, 3))
      end

      it "knows if it is current" do
        @streak.should_not be_current
      end
    end

    describe "with @started and @ended set, ending today" do
      before { @streak = Streak.new(@today - 4, @today) }

      it "has 5 days" do
        @streak.days.should == 5
      end

      it "knows if it is current" do
        @streak.should be_current
      end
    end

    describe "with @started and @ended set, ending yesterday" do
      before { @streak = Streak.new(@today - 5, @today - 1) }
    
      it "has 5 days" do
        @streak.days.should == 5
      end
    
      it "knows if it is current" do
        @streak.should be_current
      end
    end

    describe "with @started and @ended set, ending 2 days ago" do
      before { @streak = Streak.new(@today - 6, @today - 2) }
    
      it "has 5 days" do
        @streak.days.should == 5
      end
    
      it "knows if it is current" do
        @streak.should_not be_current
      end
    end
  end
end