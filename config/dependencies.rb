# dependencies are generated using a strict version, don't forget to edit the dependency versions when upgrading.
merb_gems_version = "1.0.12"

# For more information about each component, please read http://wiki.merbivore.com/faqs/merb_components
dependency "thor", "0.9.9" # 0.11.0 not compatible :(
dependency "merb-core", merb_gems_version 
dependency "merb-action-args", merb_gems_version
dependency "merb-assets", merb_gems_version  
dependency "merb-cache", merb_gems_version do
  Merb::Cache.setup do
    unless defined?(CACHE_SETUP) # HACK: rake tasks are loading this file twice
      register(:fragment_store, Merb::Cache::FileStore, :dir => Merb.root / :tmp / :fragments)
      register(:default, Merb::Cache::AdhocStore[:fragment_store])
      CACHE_SETUP=true
    end
  end
end
dependency "merb-helpers", merb_gems_version 
dependency "merb-mailer", merb_gems_version  
dependency "merb-slices", merb_gems_version  
dependency "merb-auth-core", merb_gems_version
dependency "merb-auth-more", merb_gems_version
dependency "merb-auth-slice-password", merb_gems_version
dependency "merb-param-protection", merb_gems_version
dependency "merb-exceptions", merb_gems_version
dependency "merb-haml", merb_gems_version
dependency "merb-parts", "0.9.8"

dependency "mongo_ext", '0.15.1', :require_as => false
dependency "mongo", '0.15.1'
dependency "activesupport"
dependency "mongo_mapper", '0.5.6'
dependency "merb_mongomapper", '0.1.7', :require_as => 'merb_mongomapper'
dependency "carrierwave"

dependency "RedCloth",  :require_as => 'redcloth'

# if you want run spec you need install webrat gem
dependency "webrat"
dependency "ZenTest", "4.1.4", :require_as => nil
dependency "cucumber", '0.3.104', :require_as => nil 
dependency "roman-merb_cucumber", :require_as => nil 

dependency "randexp"
dependency "machinist", '1.0.4'
dependency "machinist_mongomapper", "0.9.6", :source => 'http://gems.github.com', :require_as => 'machinist/mongomapper'
