import React from "react";
import { useSelector } from "react-redux";
import {
  searchSelector,
  subpage,
} from "../../../redux/mobile/mobile-selectors";
import { GenericControl } from "./GenericControl";
import { SearchResults } from "./search/SearchResults";

const mapContent = (content) =>
  content.map((control, index) => (
    <GenericControl key={index} control={control} />
  ));

export const Body = ({ pages }) => {
  const searchActive = useSelector(searchSelector);
  const current = useSelector(subpage);
  const selectedPage = pages[current];

  if (!selectedPage) {
    //TODO: This happens before of the early "optimization" which renders all known views and then hides those that are not active
    /*
      However, in case of mobile it causes current subpage (which comes from mobile state) to be read from incorrect state. For example
      after login page has been rendered, and login page contains subpages "login", "info", "settings" (for example) and then after
      successful login the sale page is rendered, and it contains subpages "lock", "sale", "items". If the user then clicks "Items" and
      makes the "items" page the current subpage, this renderer will attempt to read "items" from the already rendered login page, and
      since it does not exist there, it will crash.
      This entire over-optimization should be taken out because it doesn't achieve much. Only the current view should ever be rendered
      rather than all known views. That is, only login view, or sale view, or payment view, but not all known views so far.
      When this is done, this entire block won't be necessary anymore.
    */
    return null;
  }
  const { content } = selectedPage;

  // TODO: Search feature
  /*
    Aca, this feature is described in https://dev.azure.com/navipartner/Dragonglass/_workitems/edit/3379
  */
  if (searchActive) {
    return <SearchResults />;
  }

  return (
    <div className="body">
      <div className={`main`}>{mapContent(content)}</div>
    </div>
  );
};
