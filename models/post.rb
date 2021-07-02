class Post
    attr_accessor :id, :title, :content

    def self.table_name
        "#{self.to_s.downcase}s"
    end

    def self.find(id)
        sql = <<-SQL
            SELECT * FROM #{self.table_name} WHERE id = ?
        SQL

        row = DB[:conn].execute(sql, id)
        self.reify_from_row(row.first)
    end

    def self.reify_from_row(row)
        self.new.tap do |p| #returns the instance
            p.id = row[0]
            p.title = row[1]
            p.content = row[2]
        end
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS #{self.table_name} (
                id INTEGER PRIMARY KEY,
                title TEXT,
                content TEXT
            )
        SQL

        DB[:conn].execute(sql)
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

    private
        def insert
            sql = <<-SQL
                INSERT INTO #{self.class.table_name} (title, content) VALUES (?, ?)
            SQL

            DB[:conn].execute(sql, self.title, self.content)
            self.id = DB[:conn].execute("SELECT last_insert_rowid();").flatten.first
            #After we insert a post, we need to get the primary key out of the DB
            #and set the id of this instance to that value
        end

        def update
            sql = <<-SQL
                UPDATE posts SET title = ?, content = ? WHERE id = ?
            SQL

            DB[:conn].execute(sql, self.title, self.content, self.id)
        end
end