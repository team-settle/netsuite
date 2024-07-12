
# https://system.netsuite.com/help/helpcenter/en_us/apis/rest_api_browser/record/v1/2024.1/index.html#/definitions/check

module NetSuite
  module Records
    class Check
      include Support::Fields
      include Support::RecordRefs
      include Support::Records
      include Support::Actions
      include Namespaces::TranBank

      actions :get, :get_list, :initialize, :add, :delete, :update, :upsert, :search

      fields :address,
             :balance,
             :created_date,
             :cleared,
             :cleared_date,
             :currency_name,
             :exchange_rate,
             :last_modified_date,
             :memo,
             :print_voucher,
             :status,
             :to_be_printed,
             :tran_date,
             :tran_id,
             :transaction_number

      alias_method :created_at, :created_date

      field :custom_field_list, CustomFieldList
      field :expense_list,      CheckExpenseList


      record_refs :account,
                  :ap_acct,
                  :currency,
                  :custom_form,
                  :department,
                  :entity,
                  :klass,
                  :location,
                  :posting_period,
                  :subsidiary,
                  :void_journal

      attr_reader   :internal_id
      attr_accessor :external_id

      def initialize(attributes = {})
        @internal_id = attributes.delete(:internal_id) || attributes.delete(:@internal_id)
        @external_id = attributes.delete(:external_id) || attributes.delete(:@external_id)
        initialize_from_attributes_hash(attributes)
      end

      def to_record
        rec = super
        if rec["#{record_namespace}:customFieldList"]
          rec["#{record_namespace}:customFieldList!"] = rec.delete("#{record_namespace}:customFieldList")
        end
        rec
      end

      def self.search_class_name
        "Transaction"
      end

      def self.search_class_namespace
        'tranSales'
      end
    end
  end
end
