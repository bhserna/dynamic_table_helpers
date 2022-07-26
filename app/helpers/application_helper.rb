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
      element_builders: builder.element_builders
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

  class SelectBuilder
    include ActiveModel::Model
    attr_accessor :resource_name, :field, :select_options
    
    def to_partial_path
      "tables/filters/select"
    end

    def render_attributes(f, params)
      { f: f, resource_name: resource_name, field: field, options: select_options, value: params[field] }
    end
  end

  class TextFieldBuilder
    include ActiveModel::Model
    attr_accessor :resource_name, :field

    def to_partial_path
      "tables/filters/text_field"
    end

    def render_attributes(f, params)
      { f: f, resource_name: resource_name, field: field, value: params[field] }
    end
  end

  class FiltersBuilder
    attr_reader :resource_name, :opts, :element_builders

    def initialize(resource_name, opts = {})
      @resource_name = resource_name
      @opts = opts
      @element_builders = []
    end

    def filters_path
      opts.fetch(:filters_path) do
        view_context.url_for(controler: resource_name)
      end
    end

    def select(field, select_options)
      @element_builders << SelectBuilder.new(resource_name: resource_name, field: field, select_options: select_options)
      nil
    end

    def text_field(field)
      @element_builders << TextFieldBuilder.new(resource_name: resource_name, field: field)
      nil
    end

    def view_context
      opts.fetch(:view_context)
    end
  end
end
