let main = async ({ workflow, popup, captions }) => {

    let Paragon = await popup.input({ title: captions.title, caption: captions.paragonprompt});

    if (Paragon.length > 40) {
        await popup.error(captions.lengtherror);
        return(" ");
    }

    if (Paragon === null || Paragon === "") return;
    return await workflow.respond("InsertParagonNumber", { ParagonNo: Paragon });
}