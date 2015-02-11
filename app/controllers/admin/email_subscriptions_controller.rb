module Admin
  class EmailSubscriptionsController < AdminController
    def index
      @email_subscriptions = EmailSubscriptionList.new(FilterForm.new(filter_params))
    end

    def new
      @email_subscription = EmailSubscriptionForm.new
    end

    def create
      email_subscription = EmailSubscription.new(email_subscription_params)

      if email_subscription.save
        redirect_to new_admin_email_subscription_path, success: t(
          '.success',
          name_and_email: email_subscription.name_and_email,
          subscription_type: email_subscription.subscription_type.titleize,
        )
      else
        flash.now[:alert] = t('.alert')
        render :new
      end
    end

    def destroy
      email_subscription = EmailSubscription.find(params[:id])
      email_subscription.destroy

      redirect_to admin_email_subscriptions_path, success: t(
        '.success',
        name_and_email: email_subscription.name_and_email,
        subscription_type: email_subscription.subscription_type.titleize,
      )
    end

    private

    def email_subscription_params
      params.require(:email_subscription)
        .permit(:account_id, :subscription_type)
    end
  end
end
