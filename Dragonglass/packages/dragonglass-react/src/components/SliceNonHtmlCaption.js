export default function sliceNonHtmlCaption(caption) {
  const captionDoesNotContainHtml = !/<\/?[a-z][\s\S]*>/i.test(caption);

  let maxLength = 55;

  if (captionDoesNotContainHtml && caption.length >= maxLength) {
    caption = caption.slice(0, maxLength - 3).trim() + "\u2026";
  }

  return caption;
}
