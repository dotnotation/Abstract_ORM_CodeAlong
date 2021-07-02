class Post

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS posts(
                id INTEGER PRIMARY KEY,
                title TEXT,
                content TEXT
            )
        SQL

        DB[:conn].execute
    end
end