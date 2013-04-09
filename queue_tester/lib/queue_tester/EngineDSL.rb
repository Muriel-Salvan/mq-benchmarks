module QueueTester

  module EngineDSL

    # Initialize engine
    def init
      @progress = 0
      @finished = false
    end

    # Get progress
    def get_progress
      return @progress
    end

    # Get finished state
    def get_finished
      return @finished
    end

    # Set finished state
    def set_finished(finished)
      @finished = finished
    end

    # Notify a progress
    def progress(increment)
      @progress += increment
    end

  end

end
