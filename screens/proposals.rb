module BomCli
  class ProposalsView
    def initialize(screen:, url:, key:, timeout: nil)
      @screen = screen
      @bom_api = BofOMatic::ApiV1.new(url: url, apikey: key)
      
      @infolist = @screen.new_infolist("Filter: none applied", 2)
      @infolist.left_heading = "Session Details"
      @infolist.right_heading = "Scheduling Status"

      @timeout = timeout
    end
    
    def present(sort_by: :title)
      order = :ascending
      order = :descending if sort_by == :submitted_at

      @screen.titlebar.center = "BoF-O-Matic - Session Proposals"
      @infolist.clear_items
      @bom_api.proposals(sort_by: sort_by, order: order).each do |proposal|
        schedule_line1 = "Not Scheduled"
        schedule_line2 = ""
        if(proposal.scheduled) then
          schedule_line1 = proposal.start_time.strftime("%A %H:%M")
          schedule_line2 = proposal.room
        end
        @infolist.add_item FSTui::InfoItem.new(key: proposal.id, rows: [
          FSTui::InfoRow.new(lhs: proposal.title, rhs: schedule_line1),
          FSTui::InfoRow.new(lhs: proposal.description, rhs: schedule_line2)
        ])
      end
      date_string = Time.now.strftime("%d %^b %Y")
      time_string = Time.now.strftime("%H:%M")
      @screen.titlebar.left = date_string
      @screen.titlebar.right = time_string
      @screen.redraw
      
      options = {'M' => 'Main Menu'}
      if(sort_by == :title) then
        options['N'] = 'Sort by Newest'
        @infolist.infoline = "Filter: none applied\tSort: Session Title"
      else
        options['N'] = 'Sort by Name'
        @infolist.infoline = "Filter: none applied\tSort: Newest Submissions"
      end

      @infolist.get_response(extra_options: options, timeout: @timeout)
    end
  end
end
