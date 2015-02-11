require 'spec_helper'

module Admin
  describe ApplicationSettingsController do
    let(:account) { double(:account, admin?: true) }

    before { stub_logged_in account }

    describe '#edit' do
      let(:application_settings) { double(:application_settings) }

      before do
        allow(ApplicationSettings).to receive(:first_or_create) { application_settings }

        get :edit
      end

      it 'renders the template' do
        expect(response).to render_template :edit
      end

      it 'assigns the application settings' do
        expect(assigns(:application_settings)).to eq application_settings
      end
    end

    describe '#update' do
      let(:application_settings) { double(:application_settings, update: valid) }

      before do
        allow(controller).to receive(:authorize)
        allow(ApplicationSettings).to receive(:first_or_create)
          .and_return(application_settings)
      end

      context 'with valid params' do
        let(:valid) { true }

        it 'authorizes the action' do
          patch :update, application_settings: { sensors_affect_project_status: true, extra: 'value' }

          expect(controller).to have_received(:authorize).with(:unused, :manage?)
        end

        it 'redirects to edit' do
          patch :update, application_settings: { sensors_affect_project_status: true, extra: 'value' }

          expect(response).to redirect_to edit_admin_application_settings_path
        end

        it 'displays a success message' do
          patch :update, application_settings: { sensors_affect_project_status: true, extra: 'value' }

          expect(flash[:success]).to be
        end

        it 'updates the account' do
          patch :update, application_settings: { sensors_affect_project_status: true, extra: 'value' }

          expect(application_settings).to have_received(:update).with(
            'sensors_affect_project_status' => true,
          )
        end
      end

      context 'with invalid params' do
        let(:valid) { false }

        before do
          patch :update, application_settings: { sensors_affect_project_status: 3 }
        end

        it 'redirects to edit' do
          expect(response).to redirect_to edit_admin_application_settings_path
        end

        it 'displays a flash alert message' do
          expect(flash[:alert]).to be
        end
      end
    end
  end
end
