let main = async ({ workflow, context, captions, popup }) => {
    switch (context.id) {
      case "EanBox":
      case "PaymentBox":
        const { workflowName, workflowVersion, setupcode, eventcode, parameters } = await workflow.respond("prepareRequest");
        if (workflowVersion > 1) await workflow.run(workflowName, { parameters: parameters });
        if (workflowVersion == 1) await workflow.respond("doLegacyWorkflow", { actionCode: workflowName, setupcode: setupcode, eventcode: eventcode });
        return;   
      default: popup.error("Control" + " " + context.id + " " + captions.NotHandled);
        return;
    };
  };
  