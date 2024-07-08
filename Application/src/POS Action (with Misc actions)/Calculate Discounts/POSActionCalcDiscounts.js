let main = async ({ popup, context, parameters, workflow }) => {
   debugger
   const { popupSetup } = await workflow.respond("calculateDiscounts");

   if (parameters.handleBenefitItems) {
      context.popupSetup = await getBenefitItemsResponse(popup, popupSetup);
      await workflow.respond('processBenefitItems');
   }
};


async function getBenefitItemsResponse(popup, popupSetup) {

   if (!popupSetup.settings) return;

   var benefitItemsResponse = await popup.configuration(popupSetup);

   if (benefitItemsResponse === null) return;


   for (var i = 0; i < popupSetup.settings.length; i++) {
      if (popupSetup.settings[i].settings) {
         for (var j = 0; j < popupSetup.settings[i].settings.length; j++) {
            var selectedQuantity = benefitItemsResponse[popupSetup.settings[i].settings[j].id];
            if (selectedQuantity != null) {
               popupSetup.settings[i].settings[j].value = selectedQuantity
            }
         }
      }
   }

   return popupSetup
}