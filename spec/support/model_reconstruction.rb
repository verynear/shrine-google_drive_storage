module ModelReconstruction
  def reset_class class_name
    ActiveRecord::Base.send(:include, Shrine::Glue)
    Object.send(:remove_const, class_name) rescue nil
    klass = Object.const_set(class_name, Class.new(ActiveRecord::Base))

    klass.class_eval do
      include Shrine::Glue
    end

    klass.reset_column_information
    klass.connection_pool.clear_table_cache!(klass.table_name) if klass.connection_pool.respond_to?(:clear_table_cache!)

    if klass.connection.respond_to?(:schema_cache)
      if ActiveRecord::VERSION::STRING >= "5.0"
        klass.connection.schema_cache.clear_data_source_cache!(klass.table_name)
      else
        klass.connection.schema_cache.clear_table_cache!(klass.table_name)
      end
    end

    klass
  end

  def reset_table table_name, &block
    block ||= lambda { |table| true }
    ActiveRecord::Base.connection.create_table :dummies, {force: true}, &block
  end

  def modify_table table_name, &block
    ActiveRecord::Base.connection.change_table :dummies, &block
  end

  def rebuild_model options = {}
    ActiveRecord::Base.connection.create_table :dummies, force: true do |table|
      table.column :title, :string
      table.column :other, :string
      table.column :document_file_name, :string
      table.column :document_content_type, :string
      table.column :document_file_size, :integer
      table.column :document_updated_at, :datetime
      table.column :document_fingerprint, :string
    end
    rebuild_class options
  end

  def rebuild_class options = {}
    reset_class("Dummy").tap do |klass|
      klass.has_attached_file :document, options
      klass.do_not_validate_attachment_file_type :document
      Shrine.reset_duplicate_clash_check!
    end
  end

  def rebuild_meta_class_of obj, options = {}
    meta_class_of(obj).tap do |metaklass|
      metaklass.has_attached_file :document, options
      metaklass.do_not_validate_attachment_file_type :document
      Shrine.reset_duplicate_clash_check!
    end
  end

  def meta_class_of(obj)
    class << obj
      self
    end
  end
end