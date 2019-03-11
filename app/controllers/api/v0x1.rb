module Api
  module V0x1
    class RootController < ApplicationController
      def openapi
        render :json => Api::Docs["0.1"].to_json
      end
    end

    class AuthenticationsController < Api::V0x0::AuthenticationsController
      include Api::V0x1::Mixins::IndexMixin
    end

    class AvailabilitiesController < Api::V0::AvailabilitiesController
      include Api::V0x1::Mixins::IndexMixin
    end

    class ContainersController < Api::V0x0::ContainersController
      include Api::V0x1::Mixins::IndexMixin
    end

    class ContainerGroupsController < Api::V0x0::ContainerGroupsController
      include Api::V0x1::Mixins::IndexMixin
    end

    class ContainerImagesController < Api::V0x0::ContainerImagesController
      include Api::V0x1::Mixins::IndexMixin
    end

    class ContainerNodesController < Api::V0x0::ContainerNodesController
      include Api::V0x1::Mixins::IndexMixin
    end

    class ContainerProjectsController < Api::V0x0::ContainerProjectsController
      include Api::V0x1::Mixins::IndexMixin
    end

    class ContainerTemplatesController < Api::V0x0::ContainerTemplatesController
      include Api::V0x1::Mixins::IndexMixin
    end

    class EndpointsController < Api::V0x0::EndpointsController
      include Api::V0x1::Mixins::IndexMixin
    end

    class FlavorsController < Api::V0x0::FlavorsController
      include Api::V0x1::Mixins::IndexMixin
    end

    class OrchestrationStacksController < Api::V0x0::OrchestrationStacksController
      include Api::V0x1::Mixins::IndexMixin
    end

    class ServiceInstancesController < Api::V0x0::ServiceInstancesController
      include Api::V0x1::Mixins::IndexMixin
    end

    class ServiceOfferingIconsController < Api::V0x0::ServiceOfferingIconsController
      include Api::V0x1::Mixins::IndexMixin
    end

    class ServiceOfferingsController < Api::V0x0::ServiceOfferingsController
      include Api::V0x1::Mixins::IndexMixin
    end

    class ServicePlansController < Api::V0x0::ServicePlansController
      include Api::V0x1::Mixins::IndexMixin
    end

    class SourcesController < Api::V0x0::SourcesController
      include Api::V0x1::Mixins::IndexMixin
    end

    class SourceTypesController < Api::V0x0::SourceTypesController
      include Api::V0x1::Mixins::IndexMixin
    end

    class TagsController < Api::V0x0::TagsController
      include Api::V0x1::Mixins::IndexMixin
    end

    class TasksController < Api::V0x0::TasksController
      include Api::V0x1::Mixins::IndexMixin
      include Api::V0::Mixins::UpdateMixin
    end

    class VmsController < Api::V0x0::VmsController
      include Api::V0x1::Mixins::IndexMixin
    end

    class VolumeAttachmentsController < Api::V0x0::VolumeAttachmentsController
      include Api::V0x1::Mixins::IndexMixin
    end

    class VolumeTypesController < Api::V0x0::VolumeTypesController
      include Api::V0x1::Mixins::IndexMixin
    end

    class VolumesController < Api::V0x0::VolumesController
      include Api::V0x1::Mixins::IndexMixin
    end
  end
end
