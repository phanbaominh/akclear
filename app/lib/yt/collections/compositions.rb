module Yt
  module Collections
    # @private
    class Compositions < Base
      private

      def attributes_for_new_item(data)
        { data: data['brandingSettings'].merge(data['snippet']).merge(data['contentDetails']), auth: @auth,
          id: data['id'] }
      end

      def list_params
        endpoint = @parent.kind.pluralize.camelize :lower
        super.tap do |params|
          params[:path] = "/youtube/v3/#{endpoint}"
          # use compare_by_identity to keep the duplicate 'part' keys in params
          params[:params] = {}.compare_by_identity.tap do |query_params|
            query_params['part'] = 'snippet'
            query_params['id'] = Array(@parent.id).join(',')
            query_params[+'part'] = 'brandingSettings'
            query_params[+'part'] = 'contentDetails'
          end
          # use camelize_params to keep the duplicate part keys in params
          # so that .to_query will be part=snippet&part=brandingSettings
          params[:camelize_params] = false
        end
      end
    end
  end
end
