module Persistable
    module ClassMethods

        def self.extended(base) #hook, lifecycle, callback
            puts "#{base} has been extended by #{self}"
            base.attributes.keys.each do |attribute_name|
                attr_accessor attribute_name
            end
        end

        def attributes
            self::ATTRIBUTES
        end

        def table_name
            "#{self.to_s.downcase}s"
        end

        def create(attribute_hash)
            self.new.tap do |p|
                attributes_hash.each do |attribute_name, attribute_value|
                    p.send("#{attribute_name}=", attribute_value)
                end
                p.save
        end
    
        def find(id)
            sql = <<-SQL
                SELECT * FROM #{self.table_name} WHERE id = ?
            SQL
    
            row = DB[:conn].execute(sql, id)
            if rows.first
                self.reify_from_row(row.first)
            else
                nil
            end
        end

        def self.reify_from_row(row)
            self.new.tap do |p| #returns the instance
                self.attributes.key.each.with_index do |attribute_name, i|
                    p.send("#{attribute_name}=", row[i])
                end
                #taking each instance, and assigning each attribute to that instance
                #if you add new attributes, you can automatically add that attribute without changing anything other than the ATTRIBUTES
                #p.id = row[0]
                #p.title = row[1]
                #p.content = row[2]
            end
        end
    
        def create_sql
            self.attributes.collect{|attribute_name, schema| "#{attribute_name} #{schema}"}.join(",")
        end
    
        def create_table
            sql = <<-SQL
                CREATE TABLE IF NOT EXISTS #{self.table_name} (
                    #{self.create_sql}
                )
            SQL
    
            #replacing id INTEGER PRIMARY KEY, title TEXT, content TEXT
            DB[:conn].execute(sql)
        end

        def attribute_names_for_insert
            self.attributes.keys[1..-1].join(",") 
            #"title, content" basically every key from the ATTRIBUTES hash except id, and joined with a comma 
        end
    
        def question_marks_for_insert
            (self.attributes.keys.size-1).times.collect{"?"}.join(",")
            #replacing the question marks for the VALUES insert again getting rid of id
        end

        def sql_for_update
            self.attributes.keys[1..-1].collect{|attribute_name| "#{attribute_name} = ?"}.join(",")
            #replacing title = ?, content = ? in update
            #give all the keys except for id
        end
    end

    module InstanceMethods

        def self.included(base) #hook, lifecycle, callback
            puts "#{base} has mixed in #{self}"
        end

        def destroy
            sql = <<-SQL
                DELETE FROM #{self.class.table_name} WHERE id = ?
            SQL
    
            DB[:conn].execute(sql, self.id)
        end

        def ==(other_post)
            self.id == other_post.id
        end

        def save
            #if the post has been saved before, call update, otherwise call insert
            persisted? ? update : insert
        end

        def persisted?
            !!self.id
            #if it has an id then it is true 
            #using !! so it is a boolean
        end

        def attribute_values
            self.class.attributes.key[1..-1].collect{|attribute_name| self.send(attribute_name)}
            #want an array like ["Post Title", "Post Content", "Post Author"] and getting rid of id
        end

        def insert
            sql = <<-SQL
                INSERT INTO #{self.class.table_name} (#{self.class.attribute_names_for_insert}) VALUES (#{self.class.question_marks_for_insert})
            SQL

            DB[:conn].execute(sql, *attribute_values)
            self.id = DB[:conn].execute("SELECT last_insert_rowid();").flatten.first
            #After we insert a post, we need to get the primary key out of the DB
            #and set the id of this instance to that value
        end

        def update
            sql = <<-SQL
                UPDATE posts SET #{self.class.sql_for_update} WHERE id = ?
            SQL

            #replacing title = ?, content = ?

            DB[:conn].execute(sql, *attribute_values, self.id)
        end
    end
end