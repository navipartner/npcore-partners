let main = async ({ workflow, context, popup, runtime, parameters, captions}) => {
  debugger;
  let workflowstep = "AddSalesLine"; 
  if (context.hasOwnProperty ("_additionalContext")) { 
    if (context._additionalContext.hasOwnProperty("plusMinus")) 
      workflowstep = (context._additionalContext.quantity > 0) ? "IncreaseQuantity" : "DecreaseQuantity"; 

    const salesline = runtime.getData("BUILTIN_SALELINE"); 
    let row = salesline.find(r => r[6] === parameters.itemNo) || null; 
    console.log("Searching for item: " + parameters.itemNo + " found row: " + JSON.stringify(row)); 
    if ((row != null) && (parameters.qtyDialogThreshold > 0) && 
        ((row[12] >= parameters.qtyDialogThreshold) && (context._additionalContext.quantity > 0) || 
         (row[12] > parameters.qtyDialogThreshold) && (context._additionalContext.quantity < 0)) 
       ) { 
          let incrQty = (parameters.itemQuantity > 0) ? parameters.itemQuantity : 1; 
          let qtyMin = parameters.minimumAllowedQuantity || 1; 
          let qtyMax = (parameters.maximalAllowedQuantity > 0) ? parameters.maximalAllowedQuantity : (qtyMin < 100) ? 100 : qtyMin; 
          let quantity = (context._additionalContext.quantity > 0) ? row[12] + incrQty : row[12] - incrQty; 
          if (Math.abs(quantity) < qtyMin) quantity = 0; 
          context.specificQuantity = await popup.intpad({ title: captions.EnterQuantityCaption, caption: captions.EnterQuantityCaption, value: quantity }); 
          if (context.specificQuantity === null) { return; } 
          if ((Math.abs(context.specificQuantity) > qtyMax) || ((context.specificQuantity != 0) && (Math.abs(context.specificQuantity) < qtyMin))) { 
              await popup.message({ title: captions.EnterQuantityCaption, caption: captions.ValidRangeText.substitute(qtyMin, qtyMax) }); 
              return; 
          } 
          workflowstep = "SetSpecificQuantity";
    } 
  }

  AddItemAddOn = await (workflow.respond (workflowstep));

    if(AddItemAddOn){
      
      await workflow.run('SS-ITEM-ADDON');  

  }
};