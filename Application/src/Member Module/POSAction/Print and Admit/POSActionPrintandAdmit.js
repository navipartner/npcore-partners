const main = async ({ workflow, parameters, popup, context, captions }) => {
    context.reference_input = await popup.input({
        title: captions.ReferenceTitle,
        caption: captions.ReferenceCaption,
      });
      if (context.reference_input == null) {
        return(" ");
    }
    let result = await workflow.respond("fill_data");
    await workflow.respond("handle_data", { buffer_data: result });
  };
  