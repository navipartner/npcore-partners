let main = async ({ workflow, context }) => {
    let request = await workflow.respond("CreateHTTPRequestBody");
    const response = await fetch(request["url"], {
        method: "POST",
        headers: {
            "Content-Type": "application/xml",
        },
        body: request["requestBody"]
    });

    const result = await response.text();
    await workflow.respond("HandleResponse", { result: result });
};