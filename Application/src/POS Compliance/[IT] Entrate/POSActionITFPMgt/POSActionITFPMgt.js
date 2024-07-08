const main = async ({workflow, context, captions}) => {
     const requests = await workflow.respond("CreateHTTPRequestBody");
     const resultValues = await fetchFromPrinter(requests, captions);

     await workflow.respond("HandleResponse", {resultValues: resultValues});
};

async function fetchFromPrinter(requests, captions) {
  const results = [];

  await Promise.all(requests.map(async (request, index) => {
     try {
        const {url,requestBody} = request;

        const response = await fetch(url, {
           method: "POST",
           headers: {
              "Content-Type": "application/xml",
           },
           body: requestBody,
        });

        if (response.ok) {
           const result = await response.text();
           results[index] = {index,result};
        };
     } catch (error) {
        results[index] = {index, error: captions.statuserror};
     }
  }));
  return results;
}