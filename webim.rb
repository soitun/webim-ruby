require 'net/http'
require 'uri'
require 'json'

class WebIM
	VERSION = 3
	attr :user
	attr :domain
	attr :apikey
	attr :host
	attr :port
	attr :ticket

	def initialize user, ticket, domain, apikey, host, port = "8000"
		@user = user
		@ticket = ticket ? ticket.strip : nil
		@domain = domain.strip
		@apikey = apikey.strip
		@host = host.strip
		@port = port.strip
	end

	def join room_id
		params = {
			:version => VERSION,
			:ticket => @ticket,
			:apikey => @apikey,
			:domain => @domain,
			:nick => @user[:nick],
			:room => room_id
		}
		res = post('/room/join', params)
		if res and 200 == res.code.to_i
			data = JSON.parse(res.body)
			return {
				:id => room_id,
				:count => data[room_id]
			}
		else
			return nil
		end
	end

	def leave room_id
		params = {
			:version => VERSION,
			:ticket => @ticket,
			:apikey => @apikey,
			:domain => @domain,
			:nick => @user[:nick],
			:room => room_id
		}
		res = post('/room/leave', params)
		return res ? res.body : ""
	end

	def members room_id
		params = {
			:version => VERSION,
			:ticket => @ticket,
			:apikey => @apikey,
			:domain => @domain,
			:room => room_id
		}
		res = get('/room/members', params)
		if res and 200 == res.code.to_i
			data = JSON.parse(res.body)
			return data[room_id]
		else
			return nil
		end
	end

	def status to, show
		params = {
			:version => VERSION,
			:ticket => @ticket,
			:apikey => @apikey,
			:domain => @domain,
			:nick => @user[:nick],
			:to => to,
			:show => show
		}
		res = post('/statuses', params)
		return res ? res.body : ""
	end

	def message type, to, body, style = ""
		params = {
			:version => VERSION,
			:ticket => @ticket,
			:apikey => @apikey,
			:domain => @domain,
			:nick => @user[:nick],
			:type => type,
			:to => to,
			:body => body,
			:style => style,
			:timestamp => Time.now.to_f * 1000
		}
		res = post('/messages', params)
		return res ? res.body : ""
	end

	def presence show, status = ""
		params = {
			:version => VERSION,
			:ticket => @ticket,
			:apikey => @apikey,
			:domain => @domain,
			:nick => @user[:nick],
			:status => status,
			:show => show
		}
		res = post('/presences/show', params)
		return res ? res.body : ""
	end

	def offline 
		params = {
			:version => VERSION,
			:ticket => @ticket,
			:apikey => @apikey,
			:domain => @domain
		}
		res = post('/presences/offline', params)
		return res ? res.body : ""
	end

	def online buddy_ids, room_ids
		params = {
			:version => VERSION,
			:rooms => room_ids,
			:buddies => buddy_ids,
			:domain => @domain,
			:apikey => @apikey,
			:name => @user[:id],
			:nick => @user[:nick],
			:show => @user[:show]
		}
		if @user[:visitor]
			data[:visitor] = @user[:visitor]
		end
		res = post('/presences/online', params)
		if res and 200 == res.code.to_i
			data = JSON.parse(res.body)
			@ticket = data["ticket"]
			buddies = data["buddies"].map do |b|
				{
					:id => b["name"],
					:nick => b["nick"],
					:show => b["show"],
					:presence => "online",
					:status => b["status"]
				}
			end
			rooms = data["rooms"].map do |r|
				{
					:id => r["name"],
					:count => r["total"]
				}
			end
			connection = {
				:ticket => @ticket,
				:domain => @domain,
				:server => "http://" + @host + ":" + @port.to_s + "/packets"
			}
			return {
				:success => true,
				:connection => connection,
				:buddies => buddies,
				:rooms => rooms,
				:server_time => Time.now.to_f * 1000,
				:user => @user
			}
		else
			return {
				:success => false,
				:error_msg => res ? res.body : ""
			}
		end
	end

	private

	def get path, params = {}
		params = params.map {|k,v| "#{URI.escape(k.to_s)}=#{URI.escape(v.to_s)}" }.join("&")
		begin
			http = Net::HTTP.new(@host, @port)
			http.open_timeout = 10
			http.read_timeout = 10
			res = http.get(path + "?" + params)
		rescue 
			res = nil
		end
		return res
	end

	def post path, params = {}
		params = params.map {|k,v| "#{URI.escape(k.to_s)}=#{URI.escape(v.to_s)}" }.join("&")
		begin
			http = Net::HTTP.new(@host, @port)
			http.open_timeout = 10
			http.read_timeout = 10
			res = http.post(path, params)
		rescue 
			res = nil
		end
		return res
	end
end
