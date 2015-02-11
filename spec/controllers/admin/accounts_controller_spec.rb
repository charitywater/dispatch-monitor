require 'spec_helper'

module Admin
  describe AccountsController do
    let(:logged_in_account) do
      double(:logged_in_account, update: true, email: '123@example.com')
    end

    before do
      stub_logged_in(logged_in_account)
      allow(controller).to receive_messages(authorize: nil, sign_in: nil)
    end

    describe '#index' do
      it 'renders the "index" template' do
        get :index
        expect(response).to render_template :index
      end

      it 'assigns the list of accounts' do
        get :index
        expect(assigns(:accounts)).to be_a AccountList
      end

      it 'authorizes the action' do
        get :index
        expect(controller).to have_received(:authorize).with(anything, :manage?)
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

      it 'assigns a account' do
        get :new
        expect(assigns(:account)).to be_a Account
      end

      it 'assigns an account with a nil role' do
        get :new
        expect(assigns(:account).role).to be_nil
      end
    end

    describe '#create' do
      let(:account) { double(:account, email: 'test@example.org', save: valid?) }

      before do
        allow(Account).to receive(:new).and_return(account)
      end

      context 'with valid params' do
        let(:valid?) { true }

        before do
          post :create, account: {
            name: ' The Test ',
            email: ' test@example.org',
            password: 'password123 ',
            role: 'admin',
            program_id: '1',
            extra: 'cool'
          }
        end

        it 'authorizes the action' do
          expect(controller).to have_received(:authorize).with(anything, :manage?)
        end

        it 'redirects to Accounts#index' do
          expect(response).to redirect_to admin_accounts_path
        end

        it 'sets a flash success message' do
          expect(flash[:success]).to include 'test@example.org'
        end

        it 'creates a Account' do
          expect(Account).to have_received(:new).with(
            'name' => 'The Test',
            'email' => 'test@example.org',
            'password' => 'password123 ',
            'role' => 'admin',
            'program_id' => '1',
          )
          expect(account).to have_received(:save)
        end
      end

      context 'with invalid params' do
        let(:valid?) { false }

        before do
          post :create, account: { email: '', password: '' }
        end

        it 'renders new' do
          expect(response).to render_template :new
        end

        it 'shows a flash error message' do
          expect(flash[:alert]).to be
        end
      end
    end

    describe '#edit' do
      let(:account) { double(:account, destroy: nil, email: 'delete-me@example.com') }

      before do
        allow(Account).to receive(:find).with('3') { account }

        get :edit, id: 3
      end

      it 'renders the "edit" template' do
        expect(response).to render_template :edit
      end

      it 'assigns the account' do
        expect(assigns(:account)).to eq account
      end

      it 'authorizes the action' do
        expect(controller).to have_received(:authorize).with(anything, :manage?)
      end
    end

    describe '#update' do
      let(:account) { double(:account, update: valid?, email: 'test@example.com') }

      before do
        allow(Account).to receive(:find).with('3') { account }
      end

      context 'with valid params' do
        let(:valid?) { true }

        context 'when password is set' do
          before do
            patch :update, id: 3, account: {
              name: 'My Test ',
              email: ' test@example.com',
              password: 'password123 ',
              role: 'admin',
              program_id: 123,
            }
          end

          it 'authorizes the action' do
            expect(controller).to have_received(:authorize).with(anything, :manage?)
          end

          it 'redirects to index' do
            expect(response).to redirect_to admin_accounts_path
          end

          it 'shows a flash success message' do
            expect(flash[:success]).to include 'test@example.com'
          end

          it 'updates the account' do
            expect(account).to have_received(:update).with(
              'name' => 'My Test',
              'email' => 'test@example.com',
              'password' => 'password123 ',
              'program_id' => '123',
            )
          end
        end

        context 'when password is blank' do
          before do
            patch :update, id: 3, account: {
              email: 'test@example.com',
              password: '',
              role: 'admin',
              program_id: 123
            }
          end

          it 'redirects to index' do
            expect(response).to redirect_to admin_accounts_path
          end

          it 'shows a flash success message' do
            expect(flash[:success]).to include 'test@example.com'
          end

          it 'updates the account' do
            expect(account).to have_received(:update).with(
              'email' => 'test@example.com',
              'program_id' => '123',
            )
          end

          it 'does not log in the updated account' do
            expect(controller).not_to have_received(:sign_in)
          end
        end

        context 'when the account is the current account' do
          let(:account) { logged_in_account }

          before do
            patch :update, id: 3, account: {
              email: '123@example.com',
              password: '',
              role: 'admin',
              program_id: 123
            }
          end

          it 'redirects to index' do
            expect(response).to redirect_to admin_accounts_path
          end

          it 'shows a flash success message' do
            expect(flash[:success]).to include '123@example.com'
          end

          it 'updates the account' do
            expect(account).to have_received(:update).with(
              'email' => '123@example.com',
              'program_id' => '123',
            )
          end

          it 'ensures the current account remains logged in' do
            expect(controller).to have_received(:sign_in).with(account, bypass: true)
          end
        end
      end

      context 'with invalid params' do
        let(:valid?) { false }

        before do
          patch :update, id: 3, account: { email: 'test@example.com' }
        end

        it 'assigns the account' do
          expect(assigns(:account)).to eq account
        end

        it 'renders the "edit" template' do
          expect(response).to render_template :edit
        end

        it 'shows a flash alert message' do
          expect(flash.now[:alert]).to be
        end
      end
    end

    describe '#destroy' do
      let(:account) { double(:account, destroy: nil, email: 'delete-me@example.com') }

      before do
        allow(Account).to receive(:find).with('3') { account }

        delete :destroy, id: 3
      end

      it 'authorizes the action' do
        expect(controller).to have_received(:authorize).with(anything, :manage?)
      end

      it 'destroys the account' do
        expect(account).to have_received(:destroy)
      end

      it 'redirects to the account index' do
        expect(response).to redirect_to(admin_accounts_path)
      end

      it 'displays a flash message' do
        expect(flash[:success]).to include 'delete-me@example.com'
      end
    end
  end
end
