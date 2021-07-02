class NewAuthor
    #now classes are only responsible for their own attributes and readers
    ATTRIBUTES = {
        :id => "INTEGER PRIMARY KEY",
        :name => "TEXT",
        :state => "TEXT",
        :city => "TEXT",
        :age => "INTEGER"
    }

    ATTRIBUTES.keys.each do |attribute_name|
        attr_accessor attribute_name
    end

    def self.attributes
        ATTRIBUTES
    end

    include Persistable::InstanceMethods
    extend Persistable::ClassMethods
end