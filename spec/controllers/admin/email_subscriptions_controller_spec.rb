require 'spec_helper'

module Admin
  describe Admin::EmailSubscriptionsController do
    let(:account) { double(:account, admin?: true) }

    before do
      stub_logged_in account
      allow(controller).to receive(:authorize)
    end

    describe '#index' do
      it 'authorizes the action' do
        get :index
        expect(controller).to have_received(:authorize).with(anything, :manage?)
      end

      it 'renders the "index" template' do
        get :index

        expect(response).to render_template "index"
      end

      it 'assigns the list of accounts' do
        get :index
        expect(assigns(:email_subscriptions)).to be_a EmailSubscriptionList
      end
    end

    describe '#new' do
      it 'authorizes the action' do
        get :new
        expect(controller).to have_received(:authorize).with(anything, :manage?)
      end

      it 'renders the "new" template' do
        get :new
        expect(response).to render_template :new
      end

      it 'assigns a subscription' do
        get :new
        expect(assigns(:email_subscription)).to be_a EmailSubscriptionForm
      end
    end

    describe '#create' do
      let(:email_subscription) do
        double(
          :email_subscription,
          name_and_email: 'The name and the email',
          subscription_type: 'subscription_type',
          save: valid?
        )
      end

      before do
        allow(EmailSubscription).to receive(:new) { email_subscription }
      end

      context 'valid params' do
        let(:valid?) { true }

        it 'authorizes the action' do
          post :create, email_subscription: { account_id: 3 }
          expect(controller).to have_received(:authorize).with(anything, :manage?)
        end

        it 'redirects to #new' do
          post :create, email_subscription: {
            account_id: 3,
            subscription_type: :bulk_import_notifications,
            extra: 'thing',
          }
          expect(response).to redirect_to(new_admin_email_subscription_path)
        end

        it 'creates the email subscription with the right params' do
          post :create, email_subscription: {
            account_id: 3,
            subscription_type: :bulk_import_notifications,
            extra: 'thing',
          }

          expect(EmailSubscription).to have_received(:new).with(
            'account_id' => '3',
            'subscription_type' => 'bulk_import_notifications',
          )

          expect(email_subscription).to have_received(:save)
        end

        it 'sets the success flash' do
          post :create, email_subscription: {
            account_id: 3,
            subscription_type: :bulk_import_notifications,
            extra: 'thing',
          }

          expect(flash[:success]).to be
        end
      end

      context 'invalid params' do
        let(:valid?) { false }

        it 'authorizes the action' do
          post :create, email_subscription: { account_id: 3 }
          expect(controller).to have_received(:authorize).with(anything, :manage?)
        end

        it 'renders "new"' do
          post :create, email_subscription: {
            account_id: 3,
            subscription_type: :bulk_import_notifications,
            extra: 'thing',
          }
          expect(response).to render_template :new
        end

        it 'tries to create the email subscription' do
          post :create, email_subscription: {
            account_id: 3,
            subscription_type: :bulk_import_notifications,
            extra: 'thing',
          }

          expect(EmailSubscription).to have_received(:new).with(
            'account_id' => '3',
            'subscription_type' => 'bulk_import_notifications',
          )
        end

        it 'sets the alert now flash' do
          post :create, email_subscription: {
            account_id: 3,
            subscription_type: :bulk_import_notifications,
            extra: 'thing',
          }

          expect(flash.now[:alert]).to be
        end
      end
    end

    describe '#destroy' do
      let(:email_subscription) do
        double(
          :email_subscription,
          name_and_email: 'The name and the email',
          subscription_type: 'subscription_type',
          destroy: nil
        )
      end

      before do
        allow(EmailSubscription).to receive(:find).with('3') { email_subscription }
      end

      it 'authorizes the action' do
        delete :destroy, id: 3

        expect(controller).to have_received(:authorize).with(anything, :manage?)
      end

      it 'destroys the subscription' do
        delete :destroy, id: 3

        expect(email_subscription).to have_received(:destroy)
      end

      it 'sets the success flash' do
        delete :destroy, id: 3

        expect(flash[:success]).to be
      end

      it 'redirects to #index' do
        delete :destroy, id: 3

        expect(response).to redirect_to(admin_email_subscriptions_path)
      end
    end
  end
end
