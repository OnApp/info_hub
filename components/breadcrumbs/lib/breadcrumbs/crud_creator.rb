module Breadcrumbs
  class CRUDCreator
    delegate :controller_name, to: :controller

    attr_reader :controller, :breadcrumbs_nested, :params, :action, :breadcrumbs_dependencies, :resource

    NAMESPACE = 'settings'.freeze
    INDEX = 'index'.freeze
    ID = '_id'.freeze

    def self.prepare_params(*args)
      new(*args).prepare_params
    end

    def self.parse_from_url(url, controller_name)
      if url.split('/').include?(NAMESPACE) && controller_name != NAMESPACE
        { title: I18n.t(:title, scope: [NAMESPACE.to_sym, :index]), url: [NAMESPACE] }
      end
    end

    def self.vm_child?(params)
      (params.keys & Breadcrumbs.parent_ids).present?
    end

    def initialize(controller, resource, *args)
      options                     = args.extract_options!
      @breadcrumbs_nested         = options[:breadcrumbs_nested]
      @params                     = controller.params
      @controller                 = controller
      @action                     = params[:action]
      @breadcrumbs_dependencies   = options[:breadcrumbs_dependencies]
      @resource                   = resource
    end

    def prepare_params
      crumbs = []
      is_vm_child = Breadcrumbs::Policy.vm_child?(params)

      if parent && is_vm_child
        crumbs << parent_index_crumb
        crumbs << parent_show_crumb
      end

      resource = parent if is_vm_child
      crumbs << index_crumb(resource) if controller.action_methods.include?(INDEX)

      crumbs
    end

    private

    def index_crumb(resource)
      url = [controller_name.to_sym]
      url.unshift(resource) if parent && Breadcrumbs::Policy.vm_child?(params) && breadcrumbs_nested
      { title: I18n.t("#{controller_name}.index.title"), url: url }
    end

    def parent_index_crumb
      { title: I18n.t("#{parent_controller_name}.index.title"), url: [parent_controller_name.to_sym] }
    end

    def parent_show_crumb
      { title: parent_label, url: [parent] }
    end

    def parent_controller_name
      parent.model_name.to_s.tableize
    end

    def parent_label
      parent.respond_to?(:label) ? parent.label : "#{parent.class.to_s} # #{parent.id}"
    end

    def parent
      Breadcrumbs.parent_ids.each do |parent_id|
        dependency = controller.instance_variable_get("@#{parent_id.chomp(ID)}")

        return dependency if dependency
      end

      nil
    end
  end
end
