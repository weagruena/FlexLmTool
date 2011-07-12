# FlexLmTool
#!/usr/bin/env ruby
#
require 'rubygems'
require 'yaml'
require 'win32/process'

def usage(app, server, packages)
	#~ puts packages
	flexlm = []
	msg = ""
	xlines = []	
	if packages[0] == '*'
		flexlm << "#{@lmstat} -c #{server} -a"
	else
		packages.each do |p|
			flexlm << "#{@lmstat} -c #{server} -f #{p}"
		end
	end
	flexlm.each do |flex|
		IO.popen(flex, "r") {|l| msg << l.read}
		#~ puts msg
		lines = msg.split("\n")
		lines.each do |line|
			if line =~ /#{@lics}/
				if $5.to_i > 0
					xlines << "#{$1};#{$3};#{$5};USER"
					user(app, server, $1)	
				end
			end
		end
		msg = ""
	end
	xlines.sort.each {|xline| @lines << xline}	
end

def user(app, server, package)
	#~ puts "#{server} | #{package}"
	flexlm = "#{@lmstat} -c #{server} -f #{package}"
	html = "#{@t}/flexlm_#{package}.html"
	msg = ""
	xlines = []
	IO.popen(flexlm, "r") {|l| msg << l.read}
	#~ puts msg
	if msg != ""
		File.open(html, "w+") do |f|
			f.puts "<HTML><HEAD><TITLE>FlexLM usage</TITLE></HEAD><BODY>"
			f.puts "<H1>#{app}</H1>"
			f.puts "<H3>#{package} (#{server})</H3>"
			f.puts '<TABLE BORDER="1">'
			f.puts '<TR><TH>User</TH><TH>Computer</TH><TH>Start</TH></TR>'
			lines = msg.split("\n")
			lines.each do |line|
				if line =~ /#{@user}/
					f.puts "<TR><TD>#{$1}</TD><TD>#{$2}</TD><TD>#{$4}</TD></TR>"
				end
			end
			f.puts "</TABLE></BODY></HTML>"
		end
	end
end

#~ # Configuration
if !ARGV[0]
	cfile = 'FlexLmTool.ini'
else
	cfile = ARGV[0]
end
if File.exists?(cfile)
	@cfg = YAML.load_file(cfile)
	# Settings
	@clean = @cfg['settings']['clean']
	@t = @cfg['settings']['temp']
	@lmstat = @cfg['settings']['lmstat']
	temp = @t + '/flexlm.html'
	@lics = @cfg['regex']['lics']
	@user = @cfg['regex']['user']
else
	puts 'Error loading file ' + cfile
end
@lines = []

apps = []
@cfg['apps'].each {|app,v| apps << app}
apps.sort.each do |app|	
	appl = @cfg['apps'][app]['descr']
	server = "#{@cfg['apps'][app]['port']}@#{@cfg['apps'][app]['server']}"
	packages = @cfg['apps'][app]['packages']
	@lines << "#{@cfg['apps'][app]['descr']};#{server};*"
	@lines << "Package;Licenses;Used"
	usage(appl, server, packages)
end

File.open("c:/temp/flexlm_test.csv", "w") {|f| f.puts @lines}
table = false

File.open(temp, 'w') do |f|
	f.puts "<HTML><HEAD><TITLE>FlexLM usage</TITLE></HEAD><BODY>"
	f.puts '<H1>FlexLM licenses</H1>'
	@lines.each do |line|
		cols = line.split(";")
		if cols[2] == "*"
			if table
				f.puts '</TABLE>'			
			end
			f.puts '<H2>' + cols[0] + '</H2>'
			f.puts '<TABLE BORDER="1">'
			table = true
		elsif cols[2] == "Used"
			f.puts '<TR bgcolor="#00FFFF">' + "<TH>#{cols[0]}</TH>" + '<TH align="center" width="80">' + cols[1] + '</TH><TH align="center" width="80">' + "#{cols[2]}</TH></TR>"
		else
			if cols[2].to_i > 0
				pack = "#{cols[0]}"
				f.puts '<TR bgcolor="#FFFF80">' + "<TD>#{pack}</TD>" + '<TD align="center">'
				if cols[3] != ""
					html = "#{@t}/flexlm_#{pack}.html"
					link = '<TD><A HREF="' + html + '" target="_blank">>> USER</A></TD></TR>'
				else
					link = "</TR>"
				end
			else
				pack = cols[0]
				f.puts "<TR><TD>#{pack}</TD>" + '<TD align="center">'
			end
			if cols[1] == cols[2]
				f.puts cols[1] + '</TD><TD align="center" bgcolor="red"><B>' + "#{cols[2]}</B></TD>#{link}"
			else
				f.puts cols[1] + '</TD><TD align="center"><B>' + "#{cols[2]}</B></TD>#{link}"
			end
		end
	end
	f.puts "</BODY></HTML>"
end

cmd = "start /WAIT #{temp}"
t = Thread.new { system(cmd) }
t.join
	
if @clean
	Dir.chdir(@t)
	Dir.glob('flexlm*.*').each { |f| File.delete(f) }
end
