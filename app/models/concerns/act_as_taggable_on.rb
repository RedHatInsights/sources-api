module ActAsTaggableOn
  def acts_as_taggable_on
    class_eval do
      def self.tagging_relation_name
        "#{name.underscore}_tags".to_sym
      end

      has_many tagging_relation_name
      has_many :tags, :through => tagging_relation_name

      def self.taggable?
        true
      end

      def tag_list
        tags.pluck(:name)
      end

      def tag_add(tag_list, options = {})
        Tag.transaction do
          model_tag_class.transaction do
            Array(tag_list).each do |tag_name|
              next if tagged_with?(tag_name, options)
              tag_params = {:name => tag_name, :tenant_id => tenant.id}
              tag_params.merge!(options)
              tag = Tag.find_or_create_by(tag_params)
              tagging_params = {self.class.name.underscore.to_sym => self, :tag_id => tag.id}
              public_send(self.class.tagging_relation_name).create(tagging_params)
            end
          end
        end
      end

      def tagged_with?(tag_name, options = {})
        options[:value] ||= ""
        options[:namespace] ||= ""
        model_tag_class.joins(:tag)
                       .exists?(:tags => {:name => tag_name, :namespace => options[:namespace], :value => options[:value]}, self.class.name.underscore.to_sym => self)
      end

      def tag_remove(tag_list, options = {})
        options[:value] ||= ""
        options[:namespace] ||= ""
        Tag.joins(self.class.tagging_relation_name)
           .where(:name => Array(tag_list), :namespace => options[:namespace], :value => options[:value], self.class.tagging_relation_name => {self.class.name.underscore.to_sym => self})
           .destroy_all
      end

      def model_tag_class
        self.class.tagging_relation_name.to_s.classify.constantize
      end
    end
  end

  def tagged_with(tag_name, options = {})
    options[:value] ||= ""
    options[:namespace] ||= ""
    joins(tagging_relation_name => :tag).where(:tags => {:name => tag_name, :namespace => options[:namespace], :value => options[:value]})
  end
end
