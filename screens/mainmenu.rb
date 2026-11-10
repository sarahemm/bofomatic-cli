module BomCli
  class MainMenu
    def initialize(screen:, no_exit: false)
      @screen = screen
      @main_menu = @screen.new_menu("Welcome to the BoF-O-Matic System!")
      @main_menu.add_item :proposals, "View Session Proposals"
      @main_menu.add_item :propose, "Propose a BoF"
      #@main_menu.add_item :login, "Scheduler Login"
      @main_menu.add_item :exit,  "Exit" unless no_exit
    end
    
    def present
      @screen.titlebar.center = "BoF-O-Matic"
      date_string = Time.now.strftime("%d %^b %Y")
      time_string = Time.now.strftime("%H:%M")
      @screen.titlebar.left = date_string
      @screen.titlebar.right = time_string
      
      loop do
        response = @main_menu.get_response
        case response
          when :exit
            @screen.destroy
            Kernel.exit
          else
            return response
        end
      end
    end
  end
end
