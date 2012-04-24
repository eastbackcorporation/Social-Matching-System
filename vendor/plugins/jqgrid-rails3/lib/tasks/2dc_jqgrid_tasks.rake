namespace :jqgrid do

	if (rails_version_ge_3_1 = File.exist?(File.join(Rails.root, 'app', 'assets')))
		target_dir = File.join(Rails.root, 'vendor', 'assets')		# rails >= 3.1.0
	else
		target_dir = File.join(Rails.root, 'public')			# rails < 3.1.0
	end

	desc "Copy javascripts, stylesheets and images to public or vendor/assets (rails >=3.1)"
	task :install do
		Rake::Task[ "jqgrid:uninstall" ].execute

		# Stylesheets
		source = File.expand_path(File.join(File.dirname(__FILE__),'..', '..', 'public', 'stylesheets'))
		target = File.join(target_dir, 'stylesheets', 'jqgrid')
		FileUtils.mkdir_p target			
		FileUtils.copy_entry(source, target, :verbose => true)

		# Javascripts
		source = File.expand_path(File.join(File.dirname(__FILE__),'..', '..', 'public', 'javascripts'))
		target = File.join(target_dir, 'javascripts', 'jqgrid', 'i18n')
		FileUtils.mkdir_p target			
		FileUtils.copy_entry(File.join(source, 'i18n'), target, :verbose => true)

		target = File.join(target_dir, 'javascripts', 'jqgrid')
		# For rails >3.1.0 jquery already installed and copy jqgrid source instead of minified version.
		if rails_version_ge_3_1
			FileUtils.copy(File.join(source, 'jquery.jqGrid.src.js'), target, :verbose => true)
			FileUtils.copy(File.join(source, 'ui.multiselect.js'), target, :verbose => true)

			# Need to add jquery-ui to application.js if it is not already present.
			js_file = File.join(Rails.root, 'app', 'assets', 'javascripts', 'application.js')
			if File.exist?(js_file)
				js_text = File.read(js_file)
				if js_text !~ /\/\/= require jquery-ui/
					if js_text =~ /\/\/= require jquery\n/
						puts "Adding //= require jquery-ui to application.js"
						js_text.sub!(/\/\/= require jquery\n/, "//= require jquery\n//= require jquery-ui\n")
						File.open(js_file, "w") {|f| f.write(js_text)}
					else
						raise "Rails >=3.1 detected but missing '//= require jquery' line from application.js file"
					end
				end
			else
				raise "Rails >=3.1 detected but missing application.js file"
			end
		else
			files = Dir.glob(File.join(source, '*.min.js'))
			files.each {|f| FileUtils.copy(f, target, :verbose => true)}
			FileUtils.copy(File.join(source, 'ui.multiselect.js'), target, :verbose => true)
		end
	end

	desc 'Remove javascripts, stylesheets and images from public or vendor/assets (rails >=3.1)'
	task :uninstall do
		%w(javascripts stylesheets).each do |dir|
			target = File.join(target_dir, dir, 'jqgrid')
			FileUtils.rm_rf(target, :verbose => true)
		end
	end
end
