require 'webim'

describe "WebIM lib For Ruby" do
	before :all do
		@jack = {
			:id => "jack",
			:nick => "Jack",
			:show => "available"
		}
		@susan = {
			:id => "susan",
			:nick => "Susan",
			:show => "available"
		}
		@webim_susan = WebIM.new(@susan, nil, "webim20.cn", "public", "webim20.cn", "8080")
		@webim_susan.online("jack", "room1,room2")
		@webim_jack = WebIM.new(@jack, nil, "webim20.cn", "public", "webim20.cn", "8080")
	end
	it "can online" do
		data = @webim_jack.online("susan,lily", "room1,room2")
		data[:success].should == true
		data[:buddies].size.should == 1
		data[:rooms].size.should == 2
	end

	it "can set presence" do
		data = @webim_jack.presence("dnd", "I'm buzy")
		data.should == "ok"
	end

	it "can send message" do
		data = @webim_jack.message("unicast", "susan", "Hello.")
		data.should == "ok"
	end

	it "can send status" do
		data = @webim_jack.status("susan", "typing")
		data.should == "ok"
	end

	it "can join room" do
		data = @webim_jack.join("room2")
		data[:count].to_i.should == 2
	end

	it "can get members" do
		data = @webim_jack.members("room1")
		data.size.should == 2
	end
	
	it "can leave room" do
		data = @webim_jack.leave("room2")
		data.should == "ok"
	end

	it "can offline" do
		data = @webim_jack.offline
		data.should == "ok"
	end

end
