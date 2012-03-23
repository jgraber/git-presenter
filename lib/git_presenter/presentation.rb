module GitPresenter
  class Presentation
    attr_reader :slides

    def initialize(presentation)
      @slides = presentation["slides"].map{|slide| Slide.new(slide)}
      @current_slide = slides.first
    end

    def command_for(command)
      return :commit if command =~ /^[0-9]+$/
      {"n" => :next, "next" => :next,
       "back" => :previous, "b" => :previous,
       "start" => :start, "s" => :start,
       "end" => :end, "e" => :end,
       "list" => :list, "l" => :list,
       "help" => :help, "h" => :help,
       "exit" => :exit
      }[command]
    end

    def execute(user_command)
      command = command_for(user_command)
      if command.nil?
        puts "I canny understand ye, gonna try again"
        return
      end
      return commit(user_command.to_i) if command == :commit
      return :exit if command == :exit
      self.send(command)
    end

    def status_line
      "#{position+1}/#{total_slides} >"
    end

    def position
      slides.index(@current_slide)
    end

    def total_slides
      @slides.length
    end

    def start
      @current_slide = slides.first
      checkout_current
    end

    def help
      <<-EOH
Git Presenter Reference

next/n: move to next slide
back/b: move back a slide
end/e:  move to end of presentation
start/s: move to start of presentation
list/l : list slides in presentation
help/h: display this message
      EOH
    end

    def end
      @current_slide = slides.last
      checkout_current
    end

    def commit(slide_number)
      @current_slide = slides[slide_number - 1]
      checkout_current
    end

    def next
      return if position.nil?
      @current_slide = slides[position + 1] || @current_slide
      checkout_current
    end

    def previous
      return if position == 0
      @current_slide = slides[position - 1]
      checkout_current
    end

    def list
      @slides.map do |slide|
        if slide == @current_slide
          "*#{slide.commit}"
        else
          slide.commit
        end
      end.join("\n")
    end

    def checkout_current
      `git checkout -q . `
      `git checkout -q #{@current_slide.commit}`
    end
  end
end