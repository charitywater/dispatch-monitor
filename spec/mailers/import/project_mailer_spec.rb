require 'spec_helper'

module Import
  describe ProjectMailer do
    describe '#results' do
      let(:account) do
        double(
          :account,
          name: 'Kristy Conner',
          name_and_email: 'Kristy Conner <kristy.conner@example.com>',
        )
      end
      before do
        allow(Account).to receive(:find).with(5) { account }
      end

      it 'has the right subject' do
        email = ProjectMailer.results(
          results: { created: ['DEP1'] }, recipient_id: 5
        )
        expect(email.subject).to eq 'Your project import has finished'
      end

      it 'has the right recipient' do
        email = ProjectMailer.results(results: {}, recipient_id: 5)

        expect(email.to).to eq ['kristy.conner@example.com']
        expect(email.encoded).to include('Dear Kristy Conner,')
      end

      context 'created' do
        it 'shows the text when present' do
          email = ProjectMailer.results(
            results: { created: ['DEP1'] }, recipient_id: 5
          )
          expect(email.encoded).to include('1 project was created')

          email = ProjectMailer.results(
            results: { created: %w(DEP1 DEP2) }, recipient_id: 5
          )
          expect(email.encoded).to include('2 projects were created')
          expect(email.encoded).to include('DEP1')
          expect(email.encoded).to include('DEP2')
        end

        it 'hides the text when blank' do
          email = ProjectMailer.results(
            results: { created: [] }, recipient_id: 5
          )
          expect(email.encoded).not_to include('created')
        end
      end

      context 'updated' do
        it 'shows the text when present' do
          email = ProjectMailer.results(
            results: { updated: ['DEP1'] }, recipient_id: 5
          )
          expect(email.encoded).to include('1 project was updated')

          email = ProjectMailer.results(
            results: { updated: %w(DEP1 DEP2) }, recipient_id: 5
          )
          expect(email.encoded).to include('2 projects were updated')
          expect(email.encoded).to include('DEP1')
          expect(email.encoded).to include('DEP2')
        end

        it 'hides the text when blank' do
          email = ProjectMailer.results(
            results: { updated: [] }, recipient_id: 5
          )
          expect(email.encoded).not_to include('updated')
        end
      end

      context 'invalid' do
        it 'shows the text when present' do
          email = ProjectMailer.results(
            results: { invalid: ['DEP1'] }, recipient_id: 5
          )
          expect(email.encoded).to include('1 project was invalid')

          email = ProjectMailer.results(
            results: { invalid: %w(DEP1 DEP2) }, recipient_id: 5
          )
          expect(email.encoded).to include('2 projects were invalid')
          expect(email.encoded).to include('DEP1')
          expect(email.encoded).to include('DEP2')
        end

        it 'hides the text when blank' do
          email = ProjectMailer.results(
            results: { invalid: [] }, recipient_id: 5
          )
          expect(email.encoded).not_to include('invalid')
        end
      end
    end
  end
end
