module Api
  module V3x1
    class DummyController < ApplicationController
      self.openapi_enabled = false

      def list
        if params[:source_id]
          render :status => 200, :json => {
            :data => DummyController.store.values.filter { |v| v[:source_id] == params[:source_id] },
            :meta => {}
          }
        else
          render :status => 200, :json => {
            :data => DummyController.store.values.to_a,
            :meta => {}
          }
        end
      end

      def show
        render :status => 404 and return if DummyController.store[params[:id]].nil?

        render :status => 200, :json => DummyController.store[params[:id]]
      end

      def create
        params.require(:rhc_id)
        params.require(:source_id)

        key = params[:rhc_id]

        DummyController.store[key] = {
          :rhc_id    => params[:rhc_id],
          :extra     => params[:extra] || {},
          :source_id => params[:source_id]
        }.compact

        render :status => 201, :json => DummyController.store[key].merge!(:id => params[:id] || Random.rand(10_000).to_s)
      end

      def edit
        key, _ = DummyController.store.detect { |_k, v| v[:id] == params[:id] }
        render :status => 404, :json => {} and return if key.nil?

        DummyController.store[key][:extra] = params[:extra]

        render :status => 200, :json => DummyController.store[key]
      end

      def self.store
        @store ||= {}
      end
    end
  end
end
