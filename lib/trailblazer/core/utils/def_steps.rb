module Trailblazer
  module Core::Utils
    # Helpers to quickly create steps and tasks.
    module DefSteps
      # Creates a module with one step method for each name.
      #
      # @example
      #   extend T.def_steps(:create, :save)
      def self.def_steps(*names)
        Module.new do
          module_function

          names.each do |name|
            define_method(name) do |ctx, seq:, **|
              ctx[:seq] = seq + [name]

              ctx.key?(name) ? ctx[name] : true
            end
          end
        end
      end

      # Creates a method instance with a task interface.
      #
      # @example
      #   task task: T.def_task(:create)
      def self.def_task(name, **options)
        def_tasks(name, **options).method(name)
      end

      def self.def_tasks(*names, success_signal: Activity::Right)
        Module.new do
          module_function

          names.each do |name|
            define_method(name) do |ctx, flow_options, _signal, target_ctx:, **|
              seq = target_ctx[:seq] + [name]

              signal = target_ctx.key?(name) ? target_ctx[name] : success_signal

              return ctx.merge(target_ctx: target_ctx.merge(seq: seq)), flow_options, signal
            end
          end
        end
      end
    end
  end
end
