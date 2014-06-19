module RailsAdminState
  class Configuration
    def initialize(abstract_model)
      @abstract_model = abstract_model
    end

    def options
      @options ||= {
          states: {
            in_development: 'warning',
            pending_review: 'warning',
            scheduled: 'success',
            running: 'success',
            rejected: 'important',
            withdrawn: 'important',
          },
          labels: {
            in_development: 'mark as in_development',
            pending_review: 'mark as pending review',
            scheduled: 'schedule',
            running: 'run',
            rejected: 'reject',
            withdrawn: 'withdraw',
          },
          disable: []
      }.merge(config)
      @options
    end

    def state(name)
      return '' if name.nil?
      options[:states][name.to_sym] || ''
    end

    def label(name)
      return '' if name.nil?
      options[:labels][name.to_sym] || ''
    end

    def disabled?(name)
      return '' if name.nil?
      options[:disable].include? name.to_sym
    end

    def authorize?
      options[:authorize]
    end

    protected
    def config
      begin
        opt = ::RailsAdmin::Config.model(@abstract_model.model).state
        if opt.nil?
          {}
        else
          opt
        end
      rescue
        {}
      end
    end
  end
end
