require_relative '../request'
require_relative '../exceptions'
require_relative 'suggestion'

module SmartyStreets
  module InternationalAutocomplete
    # It is recommended to instantiate this class using ClientBuilder.build_international_autocomplete_api_client
    class Client
      def initialize(sender, serializer)
        @sender = sender
        @serializer = serializer
      end

      # Sends a Lookup object to the International Autocomplete API and stores the result in the Lookup's result field.
      def send(lookup)
        if not lookup or not lookup.search
          raise SmartyStreets::SmartyError, 'Send() must be passed a Lookup with the prefix field set.'
        end

        request = build_request(lookup)

        response = @sender.send(request)

        raise response.error if response.error

        result = @serializer.deserialize(response.payload)
        suggestions = convert_suggestions(result)
        lookup.result = suggestions
      end


      def build_request(lookup)
        request = Request.new

        add_parameter(request, 'search', lookup.search)
        add_parameter(request, 'country', lookup.country)
        add_parameter(request, 'include_only_administrative_area', lookup.administrative_area)
        add_parameter(request, 'include_only_locality', lookup.locality)
        add_parameter(request, 'include_only_postal_code', lookup.postal_code)

        request
      end

      def convert_suggestions(suggestion_hashes)
        converted_suggestions = []
        return converted_suggestions if suggestion_hashes.nil?

        suggestion_hashes.each do |suggestion|
          converted_suggestions.push(InternationalAutocomplete::Suggestion.new(suggestion))
        end

        converted_suggestions
      end

      def add_parameter(request, key, value)
        request.parameters[key] = value unless value.nil? or value.empty?
      end
    end
  end
end

