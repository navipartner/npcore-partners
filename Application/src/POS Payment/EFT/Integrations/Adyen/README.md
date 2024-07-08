https://docs.adyen.com/point-of-sale/

We have 2 integrations to adyen, one for their cloud API and one for their local terminal API.
The JSON payloads are the same in both directions as it is the same terminal processing that occurs.

The result parsing is shared because the payloads are the same.
The reason we maintain two integrations is that cloud has flexibility for MPOS usecases where POS & terminal can be on different networks, 
meaning even if the MPOS falls back to 5G it can keep talking with the terminal.
However for full size fixed POS and selfservice POS, the local integration is preferred as direct network communication between POS <-> Terminal
on local network will always be faster and more robust than routing requests to between BC server, adyen datacenter, terminal and back again which is what the cloud integration does.
The local integration is also better because it gives the terminal a chance to do offline approval. 

# Cloud
The cloud integration uses page background tasks in AL to make http requests in the background, as this is the only way to
mimic typical async http requests from AL code.
This means the workflow is not doing anything apart from polling the BC backend until http response comes back with transaction response.

# Local 
The local integration uses the adyen .NET SDK embedded in our hardware connector.
This means the workflow is forwarding the json request to our hardware connector, awaiting a json response.
Because the local integration depends on our hardware connector that means that an MPOS setup cannot use it, without communicating via a hardware box, setup somewhere in the store with the HWC running on it.

# Common 
The common folder contains all shared objects between the two integrations. This is mainly request building and response parsing as the JSON payloads are identical between the two.

# Signature
Signature on adyen terminals happens via the customer drawing on the terminal touch screen, so we can render bitmaps in our workflows for approval.


# Customer recognition
Adyen supports detecting cards before starting the purchase.
This is done by sending "AcquireCard" request to terminal before the purchase starts, with an estimated amount.
The response on this will provide a chance to detect a card token -> BC customer and thus lowering the amount if price/discount groups apply, before
sending the actual Purchase request to adyen with final amount.
The customer does not feel this 2 step process, as their first card tap on AcquireCard is reused when purchase happens.
This is documented more indepth on adyens website

