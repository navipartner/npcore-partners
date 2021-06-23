import React from "react";
import { useSelector } from "react-redux";
import { tags as tagsSelector } from "../../../redux/view/view-selectors";
import Page from "../../Page";

export const Transcendence = () => {
  const tags = useSelector(tagsSelector);
  return tags.map((tag) => <Page tag={tag} key={tag}></Page>);
};
