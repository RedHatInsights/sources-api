module Api
  module V0
    class ServicePlansController < ApplicationController
      include Api::V0::Mixins::IndexMixin
      include Api::V0::Mixins::ShowMixin

      def order
        service_plan = model.find(params_for_order[:service_plan_id].to_i)
        task = Task.create!(:tenant => service_plan.tenant, :state => "pending", :status => "ok")

        messaging_client.publish_message(
          :service => "platform.topological-inventory.operations-openshift",
          :message => "ServicePlan.order",
          :payload => {:task_id => task.id.to_s, :service_plan_id => service_plan.id.to_s, :order_params => params_for_order}
        )

        render :json => {:task_id => task.id}
      rescue ActiveRecord::RecordNotFound
        head :bad_request
      end

      private

      def params_for_order
        @params_for_order ||= params.permit(
          :service_plan_id,
          :service_parameters          => {},
          :provider_control_parameters => {}
        ).to_h
      end

      def messaging_client
        require "manageiq-messaging"

        @messaging_client ||= ManageIQ::Messaging::Client.open(messaging_opts)
      end

      def messaging_opts
        @messaging_opts ||= {
          :protocol => :Kafka,
          :host     => ENV["QUEUE_HOST"] || "localhost",
          :port     => ENV["QUEUE_PORT"] || "9092",
          :encoding => "json"
        }
      end
    end
  end
end
