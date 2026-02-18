import { TransactionCard } from "../components/TransactionCard";
import { mockTransactions } from "../data/mock-data";
import { Card } from "../components/ui/card";

export default function TransactionsPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="mb-2">All Transactions</h1>
        <p className="text-muted-foreground">
          View all transfer portal transactions
        </p>
      </div>

      <div className="space-y-4">
        {mockTransactions.map((transaction) => (
          <TransactionCard key={transaction.id} transaction={transaction} />
        ))}
      </div>
    </div>
  );
}
