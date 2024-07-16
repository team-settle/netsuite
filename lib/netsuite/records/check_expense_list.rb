module NetSuite
  module Records
    class CheckExpenseList < Support::Sublist
      include Namespaces::TranBank

      sublist :expense, CheckExpense

      # legacy support
      alias :expenses :expense

    end
  end
end

