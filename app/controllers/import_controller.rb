require 'import_logic2'

class ImportController < ApplicationController
  before_action :authenticate_user!

  def new
    ## Doesn't have locale param.
    @import_title = t('import_page.title')
  end

  # rubocop:disable Metrics/AbcSize
  def create
    file = params[:file]
    if file.blank?
      flash[:error] = t('import_page.not_csv')
      redirect_to action: 'new', status: 303
    elsif file.headers['Content-Type: text/csv'] ||
          file.headers['Content-Type: application/vnd.ms-excel']
      result = import(file) ## Calls import function below
      unless result[:error]
        flash[:notice] = import_notice(result)
        flash[:notice] = t('import_page.imported')
      end
      redirect_to action: 'new'
    else
      flash[:error] = t('import_page.not_csv')
      flash[:notice] = file.headers
      redirect_to action: 'new', status: 303
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  def import(file)
    before = Time.now
    begin
      total_lines = ImportLogic.import_csv(file)
    rescue ImportSupport::ImportError => error_message
      flash[:error] = "#{t('import_page.import_failed')}: #{error_message}"
      return { error: error_message }
    end
    after = Time.now
    { toal_time: after - before, total_lines: total_lines, error: nil }
  end

  def import_notice(result = {})
    [result[:total_lines],
     t('import_page.records_imported'),
     result[:total_time],
     t('import_page.seconds')].join(' ')
  end
end
