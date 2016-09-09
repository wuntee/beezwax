class Beezwax
    class ExitProcessor < AbstractBeezwaxProcessor
      def processCrash
        abort("Crash detected")
      end
    end
end