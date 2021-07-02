class NewAuthor
    ATTRIBUTES = {
        :id => "INTEGER PRIMARY KEY",
        :name => "TEXT",
        :state => "TEXT",
        :city => "TEXT",
        :age => "INTEGER"
    }

    ATTRIBUTES.keys.each do |key|
        attr_accessor key
    end

    def self.attributes
        ATTRIBUTES
    end

    include Persistable::InstanceMethods
    extend Persistable::ClassMethods
end