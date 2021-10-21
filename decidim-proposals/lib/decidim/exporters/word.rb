# frozen_string_literal: true

require "caracal"

module Decidim
  module Exporters
    # Exports any serialized object (Hash) into a readable Excel file. It transforms
    # the columns using slashes in a way that can be afterwards reconstructed
    # into the original nested hash.
    #
    # For example, `{ name: { ca: "Hola", en: "Hello" } }` would result into
    # the columns: `name/ca` and `name/es`.
    #
    # It will maintain types like Integers, Floats & Dates so Excel can deal with
    # them.
    class Word < Exporter
      # Public: Exports a file in an Excel readable format.
      #
      # Returns an ExportData instance.
      def export
        docx = Caracal::Document.new('export.docx')

        docx.style id: "metadata", name: "Metadata" do
          color "929292"
        end

        docx.style id: "gray", name: "Gray" do
          color "929292"
        end

        docx.style id: "green", name: "Green" do
          color '61D836'
        end

        docx.style id: "red", name: "Red" do
          color 'EE220C'
        end

        docx

        component = collection.first.component
        participatory_space = collection.first.participatory_space

        if component.name.keys.count > 1
          component.name.each do |language, name|
            docx.h1 "#{language}: #{name}"
          end
        else
          docx.h1 component.name.values.first
        end

        metadata = [
          "ID",
          "participatory space id: #{participatory_space.id}",
          "component id: #{component.id}"
        ]
        docx.p metadata.join(" | "), style: "metadata"
        docx.p

        collection.first.participatory_space.short_description.each do |language, short_description|
          docx.p "short description (#{language}): #{short_description}"
        end
        collection.first.participatory_space.description.each do |language, description|
          docx.p "description (#{language}): #{description}"
        end

        collection.each do |proposal|
          next if proposal.amended.present?

          docx.hr
          if proposal.title.keys.count > 1
            if proposal.component.settings.hide_participatory_text_titles_enabled? == false
              proposal.title.each do |language, title|
                docx.h2 "title (#{language}): #{title}"
              end
            end
            proposal.body.each do |language, body|
              docx.p do
                text "body (#{language}): ", bold: true
                text body
              end
            end
          else
            if proposal.component.settings.hide_participatory_text_titles_enabled? == false
              docx.h2 "title: #{proposal.title.values.first}"
            end
            docx.p do
              text "body: ", bold: true
              text proposal.body.values.first
            end
          end

          # possible states: not_answered evaluating accepted rejected withdrawn
          case proposal.state
          when "accepted"
            docx.p proposal.state, bold: true, color: '61D836'
          when "evaluating", ""
            docx.p proposal.state, bold: true, color: 'FFD932'
          when "rejected"
            docx.p proposal.state, bold: true, color: 'EE220C'
          when "not_answered", "withdrawn"
            docx.p proposal.state, bold: true, color: '929292'
          end

          docx.p "Reference: #{proposal.reference}", style: "gray"
          docx.p "Followers: #{proposal.followers.count}", style: "gray"

          docx.p do
            text "Supports: ", bold: true
            text proposal.votes.count
          end

          docx.p do
            text "endorsements/total_count: ", bold: true
            text proposal.endorsements.count
          end

          docx.p do
            text "comments: ", bold: true
            text proposal.comments.count
          end

          docx.p

          if proposal.comments.any?
            docx.h3 "Comments to this proposal:"

            proposal.comments.where(depth: 0).each do |comment|
              print_comment(comment, docx)
            end
            
            docx.p
          end

          if proposal.amendments.any?
            docx.h3 "Amendments:"

            proposal.amendments.each do |amendment|
              if proposal.component.settings.hide_participatory_text_titles_enabled? == false
                docx.p "Amendment title: #{amendment.emendation.title.values.first}", bold:true
              end
              docx.p amendment.emendation.body.values.first

              docx.p do
                text "Amendment ID: ", bold: true
                text amendment.id
                text "Proposal ID: ", bold: true
                text amendment.emendation.id
              end

              docx.p do
                text "created: ", bold: true
                text amendment.created_at
              end

              docx.p do
                text "author(s): ", bold: true
                text amendment.emendation.authors.collect {|a| "#{a.name} (#{a.id})"}.join (", ")
              end

              case amendment.amendable.state
              when "accepted"
                docx.p amendment.amendable.state, bold: true, color: '61D836'
              when "evaluating", ""
                docx.p amendment.amendable.state, bold: true, color: 'FFD932'
              when "rejected"
                docx.p amendment.amendable.state, bold: true, color: 'EE220C'
              when "not_answered", "withdrawn"
                docx.p amendment.amendable.state, bold: true, color: '929292'
              end

              docx.p "Reference: #{proposal.reference}", style: "gray"
              docx.p "Followers: #{proposal.followers.count}", style: "gray"

              docx.p do
                text "Supports: ", bold: true
                text proposal.votes.count
              end

              docx.p do
                text "endorsements/total_count: ", bold: true
                text proposal.endorsements.count
              end

              docx.p do
                text "comments: ", bold: true
                text proposal.comments.count
              end
            end
          end
        end

        # docx.p collection.inspect
        
        #processed_collection.each_with_index do |resource, index|
          #if resource[header].respond_to?(:strftime)
          # resource[header].is_a?(Date) ? cell.set_number_format("dd.mm.yyyy") : cell.set_number_format("dd.mm.yyyy HH:MM:SS")

        #ExportData.new(workbook.stream.string, "xlsx")
        doxc_buffer = docx.render
        doxc_buffer.rewind
        ExportData.new(doxc_buffer.sysread, "docx")
      end

      private

      def print_comment(comment, docx)
        docx.p do
          text (" " * (comment.depth + 1))
          text "Body: ", bold: true
          text comment.body.values.first
        end

        docx.p do
          text (" " * (comment.depth + 1))
          text "ID: ", bold: true
          text comment.id
        end

        docx.p do
          text (" " * (comment.depth + 1))
          text "created: ", bold: true
          text comment.created_at
        end

        docx.p do
          text (" " * (comment.depth + 1))
          text "author: ", bold: true
          text "#{comment.author.name} (#{comment.author.id})"
        end

        docx.p do
          text (" " * (comment.depth + 1))
          text "alignment: ", bold: true
          case comment.alignment
          when 1
            text "in favor", color: "61D836"
          when 0
            text "neutral", color: "929292"
          when -1
            text "against", color: "EE220C"
          end
        end

        if comment.user_group.present?
          docx.p do
            text (" " * (comment.depth + 1))
            text "user-group id: ", bold: true
            text "#{comment.decidim_user_group_id}"
          end

          docx.p do
            text (" " * (comment.depth + 1))
            text "user-group name: ", bold: true
            text comment.user_group.name
          end
        end

        # find comments to this comment and print them recursively
        Decidim::Comments::Comment.where(decidim_commentable_id: comment.id).each do |comment|
          print_comment(comment, docx)
        end
      end
    end
  end
end
