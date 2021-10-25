module Gembot
  module Helpers
    macro classvar_getter(var)
      def {{var}}
        @@{{var}}
      end
    end
  end
end
