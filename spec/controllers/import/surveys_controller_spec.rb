require 'spec_helper'

module Import
  describe SurveysController do
    before do
      stub_logged_in
      allow(controller).to receive(:authorize)
    end

    describe '#new' do
      it 'renders the "new" template' do
        get :new

        expect(response).to render_template :new
      end

      it 'authorizes the action' do
        get :new

        expect(controller).to have_received(:authorize).with(anything, :manage?)
      end

      it 'assigns the import survey' do
        get :new

        expect(assigns(:import_survey)).to be_a Import::Survey
      end
    end

    describe '#create' do
      let(:import_survey) { double(:import_survey, save: valid, survey_type: 'the_type') }

      before do
        allow(Import::Survey).to receive(:new) { import_survey }
      end

      context 'with valid params' do
        let(:valid) { true }

        it 'saves the import survey with the correct parameters' do
          post :create, import_survey: { survey_type: 'the_type', extra: '' }

          expect(Import::Survey).to have_received(:new).with('survey_type' => 'the_type')
        end

        it 'redirects to the projects path' do
          post :create, import_survey: { survey_type: 'the_type' }

          expect(response).to redirect_to projects_path
        end

        it 'sets a flash info message' do
          post :create, import_survey: { survey_type: 'the_type' }

          expect(flash[:info]).to be
        end

        it 'authorizes the action' do
          post :create, import_survey: { survey_type: 'the_type' }

          expect(controller).to have_received(:authorize).with(anything, :manage?)
        end
      end

      context 'with invalid params' do
        let(:valid) { false }

        it 'renders the "new" template' do
          post :create, import_survey: { survey_type: 'the_type' }

          expect(response).to render_template :new
        end

        it 'sets a flash alert message' do
          post :create, import_survey: { survey_type: 'the_type' }

          expect(flash.now[:alert]).to be
        end
      end
    end
  end
end
