require "spoj_acceptor/version"
require 'rubygems'
require 'mechanize'
require 'fileutils'
require 'set'

module SpojAcceptor

	class SpojAcceptor

		def initialize
			@user_name = ARGV[0].to_s
			@password = ARGV[1].to_s
			@directory_url = ENV["HOME"]+File::SEPARATOR+"#{@user_name}_solutions"
			# Creating directory 
			FileUtils::mkdir_p @directory_url if !File.directory?(@directory_url)
			@all_problems = Hash.new
			@count = 0
			#set for quick lookups
			@downloaded_files = Set.new 
			@downloaded_files = downloaded_solns
			if @user_name.empty? || @password.empty?
				puts "Missing user_name or password."
				exit
			end
			puts "Hello #{@user_name}!"
			@agent = Mechanize.new
			# It establish connection with `spoj.com`
			page = establish_connection			
			# It fills the login form.
			my_page = filling_login_form(page)
			# Validates user and password and terminate if credentials are not correct.
			my_account = validate_user_and_password(my_page)
			# Downloading begins.
			start_download(my_account)
		end

		def establish_connection
			puts "Establishing connection with `www.spoj.com`."
			page = @agent.get('http://www.spoj.com/')
			if page.nil?
				puts "Connection Failed."
				exit
			else
				puts "Connection established."
				puts "Validating User name and password."
			end
			page
		end

		def filling_login_form(page)
			login_page = page.link_with(:text => ' sign in').click
			my_page = login_page.form_with(:action => '/login/') do |f|
			    f.login_user  = @user_name
			    f.password    = @password
			end.click_button
			my_page
		end

		def validate_user_and_password(my_page)
			my_account = my_page.link_with(:href => "/myaccount")
			if my_account.nil?
				puts "Invalid user_name or password. Try again with valid user_name and password."
				exit
			else
				puts "Validated user!!"
				my_account = my_account.click
			end
			my_account
		end

		def store_problem_names(my_account)
			problem_set = my_account.parser.css("table")[0]
			problem_set.search("tr").each do |row|
				row.search("td").each do |col|
					prob_name = col.search("a").text
					if !prob_name.empty?
						@all_problems[prob_name] =  col.css("a")[0]["href"]
						@count += 1
					end
				end
			end
		end

		def print_already_downloaded_files
			if !@downloaded_files.nil?
				puts " "
				puts "!!Already Downloaded Files!!"
				puts "_"*50
				puts " "
				@downloaded_files.map {|file| puts file}
				puts "_"*50
				puts " "
			end
		end

		def start_download(my_account)
			# store all the problem names to @all_problems.
			store_problem_names(my_account)
			# It prints already downloaded files.
			print_already_downloaded_files
			# actual downloading begins here.
			@all_problems.each do |key,value|
				next if @downloaded_files.include?(key)
				w = 'http://www.spoj.com'+value
				prob_page = @agent.get(w)
				list = prob_page.parser.css('table.problems.table.newstatus')[0]
				list.css('tr').each do |row|
					status = row.css('td.statusres')
					if status.css("strong").text == "accepted"
						id = row.css('td.statustext')[0]
						id = id.text
						url = "http://www.spoj.com/files/src/save/" + id.gsub(/\s+/, " ").strip
						puts "Downloading #{key} problem solution..."
						sol = @agent.get(url)
						# Final solution may have any extension. So extension is fetched here.
						# Actual filename 
						filename = sol.header['content-disposition'].split("=")[1]
						# Modified filename as per the problem name.
						filename = key+File.extname(filename)
						# Created file with the accepted code.
						File.open("#{@directory_url}/#{filename}", 'w') {|f| f.write(sol.body) }
						break
					end
				end
			end
			puts "Total number of classical problems solved :- #{@count}."
			puts "Downloading Completed successfully at #{@directory_url}."
		end

		def downloaded_solns
			Dir.entries(@directory_url).select {|f| !File.directory? f}.map {|f| File.basename(f,File.extname(f))}
		end

	end
end
