require 'rubygems'
require 'ftools'
require 'yaml'

desc "Configuration"
task :config do	
	@proj = Dir.pwd.split("/")[-1]
	if File.exists?("Rakefile.ini")
		@cfg = YAML.load_file("Rakefile.ini")
		# Settings
		@backup = @cfg['settings']['backup']
		@enscript = @cfg['settings']['enscript']
		@zip = @cfg['settings']['zip']
		@gs = @cfg['settings']['gs']
		# Tools / Settings
		# enscript
		@param1 = @cfg['options']['enscript']['opt']
		# gs		
		@param2 = @cfg['options']['gs']['opt']
		# excludes
		@excludes = @cfg['options']['excludes']
	else
		puts "Error loading file: #{cfile}"
	end
end

#################### PROJECT ########################

desc "Create project"
task :new => [:config] do
	Dir.mkdir("dist")
	Dir.mkdir("doc")
	Dir.mkdir("release")
	Dir.mkdir("src")
	File.new("./src/#{@proj}.rb", "w")
	File.open("./src/#{@proj}.rb", "w+") do |f|
     f.puts "# #{@proj}\n#!/usr/bin/env ruby\n#\nrequire 'yaml'\n\n"
     f.puts "#~ # Configuration\ndef config()\n\tcfile = '" + "#{@proj}.ini" + "'\n"
     f.puts "\tif File.exists?(cfile)\n\t\t@cfg = YAML.load_file(cfile)\n"
     f.puts "\t\t# Settings\n\t\t# @temp = @cfg['settings']['temp']\n"
     f.puts "\telse\n\t\tputs 'Error loading file ' + cfile\n\tend\n"
	f.puts "end\n"    
  end
  File.new("./src/#{@proj}.ini", "w")
  File.open("./src/#{@proj}.ini", "w+") do |f|
    f.puts "# #{@proj} configuration\n---\n# Program settings\n"
    f.puts "#settings:\n#\ttemp: 'c:\\temp'\n"
  end
	File.delete("makeproj.exe") if File.exists?("makeproj.exe")
	File.delete("_new.cmd") if File.exists?("_new.cmd")
	File.delete("c:/temp/backup.txt") if File.exists?("c:/temp/backup.txt")
end

desc "Backup project"
task :backup => [:config] do
	Dir.mkdir(@backup) if !File.exists?(@backup)
	bup = "#{@backup}/#{@proj}_#{Time.now.strftime("%d%m%y")}.zip"
	#Clear backup
	File.delete(bup) if File.exist?(bup)
	#~ #Make backup
	system("#{@zip} a #{bup} *.* -r")
end

#################### DISTRIBUTION ########################

desc "Release project"
#~ task :release => [:config, :backup, :make_exe, :installer] do
task :release => [:config, :backup, :make_exe, :make_dist] do		
end

desc "Make EXE"
task :make_exe => [:config] do
	Dir.mkdir("release") if !File.exists?("release") 
	Dir.chdir("src")	
	system("ocra #{@proj}.rb")	
	File.move("./#{@proj}.exe", "../release", true)
	File.copy("./lmstat.exe", "../release", true)
	File.copy("./#{@proj}.ini", "../release", true)	
	File.copy("./autocad.ini", "../release", true)	
	File.copy("./pdms.ini", "../release", true)	
	#~ File.copy("./readmeD.txt", "../release", true)
	#~ File.copy("./readmeE.txt", "../release", true)
	#~ File.copy("./licenseD.txt", "../release", true)
	#~ File.copy("./licenseE.txt", "../release", true)	
end

desc "Make DIST"
task :make_dist => [:config] do
	Dir.chdir("../")
	Dir.mkdir("dist") if !File.exists?("dist") 
	dist = "#{Dir.pwd}/dist/#{@proj}.zip"
	#Clear backup
	File.delete(dist) if File.exist?(dist)
	#~ #Make backup
	system("#{@zip} a #{dist} ./release/*.* -r")	
end

#~ desc "Create installer"
#~ task :installer do
	#~ # InnoSetup installer
	#~ Dir.mkdir("dist") if !File.exists?("dist")
	#~ Dir.chdir("..")
	#~ script = "innosetup.iss"
	#~ installer = "d:/Programmierung/InnoSetup"
	#~ system("#{installer}/iscc.exe /O#{Dir.pwd} /Fuploader_setup  #{script}")
	#~ File.move("uploader_setup.exe", "dist", true)
#~ end

#################### DOCUMENTATION ########################

desc "Create documentation"
task :doc => [:config] do
  Dir.mkdir("doc") if !File.exists?("doc") 
	Dir.chdir("src")
	File.open("header.txt", "w+") do |f|
		f.puts "\n" * 3
		f.puts "DOCUMENTATION (Source)"
		f.puts "=" * 25
		f.puts "\nProject: #{@proj}"
		f.puts "\nFolder: #{Dir.pwd}"
		f.puts "\nStatus: #{Time.now.strftime("%d.%m.%Y")}"
		f.puts "\n------------------------------------------------------------------\n"
		Dir["*.*"].sort.each do |f1|
			if !@excludes.include?(File.extname(f1))
				dt = File.mtime(f1).strftime("%d.%m.%Y %H:%M")
				fline = File.readlines(f1)[0]
				f.puts "#{f1}\t#{dt}\t#{fline}"
			end
		end
	end 
	system(@enscript + " -B -j -r -fCourier-Bold12 -p ../doc/1header.ps header.txt")
	Dir["*"].sort.each do |f|
		system(@enscript + @param1 + "../doc/#{f}.ps #{f}") if !@excludes.include?(File.extname(f))
	end
	#~ # Make PDF
	Dir.chdir("../doc")
	files = ""
	Dir["*.ps"].sort.each { |ps| files << "#{ps} " }
	system(@gs + @param2 + "#{@proj}_Doc.pdf #{files}")
	Dir["*.ps"].each { |ps| File.delete(ps)  if File.exist?(ps) }
	system("start #{@proj}_Doc.pdf")
end
