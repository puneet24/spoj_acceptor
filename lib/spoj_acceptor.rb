require "spoj_acceptor/version"
require 'rubygems'
require 'mechanize'
require 'fileutils'
require 'set'


module SpojAcceptor

	class SpojAcceptor
		
		def initialize
			# changed the directory
			directory_url = ENV["HOME"]+File::SEPARATOR+"solutions"
			FileUtils::mkdir_p directory_url

			all_problems = Hash.new
			user_name = ARGV[0].to_s
			password = ARGV[1].to_s
			all_sol_files = Dir.entries(directory_url)
			all_sol_files.map! {|file| file.split(".")[0] }

			#set for quick lookups
			downloaded_files = Set.new 
			downloaded_files.merge(all_sol_files)

			if user_name.empty? || password.empty?
				puts "Missing user_name or password."
				exit
			end

			puts "Hello #{user_name}!"
			puts "Establishing connection with `www.spoj.com`."

			agent = Mechanize.new

			page = agent.get('http://www.spoj.com/')

			if page.nil?
				puts "Connection Failed."
			else
				puts "Connection established."
				puts "Validating User name and password."
			end

			login_page = page.link_with(:text => ' sign in').click

			my_page = login_page.form_with(:action => '/login/') do |f|
			    f.login_user  = user_name
			    f.password    = password
			end.click_button

			my_account = my_page.link_with(:href => "/myaccount")
			if my_account.nil?
				puts "Invalid user_name or password. Try again with valid user_name and password."
				exit
			else
				puts "Validated user!! Started Downloading..."
				my_account = my_account.click
			end

			problem_set = my_account.parser.css("table")[0]

			count = 0

			problem_set.search("tr").each do |row|
				row.search("td").each do |col|
					prob_name = col.search("a").text
					if !prob_name.empty?
						all_problems[prob_name] =  col.css("a")[0]["href"]
						count += 1
					end
				end
			end

			if !downloaded_files.empty?
				puts "Already Downloaded Files..."
				downloaded_files.map {|file| puts file}
				puts "____________________________"
				puts " "
			end

			all_problems.each do |key,value|

				if downloaded_files.include?(key)
					next
				end
				w = 'http://www.spoj.com'+value
				prob_page = agent.get(w)
				list = prob_page.parser.css('table.problems.table.newstatus')[0]
				list.css('tr').each do |row|
					status = row.css('td.statusres')
					if status.css("strong").text == "accepted"
						id = row.css('td.statustext')[0]
						id = id.text
						url = "http://www.spoj.com/files/src/save/" + id.gsub(/\s+/, " ").strip
						puts "Downloading #{key} problem solution..."
						sol = agent.get(url)

						# Final solution may have any extension. So extension is fetched here.
						# Actual filename 
						filename = sol.header['content-disposition'].split("=")[1]
						# Modified filename as per the problem name.
						filename = key+File.extname(filename)
						# Created file with the accepted code.
						File.open("#{directory_url}/#{filename}", 'w') {|f| f.write(sol.body) }
						break
					end
				end
				#puts prob_page.uri
			end

			puts "Total number of classical problems solved :- #{count}."
			puts "Downloading Completed successfully at #{directory_url}."
		end

	end

end
