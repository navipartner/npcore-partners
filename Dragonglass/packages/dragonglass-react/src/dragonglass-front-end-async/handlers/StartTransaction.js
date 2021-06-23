import { FrontEndAsyncRequestHandler } from "dragonglass-front-end-async";
import { StateStore } from "../../redux/StateStore";
import { updateTransactionState } from "../../redux/actions/transactionStateActions";
import { resetDataSets } from "../../redux/actions/dataActions";
import { GlobalEventDispatcher } from "dragonglass-core";
import { resetMenu } from "../../redux/menu/menu-actions";

let lastTransaction = {};

export class StartTransaction extends FrontEndAsyncRequestHandler {
  handle(request) {
    const transaction = {
      no: request.TransactionNo,
      register: request.Content.register,
      salesPerson: request.Content.salesPerson,
    };

    StateStore.dispatch(updateTransactionState(transaction));
    StateStore.dispatch(resetDataSets());

    if (
      lastTransaction.register != transaction.register ||
      lastTransaction.salesPerson != transaction.salesPerson
    )
      StateStore.dispatch(resetMenu());
    lastTransaction = transaction;

    GlobalEventDispatcher.startTransaction();
  }
}
