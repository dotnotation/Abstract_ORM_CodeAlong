class Comment
    #now classes are only responsible for their own attributes and readers
    ATTRIBUTES = {
        :id => "INTEGER PRIMARY KEY",
        :content => "TEXT",
    }

    # ATTRIBUTES.keys.each do |attribute_name|
    #     attr_accessor attribute_name
    # end

    # def self.attributes
    #     ATTRIBUTES
    # end

    include Persistable::InstanceMethods
    extend Persistable::ClassMethods
end