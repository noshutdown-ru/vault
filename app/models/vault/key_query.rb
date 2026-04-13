module Vault
  class KeyQuery < Query
    self.queried_class = Vault::Key
    self.view_permission = :view_keys

    self.available_columns = [
      QueryColumn.new(:type, sortable: "#{Vault::Key.table_name}.type"),
      QueryColumn.new(:name, sortable: "#{Vault::Key.table_name}.name"),
      QueryColumn.new(:url, sortable: "#{Vault::Key.table_name}.url"),
      QueryColumn.new(:login, sortable: "#{Vault::Key.table_name}.login"),
      QueryColumn.new(:body),
    ]

    def initialize(attributes = nil, *args)
      super(attributes)
      self.filters ||= {}
    end

    def initialize_available_filters
      add_available_filter(
        'type',
        type: :list_optional,
        values: [
          [::I18n.t('activerecord.models.password'), 'Vault::Password'],
          [::I18n.t('activerecord.models.sftp'), 'Vault::Sftp'],
          [::I18n.t('activerecord.models.key_file'), 'Vault::KeyFile']
        ]
      )

      add_available_filter('name', type: :string)
      add_available_filter('url', type: :string)
      add_available_filter('login', type: :string)

      add_available_filter(
        'tags',
        type: :list_optional,
        values: available_tag_values
      )

      add_available_filter(
        'has_url',
        type: :list,
        values: [[l(:general_text_yes), '1'], [l(:general_text_no), '0']]
      )

      add_available_filter(
        'has_login',
        type: :list,
        values: [[l(:general_text_yes), '1'], [l(:general_text_no), '0']]
      )
    end

    def default_columns_names
      @default_columns_names ||= [:type, :name, :url, :login, :body]
    end

    def default_sort_criteria
      [['name', 'asc']]
    end

    def base_scope
      scope = queried_class.joins(:project).where(project_id: project&.id)
      scope = scope.where(statement) if statement.present?
      scope
    end

    def results_scope(options = {})
      scope = base_scope
      scope = apply_live_search(scope, options[:search])

      order_option = [group_by_sort_order, (options[:order] || sort_clause)].flatten.reject(&:blank?)
      order_option << "#{Vault::Key.table_name}.id ASC"

      scope.order(order_option).joins(joins_for_order_statement(order_option.join(','))).distinct
    end

    def sql_for_tags_field(_field, operator, value)
      connection = ActiveRecord::Base.connection
      keys_table = connection.quote_table_name(Vault::Key.table_name)
      tags_table = connection.quote_table_name(Vault::Tag.table_name)
      join_table = connection.quote_table_name('keys_vault_tags')
      ids_column = "#{keys_table}.#{connection.quote_column_name('id')}"
      key_id_column = "#{join_table}.#{connection.quote_column_name('key_id')}"
      tag_id_column = "#{join_table}.#{connection.quote_column_name('tag_id')}"
      tag_name_column = "#{tags_table}.#{connection.quote_column_name('name')}"

      case operator
      when '*'
        "#{ids_column} IN (SELECT DISTINCT #{key_id_column} FROM #{join_table})"
      when '!*'
        "#{ids_column} NOT IN (SELECT DISTINCT #{key_id_column} FROM #{join_table})"
      else
        values = Array(value).reject(&:blank?)
        return operator == '!' ? '1=1' : '1=0' if values.empty?

        quoted_values = values.map { |v| connection.quote(v) }
        key_ids_subquery = "SELECT DISTINCT #{ids_column} FROM #{keys_table} " \
          "INNER JOIN #{join_table} ON #{key_id_column} = #{ids_column} " \
          "INNER JOIN #{tags_table} ON #{tags_table}.#{connection.quote_column_name('id')} = #{tag_id_column} " \
          "WHERE #{tag_name_column} IN (#{quoted_values.join(',')})"

        if operator == '!'
          "#{ids_column} NOT IN (#{key_ids_subquery})"
        else
          "#{ids_column} IN (#{key_ids_subquery})"
        end
      end
    end

    def sql_for_has_url_field(_field, operator, value)
      sql_for_presence_field('url', operator, value)
    end

    def sql_for_has_login_field(_field, operator, value)
      sql_for_presence_field('login', operator, value)
    end

    def sql_for_has_body_field(_field, operator, value)
      sql_for_presence_field('body', operator, value)
    end

    private

    def available_tag_values
      return [] unless project

      Vault::Tag.cloud_for_project(project.id).map { |tag_name| [tag_name, tag_name] }
    end

    def apply_live_search(scope, raw_search)
      search = raw_search.to_s.strip
      return scope if search.blank?

      search.split(/\s+/).reject(&:blank?).each do |token|
        if token.start_with?('#')
          tag_name = token.delete_prefix('#')
          next if tag_name.blank?

          scope = scope.joins(:tags).where("#{Vault::Tag.table_name}.name = ?", tag_name)
        else
          pattern = "%#{queried_class.sanitize_sql_like(token)}%"
          scope = scope.where(
            "#{Vault::Key.table_name}.name LIKE :q OR #{Vault::Key.table_name}.login LIKE :q OR #{Vault::Key.table_name}.url LIKE :q OR #{Vault::Key.table_name}.body LIKE :q",
            q: pattern
          )
        end
      end

      scope
    end

    def sql_for_presence_field(column_name, operator, value)
      positive = value.first.to_s == '1'
      positive = !positive if exclude_operator?(operator)

      if positive
        "(#{Vault::Key.table_name}.#{column_name} IS NOT NULL AND #{Vault::Key.table_name}.#{column_name} <> '')"
      else
        "(#{Vault::Key.table_name}.#{column_name} IS NULL OR #{Vault::Key.table_name}.#{column_name} = '')"
      end
    end

    def exclude_operator?(operator)
      ['!', '!*'].include?(operator)
    end
  end
end
