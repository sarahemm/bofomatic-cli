module BomCli
  class ProposeNewView
    def initialize(screen:, url:, key:)
      @screen = screen
      @bom_api = BofOMatic::ApiV1.new(url: url, apikey: key)
      
      @fieldscreen = @screen.new_fieldscreen "BoF-O-Matic", "Propose New Session", [
        FSTui::Field.new(name: "Your Name"),
        FSTui::Field.new(name: "Email"),
        FSTui::Field.new(name: "Phone", required: false),
        FSTui::Field.new(name: "Session Title"),
        FSTui::Field.new(name: "Description"),
        FSTui::Field.new(name: "Notes for Scheduler", required: false)
      ]
    end
    
    def present
      @fieldscreen.clear_fields
      # just check to make sure we can access the server
      # if we can't, better to bail out now than have them fill in a bunch of info
      @bom_api.proposals[0]
      #date_string = Time.now.strftime("%d %^b %Y")
      #time_string = Time.now.strftime("%H:%M")
      #@screen.titlebar.left = date_string
      #@screen.titlebar.right = time_string
      @screen.redraw

      #@fieldscreen.title = "Propose Session"
      #@fieldscreen.subtitle = "'#{proposal.title}'"
      
      fields = @fieldscreen.get_response
      return if fields == nil
      # TODO: clean this up
      submitted_by = submitter_email = submitter_phone = session_title = session_description = scheduler_notes = nil
      fields.each do |field|
        submitted_by = field.value        if field.name == 'Your Name'
        submitter_email = field.value     if field.name == 'Email'
        submitter_phone = field.value     if field.name == 'Phone'
        session_title = field.value       if field.name == 'Session Title'
        session_description = field.value if field.name == 'Description'
        scheduler_notes = field.value     if field.name == 'Notes for Scheduler'
      end
      @bom_api.proposals.new submitted_by: submitted_by, submitter_email: submitter_email, submitter_phone: submitter_phone, session_title: session_title, session_description: session_description, scheduler_notes: scheduler_notes
    end
  end
end
