class Merb::Authentication
  module Mixins
    module SaltedUser
      module MongoMapperClassMethods
        def self.extended(base)
          base.class_eval do
            
            key :crypted_password, String, :required => true
            key :salt, String, :required => true
            
            validates_presence_of :password, :if => proc{|m| m.password_required?}
            validates_true_for    :password, :logic  => lambda { password == password_confirmation }

            before_validation :encrypt_password

          end # base.class_eval
          
        end # self.extended
        
        def authenticate(login, password)
          @u = find(:first, :conditions => {:login => login })
          @u && @u.authenticated?(password) ? @u : nil
        end
      end # DMClassMethods      
    end # SaltedUser
  end # Mixins
end # Merb::Authentication
