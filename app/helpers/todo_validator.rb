# frozen_string_literal: true

class Validator
  class << self
    def validated_params_for_create(params)
      return params if params.key?('title') && params['title'] != '' && !params.key?('completed')
      return params if params['completed'] == true || params['completed'] == false

      raise ActionController::ParameterMissing, 'Wrong parameters for request'
    end

    def validated_params_for_update(params)
      if params.empty? || params['completed'].is_a?(String)
        raise ActionController::ParameterMissing,
              'Wrong parameters for request'
      end

      params
    end
  end
end
