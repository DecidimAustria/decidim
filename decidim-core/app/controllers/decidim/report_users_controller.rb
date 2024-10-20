# frozen_string_literal: true

module Decidim
  class ReportUsersController < ApplicationController
    include FormFactory
    include NeedsPermission

    before_action :authenticate_user!

    def create
      enforce_permission_to :create, :user_report

      @form = form(Decidim::ReportForm).from_params(params)

      CreateUserReport.call(@form, reportable) do
        on(:ok) do
          flash[:notice] = I18n.t("decidim.reports.create.success")
          if @form.block?
            redirect_to decidim_admin.new_user_block_path(user_id: reportable.id, hide: form.hide?)
          else
            redirect_back fallback_location: root_path
          end
        end

        on(:invalid) do
          flash[:alert] = I18n.t("decidim.reports.create.error")
          redirect_back fallback_location: root_path
        end
      end
    end

    private

    def reportable
      @reportable ||= GlobalID::Locator.locate_signed params[:sgid]
    end

    def permission_class_chain
      [Decidim::ReportUserPermissions, Decidim::Permissions]
    end

    def permission_scope
      :public
    end
  end
end
