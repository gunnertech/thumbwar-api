

namespace :db do  
  desc "creates facebook ads"
  task :cleanup => :environment do
  	1.upto(5) do |i|
			Thumbwar.reorder{ id.desc }[i].destroy
  	end
  end
 end