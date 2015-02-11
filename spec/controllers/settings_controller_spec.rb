require 'spec_helper'

describe SettingsController do
  let(:account) { double(:account) }

  before { stub_logged_in account }

  describe '#edit' do
    before do
      get :edit
    end

    it 'renders the template' do
      expect(response).to render_template :edit
    end

    it 'assigns the current account' do
      expect(assigns(:account)).to eq account
    end
  end

  describe '#update' do
    let(:account) { double(:account, update: valid) }

    context 'with valid params' do
      let(:valid) { true }

      before do
        allow(controller).to receive(:sign_in)
      end

      context 'password is set' do
        it 'redirects to edit' do
          patch :update, account: {
            name: 'First Name Middle Name Last Name Suffix',
            email: 'email@example.org',
            password: 'password123',
            timezone: 'Moon/Dark_Side',
            role: 'super-mega-admin' ,
            weekly_subscription: true,
          }

          expect(response).to redirect_to edit_settings_path
        end

        it 'displays a success message' do
          patch :update, account: {
            name: 'First Name Middle Name Last Name Suffix',
            email: 'email@example.org',
            password: 'password123',
            timezone: 'Moon/Dark_Side',
            role: 'super-mega-admin' ,
            weekly_subscription: true,
          }

          expect(flash[:success]).to be
        end

        it 'updates the account' do
          patch :update, account: {
            name: '  First Name Middle Name Last Name Suffix',
            email: 'email@example.org  ',
            password: 'password123  ',
            timezone: 'Moon/Dark_Side',
            role: 'super-mega-admin' ,
            weekly_subscription: true,
          }

          expect(account).to have_received(:update).with(
            'name' => 'First Name Middle Name Last Name Suffix',
            'email' => 'email@example.org',
            'password' => 'password123  ',
            'timezone' => 'Moon/Dark_Side',
            'weekly_subscription' => true,
          )
        end

        it 'doesn’t sign the user out' do
          patch :update, account: {
            name: '  First Name Middle Name Last Name Suffix',
            email: 'email@example.org  ',
            password: 'password123  ',
            timezone: 'Moon/Dark_Side',
            role: 'super-mega-admin' ,
            weekly_subscription: true,
          }

          expect(controller).to have_received(:sign_in).with(account, bypass: true)
        end
      end

      context 'password is blank' do
        it 'updates only the valid params' do
          patch :update, account: {
            name: '  First Name Middle Name Last Name Suffix',
            email: 'email@example.org  ',
            password: '',
            timezone: 'Moon/Dark_Side',
            role: 'super-mega-admin',
            weekly_subscription: true,
          }

          expect(account).to have_received(:update).with(
            'name' => 'First Name Middle Name Last Name Suffix',
            'email' => 'email@example.org',
            'timezone' => 'Moon/Dark_Side',
            'weekly_subscription' => true,
          )
        end
      end
    end

    context 'with invalid params' do
      let(:valid) { false }

      before do
        patch :update, account: { email: '' }
      end

      it 'renders edit' do
        expect(response).to render_template :edit
      end

      it 'displays a failure alert message' do
        expect(flash.now[:alert]).to be
      end

      it 'updates the account' do
        expect(account).to have_received(:update).with(
          'email' => '',
        )
      end
    end
  end
end
