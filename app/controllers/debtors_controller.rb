class DebtorsController < ApplicationController
  before_action :authenticate_user!

  include Pagy::Backend

  ## Resource Actions ##
  def new
    assign_current_user
    @debtor = Debtor.new
  end

  def create
    assign_current_user
    @debtor = Debtor.new(debtor_params)
    begin
      if @debtor.save
        flash[:success] = I18n.t('flash.new_record_created')
        redirect_to @debtor
      else
        flash.now[:warning] = I18n.t('flash.warning_on_record_creation')
        render 'new'
      end
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::StatementInvalid, ActiveRecord::JDBCError => e
      flash.now[:error] = "#{I18n.t('flash.error_on_record_creation')} \t#{e.message}"
      render 'new'
    end
  end

  def show
    assign_current_user
    @debtor = Debtor.find_by(id: params[:id])
  end

  def destroy
    assign_current_user # Should only be certain users --> Supervisor users.
    ##  With 'dependency: restrict' only debtors w/ no debt can be deleted.
    begin
      Debtor.find(params[:id]).destroy
      flash[:success] = I18n.t('flash.debtor_record_erased')
    rescue ActiveRecord::DeleteRestrictionError => e
      flash[:error] = e
      raise e
    end
    redirect_to debtors_url
  end

  def edit
    assign_current_user
    @debtor = Debtor.find_by(id: params[:id])
  end

  def update
    # TODO: fix form method to patch or put for SS
    # Probably related to debtor_params below
    assign_current_user
    @debtor = Debtor.find_by(id: params[:id])
    begin
      if @debtor.update(debtor_params)
        flash[:success] = I18n.t('flash.debtor_info_updated')
        redirect_to @debtor
      else
        render 'edit'
      end
    rescue ActiveRecord::RecordNotUnique,
           ActiveRecord::StatementInvalid,
           ActiveRecord::JDBCError => e
      flash.now[:error] = "#{I18n.t('flash.error_on_record_creation')} \t#{e.message}"
      render 'new'
    end
  end

  def index
    # #TODO this is not getting the locale param passed from the search action
    assign_current_user

    sort_order = (sort_column + " " + sort_direction)
    @direction = sort_direction
    if params[:search].blank? && sort_column != 'total_balance'
      @pagy, @debtors = pagy(Debtor.all.order(sort_order), items: 10)
    elsif sort_column == 'total_balance'
      @pagy, @debtors = pagy(
        Debtor
        .joins(:debts)
        .group('debts.pending_balance')
        .order(Arel.sql("SUM(debts.pending_balance) #{sort_direction}"))
        .references(:debts), items: 10)
    else
      @debtors = Debtor.search(params[:search], sort_order)
    end
  end

  ## Additional Methods ##
  def search
    sort_order = (sort_column + " " + sort_direction)
    @debtor = Debtor.search(params[:search], sort_order)
  end

  private

  def sort_column
    if Debtor.column_names.push('total_balance').include?(params[:sort])
      params[:sort]
    else
      "id"
    end
  end

  def sort_direction
    if %w[asc desc].include?(params[:direction])
      params[:direction]
    else
      "asc" # default
    end
  end

  def assign_current_user
    @user = current_user
  end

  def debtor_params
    if user_signed_in?
      params.require(:debtor).permit(:name, :email, :tel, :ext, :address,
                                     :location,
                                     :employer_id_number,
                                     :ss_hex_digest)
    else
      redirect_to new_user_session_path
    end
  end
end
