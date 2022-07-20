module ApplicationHelper
  include Pagy::Frontend
  include Pagy::Backend

  def table_for(resource_name, scope, opts = {})
    items = opts.fetch(:items) { 10 }
    fields = opts.fetch(:fields) { scope.columns.map(&:name) }
    pagy, records = pagy(scope, items: items)
    builder = TableBuilder.new
    yield builder if block_given?

    render "tables/table",
      records: records,
      pagy: pagy,
      fields: fields,
      cell_renderer: builder.cell_renderer,
      resource_name: resource_name
  end

  def filters_for(resource_name, opts = {})
    opts = opts.merge(view_context: self)
    builder = FiltersBuilder.new(resource_name, opts)
    yield builder if block_given?

    render "tables/filters",
      resource_name: builder.resource_name,
      filters_path: builder.filters_path,
      selects: builder.selects
  end

  class CellRenderer
    def initialize
      @renderers = {}
    end

    def define_field(field, &block)
      @renderers[field] = block
    end

    def render(field, record)
      field_renderer = renderers[field]

      if field_renderer
        field_renderer.call(record)
        nil
      else
        record.public_send(field)
      end
    end

    private

    attr_reader :renderers

    def default_renderer(field, record)
      record.public_send(field)
    end
  end

  class TableBuilder
    attr_reader :cell_renderer

    def initialize
      @cell_renderer = CellRenderer.new
    end

    def cell_for(field, &block)
      cell_renderer.define_field(field, &block)
      nil
    end
  end

  class FiltersBuilder
    attr_reader :resource_name, :opts, :selects

    def initialize(resource_name, opts = {})
      @resource_name = resource_name
      @opts = opts
      @selects = []
    end

    def filters_path
      opts.fetch(:filters_path) do
        view_context.url_for(controler: resource_name)
      end
    end

    def select(field, select_options)
      @selects << {field: field, options: select_options}
      nil
    end

    def view_context
      opts.fetch(:view_context)
    end
  end

end
