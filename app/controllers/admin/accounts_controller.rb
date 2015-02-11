module Admin
  class AccountsController < AdminController
    def index
      @accounts = AccountList.new(FilterForm.new(filter_params))
    end

    def new
      @account = Account.new(role: nil)
    end

    def create
      @account = Account.new(account_params)

      if @account.save
        redirect_to admin_accounts_path,
          success: t('.success', email: @account.email)
      else
        flash.now[:alert] = t('.alert')
        render :new
      end
    end

    def edit
      @account = Account.find(params[:id])
    end

    def update
      @account = Account.find(params[:id])

      if @account.update(update_account_params)
        if @account == current_account
          sign_in(@account, bypass: true)
        end

        redirect_to admin_accounts_path,
          success: t('.success', email: @account.email)
      else
        flash.now[:alert] = t('.alert')
        render :edit
      end
    end

    def destroy
      @account = Account.find(params[:id])

      @account.destroy
      redirect_to admin_accounts_path,
        success: t('.success', email: @account.email)
    end

    private

    def account_params
      params.require(:account)
        .permit(:name, :email, :password, :role, :program_id)
        .tap do |p|
        p[:name].try(:strip!)
        p[:email].try(:strip!)
      end
    end

    def update_account_params
      params.require(:account)
        .permit(:name, :email, :password, :program_id)
        .tap do |p|
        p[:name].try(:strip!)
        p[:email].try(:strip!)
        p.delete(:password) if p[:password].blank?
      end
    end
  end
end
