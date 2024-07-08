let main = async ({ parameters, context, captions }) => {
    if (parameters.AudioFileUrl) {
        var audio = new Audio(parameters.AudioFileUrl);
        audio.play();
    }
    if (parameters.ShowMessage) {
        if (parameters.MessageText.length > 0) {
            await popup.message(parameters.MessageText, parameters.MessageHeader);
        };
    }
}