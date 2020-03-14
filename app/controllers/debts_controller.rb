class DebtsController < ApplicationController
  before_action :authenticate_user!
  ## Mailing Actions should be included here.

  include Pagy::Backend

  ## Resource Actions ##
  def new
    assign_current_user
    @debtor = Debtor.find_by(id: params[:debtor_id])
    @debt = Debt.new
  end

  def edit
    assign_current_user
    @debt = Debt.find_by(id: params[:id])
    @debtor = Debtor.find_by(id: @debt.debtor_id)
  end

  def show
    assign_current_user
    @debt = Debt.find_by(id: params[:id])
    @debtor = Debtor.find_by id: @debt.debtor_id
  end

  # rubocop:disable Metrics/AbcSize
  def create
    assign_current_user
    @debtor = Debtor.find_by(id: params[:debtor_id])
    fail if @debtor.nil?

    params[:debt][:debtor_id] = @debtor.id
    @debt = Debt.new(debt_params)
    # @debt.infraction_number = strip_hyphens(@debt.infraction_number)
    @debt.original_balance = @debt.pending_balance
    if @debt.save
      flash[:success] = I18n.t('flash.new_debt_saved')
      redirect_to @debt
    else
      flash[:error] = I18n.t('flash.debt_not_saved')
      render 'new'
    end
  end
  # rubocop:enable Metrics/AbcSize

  def update
    assign_current_user
    @debt = Debt.find_by(id: params[:id])
    @debtor = Debtor.find_by(id: @debt.debtor_id)
    @debt.infraction_number = strip_hyphens(@debt.infraction_number)
    if @debt.update(update_debt_params) && @debt.valid?
      flash[:success] = I18n.t('flash.debt_updated')
      redirect_to @debt
    else
      flash[:error] = I18n.t('flash.debt_not_updated')
      render 'edit'
    end
  end

  #  Index of all debt and XLS & CSV export
  def index
    #  Responds to xls and csv format and uses pagination
    assign_current_user
    case params['format']
    when 'csv', 'xls' # , 'xlsx'
      @debts_all = Debt.all
    else
      @pagy, @debts_all = pagy(Debt.all, items: 10)
    end
    respond_to do |format|
      format.html
      format.xls
      # format.xlsx
      format.csv { send_data @debts_all.to_csv }
    end
  end

  # def preview_email
  #
  # end

  private

  ## Controller Private Methods ##
  def assign_current_user
    @user = current_user
  end

  def debt_params
    if user_signed_in?
      # Can be determined by role
      params.require(:debt).permit(
        :infraction_number,
        :pending_balance,
        :original_balance,
        :incurred_debt_date,
        :in_payment_plan,
        :debtor_id,
        :fimas_id
      )
    else
      redirect_to new_user_session_path
    end
  end

  def update_debt_params
    ## Update params for non-admin users.
    if user_signed_in?
      # Can be determined by role
      params.require(:debt).permit(
        :infraction_number,
        :pending_balance,
        :incurred_debt_date,
        :in_payment_plan
      )
    else
      redirect_to new_user_session_path
    end
  end
end
