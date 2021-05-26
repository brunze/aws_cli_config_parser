module AwsCliConfigParser
  module Refined
    BLANK_RE = /\A[[:space:]]*\z/

    module Strings
      refine String do

        def blank?
          AwsCliConfigParser::Refined::BLANK_RE === self
        end

      end
    end
  end
end