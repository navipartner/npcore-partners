# EFT Integration types

Each EFT integration subscribes to the framework and implements the necessary operations along with any integration-specific auxiliary operations that are not supported by default in the framework.

We group all EFT integrations into two categories:

- Integrations that require a client-side component, since communication with locally-connected hardware is necessary.      
  An example is a traditional EFT Pin pad connected to the local machine on COM, USB or ethernet.

- Integrations that don't require any client-side components, since communication with the external system can be done fully from the NAV server using the C/AL and DotNet interop.         

  An example is a webservice-API-based integration that allows users to pay through a smartphone app via an intermediate server that links the POS, and the end customer's device.      
  It can also be an integration that communicates with a local POS hardware device via an external server instead of a direct local route through the POS machine.

> [!Note]  
> The second type of integration is usually simpler to implement and maintain, as there are fewer parts involved from NPRetail's side.

## Client-side integration (Stargate) 

For client-side integrations we offer our hardware proxy (Stargate) to communicate back and forth between the NST and the local machine. Stargate works by building .NET DLLs that extend our request/response .NET interface and uploading these DLL packages into the customers NAV database where needed.
Initial deployment of these assemblies to the local POS machines and any future assembly updates are handled by the Stargate framework.

For Stargate integrations, the best approach to integration-specific GUI is usually to keep it local via .NET dialogs to prevent excessive ping-pongs between the client machine and the NAV server for each dialog update.   

We have a *MOCK_CLIENT_SIDE* integration in NP Retail that can be used as an example of how to develop a Stargate EFT integration.

On the local machine, it uses a generic *EFTDialog.dll* to show a simple EFT dialog. This assembly can be reused by other integrations if needed – the source code will be supplied upon request.

## Server-side integration

For server-side integrations you can use mostly standard C/AL development concepts to implement your webservice requests.
It uses Transcendence to load HTML, CSS and JS at run-time, and displays a dialog that continually updates every second by pinging back to the NST and invoking an external server to check the transaction status.

Your server-side integration will most likely be implemented via one of the following mechanisms:

- Long-polling HTTP requests (e.g MOBILEPAY)
- High frequency HTTP result check requests (these integrations should be straightforward, using the standard C/AL and .NET interop)
- Callback responses (these integrations pose a problem for NAV as they don't support the concept of an unprotected open API; if this is an only option available to your server-side integration, you will most likely need to use an external system to expose a public API for the callback, i.e. an Azure Function, or similar)

### Related links

- [EFT setup](EFT_setup.md)
