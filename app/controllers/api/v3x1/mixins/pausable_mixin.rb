module Api
  module V3x1
    module Mixins
      module PausableMixin
        ALLOWED_ATTRIBUTES_FOR_PAUSED_RESOURCES = %w[
          availability_status
          availability_status_error
          last_checked_at
          last_available_at
        ].freeze

        def update_pausable(record)
          raise ArgumentError, "Method requires block" unless block_given?

          if allowed_update_keys_for(record).empty?
            response = {:status => "422", :detail => failure_message_message_for_unpermitted(params_for_update)}
            render :json => {:errors => [response]}, :status => :unprocessable_entity
          else
            yield(allowed_parameters_for_update(record))

            if partial_update?(record)
              render :json => partial_update_response(allowed_parameters_for_update(record)), :status => :multi_status
            else
              head :no_content
            end
          end
        end

        private

        def partial_update?(record)
          params_for_update.keys.count != allowed_parameters_for_update(record).keys.count
        end

        def allowed_parameters_for_update(record)
          params_for_update.slice(*allowed_update_keys_for(record))
        end

        def allowed_update_keys_for(record)
          update_parameters = params_for_update.keys
          paused?(record) ? update_parameters & allowed_attributes_to_update_for_model : update_parameters
        end

        def failure_message_message_for_unpermitted(parameters)
          "Found unpermitted parameters: #{parameters.keys.sort.join(', ')}"
        end

        def partial_update_response(allowed_parameters)
          success_message = "Listed parameters in 'resource' has been updated successfully."
          success_results = [{:detail => success_message, :resource => allowed_parameters, :status => 200}]

          disallowed_parameters = params_for_update.except(*allowed_parameters.keys)
          error_message = failure_message_message_for_unpermitted(disallowed_parameters)
          {:results => success_results, :errors => [{:detail => error_message, :status => 422 }]}
        end

        def allowed_attributes_to_update_for_model
          model.attribute_names & ALLOWED_ATTRIBUTES_FOR_PAUSED_RESOURCES
        end

        def paused?(record)
          model.include?(Pausable) && record.discarded?
        end
      end
    end
  end
end
