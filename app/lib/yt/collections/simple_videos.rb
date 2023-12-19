module Yt
  module Collections
    class SimpleVideos < Base
      private

      def attributes_for_new_item(data)
        { snippet: data['snippet'], auth: @auth, id: data['id'] }
      end

      # @return [Hash] the parameters to submit to YouTube to get the
      #   snippet of a resource, for instance a channel.
      # @see https://developers.google.com/youtube/v3/docs/channels#resource
      def list_params
        super.tap do |params|
          params[:path] = '/youtube/v3/videos'
          params[:params] = { id: Array((@where_params ||= {})[:id]).join(','), part: 'snippet' }
        end
      end

      def list_resources
        'Video'
      end
    end
  end
end
