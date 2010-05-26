class Attachment
  include Mongoid::Document

  #class << self

    #include CarrierWave::Mount

    #def mount_uploader(column, uploader, options={}, &block)

      #options[:mount_on] ||= "#{column}_filename"
      #key options[:mount_on]
      #super
      #alias_method :read_uploader, :[]
      #alias_method :write_uploader, :[]=


      #after_save "store_#{column}!".to_sym
      #before_save "write_#{column}_identifier".to_sym
      #after_destroy "remove_#{column}!".to_sym
    #end
  #end

  #mount_uploader :attachment, AttachmentUploader

  #timestamps!

end
