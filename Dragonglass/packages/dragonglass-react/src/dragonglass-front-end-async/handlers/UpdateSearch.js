import { FrontEndAsyncRequestHandler } from "dragonglass-front-end-async";
import { StateStore } from "../../redux/StateStore";
import { searchResults } from "../../redux/mobile/mobile-actions";

export class UpdateSearch extends FrontEndAsyncRequestHandler {
  handle({ Content }) {
    const { results, hasMore } = Content;
    StateStore.dispatch(searchResults({ results, hasMore }));
  }
}
