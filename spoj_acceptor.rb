require 'rubygems'
require 'mechanize'
require 'fileutils'

puts ARGV[0]
puts ARGV[1]


# changed the directory
directory_url = ENV["userprofile"]+File::SEPARATOR+"solutions"
FileUtils::mkdir_p directory_url

all_problems = Hash.new
user_name = ARGV[0].to_s
password = ARGV[1].to_s

puts "Hello #{user_name}!"
puts "Establishing connection with `www.spoj.com`."

agent = Mechanize.new

page = agent.get('http://www.spoj.com/')

if page.nil?
	puts "Connection Failed."
else
	puts "Connection established."
	puts "Starting downloading accepted solutions"
end

login_page = page.link_with(:text => ' sign in').click

my_page = login_page.form_with(:action => '/login/') do |f|
    f.login_user  = user_name
    f.password    = password
end.click_button
 

my_account = my_page.link_with(:href => "/myaccount").click

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

all_problems.each do |key,value|
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

			#elaborated for better understanding 
			filename = sol.header['content-disposition'].split("=")[1]
			fileformat = filename.split(".")[1]
			filename = key+"."+fileformat

			#not all files are cpp
			#got the file name from the header
			File.open("#{directory_url}/#{filename}", 'w') {|f| f.write(sol.body) }
			break
		end
	end
	#puts prob_page.uri
end

puts count
