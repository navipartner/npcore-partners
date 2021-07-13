import { FrontEndAsyncRequestHandler } from "dragonglass-front-end-async";
import { balancingActions } from "../../redux/balancing/balancing-actions";

export class BalanceSetContext extends FrontEndAsyncRequestHandler {
  handle(request) {
    balancingActions.updateBackEndContext(request.Content.balancingContext);
  }
}
