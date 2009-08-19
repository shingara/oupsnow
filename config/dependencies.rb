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

dependency "mongomapper", "~>0.3.3"
dependency "merb_mongomapper", "0.1.3", :require_as => 'merb_mongomapper'

dependency "RedCloth", "3.0.4",  :require_as => 'redcloth'
dependency "activesupport", "2.3.3"

# if you want run spec you need install webrat gem
dependency "webrat", :require_as => nil
dependency "cucumber", :require_as => nil 
dependency "roman-merb_cucumber", :require_as => nil 

dependency "randexp"
dependency "yeastymobs-machinist_mongomapper", :source => 'http://gems.github.com', :require_as => 'machinist/mongomapper'
