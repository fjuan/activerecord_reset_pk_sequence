require 'activerecord-reset-pk-sequence/version'

module ActiveRecord
  class Base
    class << self
      def reset_pk_sequence
        case ActiveRecord::Base.connection.adapter_name
        when 'SQLite'
          ActiveRecord::Base.connection.execute(sqlite_update_seq_sql)
        when 'Mysql'
          ActiveRecord::Base.connection.execute(mysql_update_seq_sql)
        when 'PostgreSQL'
          ActiveRecord::Base.connection.reset_pk_sequence!(table_name)
        else
          raise 'Task not implemented for this DB adapter'
        end
      end

      private

      def sqlite_update_seq_sql
        new_max_id = maximum(primary_key) || 0
        "UPDATE sqlite_sequence SET seq = #{new_max_id} WHERE name = '#{table_name}';"
      end

      def mysql_update_seq_sql
        new_max_id = maximum(primary_key) + 1 || 1
        "ALTER TABLE '#{table_name}' AUTO_INCREMENT = #{new_max_id};"
      end
    end
  end
end
