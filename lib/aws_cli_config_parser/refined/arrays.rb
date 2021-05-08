module AwsCliConfigParser
  module Refined
    module Arrays
      refine Array do

        def index_by
          each_with_object({}){ |value, index| index[yield(value)] = value }
        end

      end
    end
  end
end