import { FrontEndAsyncRequestHandler } from "dragonglass-front-end-async";
import { StateStore } from "../../redux/StateStore";
import { preSearchResults } from "../../redux/mobile/mobile-actions";

export class UpdatePreSearch extends FrontEndAsyncRequestHandler {
  handle({ Content }) {
    const { results } = Content;
    StateStore.dispatch(preSearchResults(results));
  }
}
