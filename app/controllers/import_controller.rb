require 'import_logic2'

class ImportController < ApplicationController
  before_action :authenticate_user!

  def new
    ## Doesn't have locale param.
    @import_title = t('import_page.title')
  end

  def create
    file = params[:file]
    if !file.blank? && (file.headers['Content-Type: text/csv'] ||
          file.headers['Content-Type: application/vnd.ms-excel'])
      ## Calls import function below
      result = import(file) 
      unless result[:error]
        flash[:notice] = import_notice(result)
        flash[:notice] = t('import_page.imported')
      end
      redirect_to action: 'new'
    else
      flash[:error] = t('import_page.not_csv')
      flash[:notice] = file.headers unless file.blank?
      redirect_to action: 'new', status: :see_other
    end
  end

  private

  # Imports File,  Here is the Import Call
  def import(file)
    before = Time.zone.now
    begin
      total_lines = ImportLogic.import_csv(file)
    rescue ImportSupport::ImportError => error_message
      flash[:error] = "#{t('import_page.import_failed')}: #{error_message}"
      return { error: error_message }
    end
    after = Time.zone.now
    { toal_time: after - before, total_lines: total_lines, error: nil }
  end

  def import_notice(result = {})
    [result[:total_lines],
     t('import_page.records_imported'),
     result[:total_time],
     t('import_page.seconds')].join(' ')
  end
end
