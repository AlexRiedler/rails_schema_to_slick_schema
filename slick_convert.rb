require 'active_support/inflector'
module ActiveRecord
  class Column
    attr_accessor :name, :type, :limit, :default, :scale, :null, :precision
    def initialize(name, type)
      @name = name
      @type = type
    end

    def skim_type
      case @type
      when "integer"
        "Long"
      when "string"
        "String"
      when "text"
        "String"
      when "float"
        "Double"
      when "decimal"
        "Long"
      when "datetime"
        "java.sql.Timestamp"
      when "timestamp"
        "java.sql.Timestamp"
      when "time"
        "java.sql.Time"
      when "date"
        "java.sql.Date"
      when "binary"
        "java.sql.Blob"
      when "boolean"
        "Boolean"
      end
    end

    def to_skim()
      "    def #{self.name} = column[#{self.skim_type}](\"#{self.name}\")"
    end
  end
  class Table
    attr_accessor :columns, :name

    def initialize(options)
      @name = options[:name]
      @columns = []
    end

    def column(name, type, options = {})
      column = Column.new(name, type)
      if options[:limit]
        column.limit = options[:limit]
      #elsif native[type.to_sym].is_a?(Hash)
      #  column.limit = native[type.to_sym][:limit]
      end
      column.precision = options[:precision]
      column.scale = options[:scale]
      column.default = options[:default]
      column.null = options[:null]
      @columns << column
      self
    end

    %w( string text integer float decimal datetime timestamp time date binary boolean ).each do |column_type|
      class_eval <<-EOV, __FILE__, __LINE__ + 1
        def #{column_type}(*args)                                               # def string(*args)
          options = args.last.is_a?(::Hash) ? args.pop : {}                     #   options = args.extract_options!
          column_names = args                                                   #   column_names = args
                                                                                #
          column_names.each { |name| column(name, '#{column_type}', options) }  #   column_names.each { |name| column(name, 'string', options) }
        end                                                                     # end
      EOV
    end

    def to_skim()
      puts "object #{self.name.classify} extends Table[(#{@columns.collect(&:skim_type).join(', ')})](\"#{self.name}\") {"
      @columns.each do |c|
        puts c.to_skim()
      end
      puts "    def * = #{@columns.collect(&:name).join(' ~ ')}"
      puts "}"
    end
  end
  class Schema
    def self.define(info={}, &block)
      schema = new
      schema.instance_eval(&block)
    end

    def create_table(table_name, options={})
      td = Table.new(name: table_name)
      yield td if block_given?
      puts td.to_skim()
    end
    def add_index(table_name, index_fields, options={})
    end
  end
end
load 'db/schema.rb'
