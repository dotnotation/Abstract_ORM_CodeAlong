class NewPost
    ATTRIBUTES = {
        :id => "INTEGER PRIMARY KEY",
        :title => "TEXT",
        :content => "TEXT",
        :author_name => "TEXT"
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