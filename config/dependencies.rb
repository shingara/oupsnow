# dependencies are generated using a strict version, don't forget to edit the dependency versions when upgrading.
merb_gems_version = "1.0.11"
dm_gems_version   = "0.9.11"
do_gems_version   = "0.9.11"

# For more information about each component, please read http://wiki.merbivore.com/faqs/merb_components
dependency "merb-core", merb_gems_version 
dependency "merb-action-args", merb_gems_version
dependency "merb-assets", merb_gems_version  
dependency "merb-cache", merb_gems_version 
dependency "merb-helpers", merb_gems_version 
dependency "merb-mailer", merb_gems_version  
dependency "merb-slices", merb_gems_version  
dependency "merb-auth-core", merb_gems_version
dependency "merb-auth-more", merb_gems_version
dependency "merb-auth-slice-password", merb_gems_version
dependency "merb-param-protection", merb_gems_version
dependency "merb-exceptions", merb_gems_version
dependency "merb-parts", "0.9.8"

dependency "data_objects", do_gems_version
dependency "dm-core", dm_gems_version         
dependency "dm-aggregates", dm_gems_version   
dependency "dm-migrations", dm_gems_version   
dependency "dm-timestamps", dm_gems_version   
dependency "dm-types", dm_gems_version        
dependency "dm-validations", dm_gems_version  
dependency "dm-serializer", dm_gems_version   

dependency "merb_datamapper", merb_gems_version

dependency "dm-sweatshop", dm_gems_version
dependency "dm-tags", dm_gems_version
dependency "dm-constraints", dm_gems_version

dependency "RedCloth", "3.0.4",  :require_as => 'redcloth'
dependency "activesupport", "2.3.2"

# if you want run spec you need install webrat gem
dependency "webrat", :require_as => nil
dependency "cucumber", :require_as => nil 
dependency "roman-merb_cucumber", :require_as => nil 
