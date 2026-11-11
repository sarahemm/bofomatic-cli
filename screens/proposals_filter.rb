module BomCli
  class ProposalsFilterView
    def initialize(screen:, url:, key:, timeout: nil)
      @screen = screen
      @bom_api = BofOMatic::ApiV1.new(url: url, apikey: key)
      @timeout = timeout
      
      @fieldscreen = @screen.new_fieldscreen("BoF-O-Matic - Proposal List Filter", "", "Details go here\nalso here\neven here, too\nand here!")
      @fieldscreen = @screen.new_fieldscreen "BoF-O-Matic", "Proposal List Filter", [
        FSTui::Field.new(name: "Submitter Name", required: false),
        FSTui::Field.new(name: "Session Title", required: false),
        FSTui::Field.new(name: "Session Description", required: false),
      ]
    end
    
    def present
      @fieldscreen.clear_fields

      @screen.titlebar.center = "BoF-O-Matic - Filter Proposal List"
      @screen.redraw

      @fieldscreen.title = "Filter Proposals"
      
      fields = @fieldscreen.get_response(timeout: @timeout)
      return if fields == nil
      return :timeout if fields == :timeout

      filter = {}
      fields.each do |field|
        filter[:name] = field.value         if field.name == 'Submitter Name'
        filter[:title] = field.value        if field.name == 'Session Title'
        filter[:description] = field.value  if field.name == 'Session Description'
      end

      filter
    end
  end
end
