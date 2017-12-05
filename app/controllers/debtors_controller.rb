class DebtorsController < ApplicationController
  before_action :authenticate_user!

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
    @debtor = Debtor.find_by_id(params[:id])
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
    @debtor = Debtor.find_by_id(params[:id])
  end

  def update
    # TODO: fix form method to patch or put for SS
    # Probably related to debtor_params below
    assign_current_user
    @debtor = Debtor.find_by_id(params[:id])
    begin
      if @debtor.update_attributes(debtor_params)
        flash[:success] = I18n.t('flash.debtor_info_updated')
        redirect_to @debtor
      else
        render 'edit'
      end
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::StatementInvalid, ActiveRecord::JDBCError => e
      flash.now[:error] = "#{I18n.t('flash.error_on_record_creation')} \t#{e.message}"
      render 'new'
    end
  end

  def index
    assign_current_user

    @debtors =
      if params[:search].blank?
        Debtor.paginate(page: params[:page], per_page: 10)
      else
        Debtor.search(params[:search])
      end

    # @color_code_proc =
    #   lambda do |debtor_debts|
    #     debtor_debts
    #       .collect { |debt| debt.paid_in_full ? 0 : debt.amount_owed_pending_balance }
    #       .reduce(0) { |total, amount| amount + total }
    #   end
  end

  ## Additional Methods ##
  def search
    @debtor = Debtor.search(params[:search])
  end

  private

  def assign_current_user
    @user = current_user
  end

  def debtor_params
    # permited_params =
    #   %i[name email tel ext address location employer_id_number ss_hex_digest]
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
