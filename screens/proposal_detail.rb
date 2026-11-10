module BomCli
  class ProposalDetailView
    def initialize(screen:, url:, key:, timeout: nil)
      @screen = screen
      @bom_api = BofOMatic::ApiV1.new(url: url, apikey: key)
      @timeout = timeout
      
      @datascreen = @screen.new_datascreen("Title", "Subtitle", "Details go here\nalso here\neven here, too\nand here!")
    end
    
    def present(proposal_id)
      proposal = @bom_api.proposals[proposal_id]

      @screen.titlebar.center = "BoF-O-Matic - Session Details"
      @screen.inputbar.instructions = "I=Express Interest  B=Back  M=Main Menu"
      date_string = Time.now.strftime("%d %^b %Y")
      time_string = Time.now.strftime("%H:%M")
      @screen.titlebar.left = date_string
      @screen.titlebar.right = time_string
      @screen.redraw

      @datascreen.title = proposal.title
      @datascreen.subtitle = proposal.description
      interests = ["Interested:"]
      proposal.interests.each do |data|
        interests << "- #{data.name}"
      end
      proposer_info = "Proposed by #{proposal.submitted_by}"
      schedule_info = "Status: Gathering Interest"
      schedule_info = "Scheduled for #{proposal.start_time.strftime("%A %H:%M")} in #{proposal.room}" if proposal.scheduled
      @datascreen.data = proposer_info + "\n" + schedule_info + "\n\n" + interests.join("\n")

      @datascreen.get_response options: ['i', 'b', 'm'], timeout: @timeout
    end
  end
end
