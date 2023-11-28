let main = async ({ workflow, context }) => {
    let request = await workflow.respond("PrepareRequest");
    const response = await fetch(request['url'], {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: request['requestBody']
    });

    const result = await response.json();
    await workflow.respond("HandleResponse", { result: result });
};