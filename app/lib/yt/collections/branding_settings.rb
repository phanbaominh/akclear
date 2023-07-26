module Yt
  module Collections
    # @private
    class BrandingSettings < Base
      private

      def attributes_for_new_item(data)
        { data: data['brandingSettings'].merge(data['snippet']), auth: @auth }
      end

      def list_params
        endpoint = @parent.kind.pluralize.camelize :lower
        super.tap do |params|
          params[:path] = "/youtube/v3/#{endpoint}"
          params[:params] = { id: @parent.id, 'part' => 'snippet', part: 'brandingSettings' }
          # use camelize_params to keep the duplicate part keys in params
          # so that .to_query will be part=snippet&part=brandingSettings
          params[:camelize_params] = false
        end
      end
    end
  end
end
