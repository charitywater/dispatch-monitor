require 'spec_helper'

describe ApplicationController do
  describe 'unauthorized action' do
    controller do
      def index
        raise Pundit::NotAuthorizedError
      end
    end

    context 'get requests' do
      before do
        stub_logged_in

        get :index
      end

      it 'redirects to the homepage' do
        expect(response).to redirect_to root_path
      end

      it 'shows a warning message' do
        expect(flash[:warning]).to be
      end
    end

    context 'other requests' do
      before do
        stub_logged_in
      end

      it 'give a 403' do
        post :index
        expect(response.code).to eq '403'

        put :index
        expect(response.code).to eq '403'

        patch :index
        expect(response.code).to eq '403'

        delete :index
        expect(response.code).to eq '403'
      end
    end
  end
end
