require 'spec_helper'

describe NetSuite::Records::Check do
  let(:check) { NetSuite::Records::Check.new }
  let(:vendor) { NetSuite::Records::Vendor.new }
  let(:response) { NetSuite::Response.new(:success => true, :body => { :@internal_id => '1', :@external_id => 'some id' }) }

  it 'has all the right fields' do
    [
      :address, :balance, :created_date, :cleared, :cleared_date, :currency_name, :exchange_rate, :last_modified_date,
      :memo, :print_voucher, :status, :to_be_printed, :tran_date, :tran_id, :transaction_number
    ].each do |field|
      expect(check).to have_field(field)
    end
  end

  it 'has all the right record refs' do
    [
      :account, :ap_acct, :currency, :custom_form, :department, :entity, :klass, :location, :posting_period,
      :subsidiary, :void_journal
    ].each do |record_ref|
      expect(check).to have_record_ref(record_ref)
    end
  end

  describe '#custom_field_list' do
    it 'can be set from attributes' do
      attributes = {
        :custom_field => {
          :amount => 10,
          :internal_id => 'custfield_amount'
        }
      }
      check.custom_field_list = attributes
      expect(check.custom_field_list).to be_kind_of(NetSuite::Records::CustomFieldList)
      expect(check.custom_field_list.custom_fields.length).to eql(1)
    end

    it 'can be set from a CustomFieldList object' do
      custom_field_list = NetSuite::Records::CustomFieldList.new
      check.custom_field_list = custom_field_list
      expect(check.custom_field_list).to eql(custom_field_list)
    end
  end

  describe '#expense_list' do
    it 'can be set from attributes' do
      attributes = {
        expense: [
          {
            amount: 5000,
            account: NetSuite::Records::RecordRef.new(internal_id: "internal_id"),
            klass: NetSuite::Records::RecordRef.new(internal_id: "internal_id")
          }
        ]
      }
      check.expense_list = attributes
      expect(check.expense_list).to be_kind_of(NetSuite::Records::CheckExpenseList)
      expect(check.expense_list.expense.length).to eql(1)
    end

    it 'can be set from a CheckExpenseList object' do
      expense_list = NetSuite::Records::CheckExpenseList.new
      check.expense_list = expense_list
      expect(check.expense_list).to eql(expense_list)
    end
  end

  describe '.get' do
    context 'when the response is successful' do
      it 'returns an Check instance populated with the data from the response object' do
        expect(NetSuite::Actions::Get).to receive(:call).with([NetSuite::Records::Check, external_id: 'some id'], {}).and_return(response)
        payment = NetSuite::Records::Check.get(external_id: 'some id')
        expect(payment).to be_kind_of(NetSuite::Records::Check)
        expect(payment.internal_id).to eql('1')
      end
    end

    context 'when the response is unsuccessful' do
      let(:response) { NetSuite::Response.new(:success => false, :body => {}) }

      it 'raises a RecordNotFound exception' do
        expect(NetSuite::Actions::Get).to receive(:call).with([NetSuite::Records::Check, external_id: 'some id'], {}).and_return(response)
        expect {
          NetSuite::Records::Check.get(external_id: 'some id')
        }.to raise_error(NetSuite::RecordNotFound,
                         /NetSuite::Records::Check with OPTIONS=(.*) could not be found/)
      end
    end
  end

  describe '.initialize' do
    context 'when the request is successful' do
      it 'returns an initialized vendor payment from the vendor entity' do
        expect(NetSuite::Actions::Initialize).to receive(:call).with([NetSuite::Records::Check, vendor], {}).and_return(response)
        payment = NetSuite::Records::Check.initialize(vendor)
        expect(payment).to be_kind_of(NetSuite::Records::Check)
      end
    end

    context 'when the response is unsuccessful' do
      let(:response) { NetSuite::Response.new(:success => false, :body => {}) }

      it 'raises a InitializationError exception' do
        expect(NetSuite::Actions::Initialize).to receive(:call).with([NetSuite::Records::Check, vendor], {}).and_return(response)
        expect {
          NetSuite::Records::Check.initialize(vendor)
        }.to raise_error(NetSuite::InitializationError,
                         /NetSuite::Records::Check.initialize with .+ failed./)
      end
    end
  end

  describe '#add' do
    context 'when the response is successful' do
      it 'returns true' do
        expect(NetSuite::Actions::Add).to receive(:call).with([check], {}).and_return(response)
        expect(check.add).to be_truthy
        expect(check.internal_id).to eq('1')
      end
    end

    context 'when the response is unsuccessful' do
      let(:response) { NetSuite::Response.new(:success => false, :body => {}) }
      it 'returns false' do
        expect(NetSuite::Actions::Add).to receive(:call).with([check], {}).and_return(response)
        expect(check.add).to be_falsey
      end
    end
  end

  describe '#delete' do
    context 'when the response is successful' do
      it 'returns true' do
        expect(NetSuite::Actions::Delete).to receive(:call).with([check], {}).and_return(response)
        expect(check.delete).to be_truthy
      end
    end

    context 'when the response is unsuccessful' do
      let(:response) { NetSuite::Response.new(:success => false, :body => {}) }
      it 'returns false' do
        expect(NetSuite::Actions::Delete).to receive(:call).with([check], {}).and_return(response)
        expect(check.delete).to be_falsey
      end
    end
  end

  describe '#to_record' do
    before do
      check.memo   = 'some check'
      check.tran_id = 'TRAN-REF-1'
    end
    it 'can represent itself as a SOAP tranBank record' do
      record = {
          'tranBank:memo'   => 'some check',
          'tranBank:tranId' => 'TRAN-REF-1'
      }
      expect(check.to_record).to eql(record)
    end
  end

  describe '#record_type' do
    it 'returns a string representation of the SOAP type' do
      expect(check.record_type).to eql('tranBank:Check')
    end
  end
end
