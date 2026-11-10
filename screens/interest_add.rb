module BomCli
  class ProposalInterestView
    def initialize(screen:, url:, key:, timeout: nil)
      @screen = screen
      @bom_api = BofOMatic::ApiV1.new(url: url, apikey: key)
      @timeout = timeout
      
      @fieldscreen = @screen.new_fieldscreen("BoF-O-Matic - Express Interest", "Subtitle", "Details go here\nalso here\neven here, too\nand here!")
      @fieldscreen = @screen.new_fieldscreen "BoF-O-Matic", "Express Interest", [
        FSTui::Field.new(name: "Name"),
        FSTui::Field.new(name: "Email", required: false),
        FSTui::Field.new(name: "Phone", required: false)
      ]
    end
    
    def present(proposal_id)
      @fieldscreen.clear_fields
      proposal = @bom_api.proposals[proposal_id]

      @screen.titlebar.center = "BoF-O-Matic - Express Interest"
      #date_string = Time.now.strftime("%d %^b %Y")
      #time_string = Time.now.strftime("%H:%M")
      #@screen.titlebar.left = date_string
      #@screen.titlebar.right = time_string
      @screen.redraw

      @fieldscreen.title = "Express Interest"
      @fieldscreen.subtitle = "'#{proposal.title}'"
      
      fields = @fieldscreen.get_response(timeout: @timeout)
      return if fields == nil
      return :timeout if fields == :timeout
      # TODO: clean this up
      name = email = phone = nil
      fields.each do |field|
        name  = field.value if field.name == 'Name'
        email = field.value if field.name == 'Email'
        phone = field.value if field.name == 'Phone'
      end
      proposal.add_interest name: name, email: email, phone: phone
    end
  end
end
