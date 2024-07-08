let main = async ({captions}) => {
    let result = await popup.confirm ({title: captions.ConfirmTitle, caption: captions.ConfirmMessage});
    if (result) {
      let responseJson = await workflow.respond();
      let response = JSON.parse (responseJson);
      if (response.message) {await popup.message (response.message);}
    }
};