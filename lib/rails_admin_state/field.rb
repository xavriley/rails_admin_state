require 'builder'

module RailsAdmin
  module Config
    module Fields
      module Types
        class AvailableAction < RailsAdmin::Config::Fields::Base
          # Register field type for the type loader
          RailsAdmin::Config::Fields::Types::register(self)
          include RailsAdmin::Engine.routes.url_helpers

          register_instance_option :pretty_value do
            @state_machine_options = ::RailsAdminState::Configuration.new @abstract_model
            v = bindings[:view]

            ret = []
            events = bindings[:object].state_machine.allowed_transitions
            events.each do |event|
              next if @state_machine_options.disabled?(event)
              next unless v.authorized?(:state, @abstract_model, bindings[:object]) && (v.authorized?(:all_events, @abstract_model, bindings[:object]) || v.authorized?(event, @abstract_model, bindings[:object]))
              event_class = @state_machine_options.state(event)
              event_label = @state_machine_options.label(event)
              ret << bindings[:view].link_to(
                "#{event_label}".html_safe,
                state_path(model_name: @abstract_model, id: bindings[:object].id, event: event, attr: name),
                method: :post, 
                class: "btn btn-mini btn-#{event_class}",
                style: 'margin-bottom: 5px;'
              )
            end
            ('<div style="white-space: normal;">' + ret.join(' ') + '</div>').html_safe
          end

          register_instance_option :label do
            "Available Actions"
          end

          register_instance_option :formatted_value do
            form_value
          end

          register_instance_option :form_value do
            @state_machine_options = ::RailsAdminState::Configuration.new @abstract_model
            c = bindings[:controller]
            v = bindings[:view]

            ret = []
            events = bindings[:object].class.state_machines[name.to_sym].events
            empty = true
            bindings[:object].send("#{name}_events".to_sym).each do |event|
              next if @state_machine_options.disabled?(event)
              next unless v.authorized?(:state, @abstract_model, bindings[:object]) && (v.authorized?(:all_events, @abstract_model, bindings[:object]) || v.authorized?(event, @abstract_model, bindings[:object]))
              empty = false
              event_class = @state_machine_options.event(event)
              ret << bindings[:view].link_to(
                events[event].human_name,
                '#',
                'data-attr' => name,
                'data-event' => event,
                class: "state-btn btn btn-mini #{event_class}",
                style: 'margin-bottom: 5px;'
              )
            end
            unless empty
              ret << bindings[:view].link_to(
                I18n.t('admin.state_machine.no_event'),
                '#',
                'data-attr' => name,
                'data-event' => '',
                class: "state-btn btn btn-mini active",
                style: 'margin-bottom: 5px;'
              )
            end
            ('<div style="white-space: normal;">' + ret.join(' ') + '</div>').html_safe
          end
          
          register_instance_option :export_value do
            state = bindings[:object].send(name)
            bindings[:object].class.state_machines[name.to_sym].states[state.to_sym].human_name
          end

          register_instance_option :partial do
            :form_state
          end

          register_instance_option :allowed_methods do
            [method_name, (method_name.to_s + '_event').to_sym]
          end

          register_instance_option :multiple? do
            false
          end
        end

        class State < RailsAdmin::Config::Fields::Base
          # Register field type for the type loader
          RailsAdmin::Config::Fields::Types::register(self)
          include RailsAdmin::Engine.routes.url_helpers

          register_instance_option :pretty_value do
            @state_machine_options = ::RailsAdminState::Configuration.new @abstract_model
            v = bindings[:view]

            state = bindings[:object].send(name)
            state_class = @state_machine_options.state(state)
            state_label = @state_machine_options.label(state)
            ret = [
              '<div class="label label-' + state_class + '">' + state + '</div>',
              '<div style="height: 10px;"></div>'
            ]

            ('<div style="white-space: normal;">' + ret.join(' ') + '</div>').html_safe
          end

          register_instance_option :formatted_value do
            form_value
          end

          register_instance_option :form_value do
            @state_machine_options = ::RailsAdminState::Configuration.new @abstract_model
            c = bindings[:controller]
            v = bindings[:view]

            state = bindings[:object].send(name)
            state_class = @state_machine_options.state(state)
            s = bindings[:object].class.state_machines[name.to_sym].states[state.to_sym]
            ret = [
              '<div class="label ' + state_class + '">' + s.human_name + '</div>',
              '<div style="height: 10px;"></div>'
            ]

            events = bindings[:object].class.state_machines[name.to_sym].events
            empty = true
            bindings[:object].send("#{name}_events".to_sym).each do |event|
              next if @state_machine_options.disabled?(event)
              next unless v.authorized?(:state, @abstract_model, bindings[:object]) && (v.authorized?(:all_events, @abstract_model, bindings[:object]) || v.authorized?(event, @abstract_model, bindings[:object]))
              empty = false
              event_class = @state_machine_options.event(event)
              ret << bindings[:view].link_to(
                events[event].human_name,
                '#',
                'data-attr' => name,
                'data-event' => event,
                class: "state-btn btn btn-mini #{event_class}",
                style: 'margin-bottom: 5px;'
              )
            end
            unless empty
              ret << bindings[:view].link_to(
                I18n.t('admin.state_machine.no_event'),
                '#',
                'data-attr' => name,
                'data-event' => '',
                class: "state-btn btn btn-mini active",
                style: 'margin-bottom: 5px;'
              )
            end
            ('<div style="white-space: normal;">' + ret.join(' ') + '</div>').html_safe
          end
          
          register_instance_option :export_value do
            state = bindings[:object].send(name)
            bindings[:object].class.state_machines[name.to_sym].states[state.to_sym].human_name
          end

          register_instance_option :partial do
            :form_state
          end

          register_instance_option :allowed_methods do
            [method_name, (method_name.to_s + '_event').to_sym]
          end

          register_instance_option :multiple? do
            false
          end
        end
      end
    end
  end
end
