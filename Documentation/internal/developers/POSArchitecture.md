# NP Core Point-Of-Sale Architecture

While NP Retail Point-Of-Sale (POS) is a part of our NP Core app for Business Central, the app is only one part of the solution, and there are other relevant components that work together to support our customers' processes. For POS to be fully functional in most retail scenarios, there are several crucial characteristics the application must have.

These characteristics are:
* **Touch-First**. The application must be totally touch-oriented. All actions must be easy to perform using touch interaction only, and no additional input device should be required. If there are other input devices, that's an additional benefit, but if there is no keyboard, or no mouse, the user must still be able to perform every task with equal proficiency.
* **Robust**. The application must not allow accidental undesired interaction to cause loss of transaction state or even delay in the processing of current retail transaction. Retail processes at POS are mission-critical, it's of crucial importance that no technical glitches cause retail customers to wait in line until such problems are fixed. For example, accidentally clicking back in the browser, or navigating away to another page, or sometimes even accidentally refreshing the page, could all cause delays in completing retail processes.
* **Local hardware access**. Most of retail POS devices must at minimum be able to process credit card transactions and print receipts. Based on needs, there may be other hardware devices, such as secondary displays, cameras, scanners, scales, or many more.

None of these characteristics are fully met by Business Central web client. While technically the web client is touch-optimized, it's far from being touch-first, and there are a number of UI limitations that prevent constructing easy-to-use POS interfaces. The web client alone is far from being robust enough to prevent accidental interactions in the middle of the POS transaction, and web browser has no direct means of accessing any local hardware (except printers, in a very limited way).

That's where various components of NP Retail come to stage. NP Retail uses a control add-in that is a part of NP Core app to render the user interface, as well as to hide any unnecessary UI elements from screen, embed the web browser in a custom-built application that prevents all unwanted or accidental interaction, and that can directly access local hardware.

## Components of NP Retail
| Component | Description |
|-|-|
| NP Core | This repository. Contains the entire back-end architecture to support POS processes. |
| [Major Tom](https://dev.azure.com/navipartner/Major%20Tom) | Windows application written in C# that embeds the web client, prevents accidental interaction with the browser, and serves as a middleware between the web browser and the local hardware. |
| [Transcendence](https://dev.azure.com/navipartner/Transcendence) | Stand-alone control add-in written to support previous version of NP Retail in C/SIDE and C/AL. Transcendence is no longer maintained, except for critical fixes. |
| [Dragonglass](https://dev.azure.com/navipartner/Dragonglass) | Control add-in that supersedes Transcendence as POS front-end in AL and the NP Core app. Dragonglass also embeds chunks of Transcendence as failover to support execution of Workflows v1 front-end actions. |
| Workflows | A feature of NP Retail front end responsible for coordinating business logic that executes in response to button clicks in POS. There are two versions of workflows. Both version of workflows allow AL developers to write JavaScript code that executes in the front end, that invokes any back-end code only when necessary. |
| Workflows v1 | First iteration of workflows, based on custom-built API, that allows structuring AL code in the back end to support asynchronous behavior of JavaScript that's executing in the front end. Workflows v1 are an essential part of the Transcendence front-end framework. Workflows v1 were designed primarily with AL developers in mind, requiring minimum understanding of JavaScript while still being able to write most of front-end logic. |
| Workflows v2 | Second iteration of workflows, based on JavaScript built-in [Promises API](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise). This iteration is far more robust, it coordinates the entire execution of business logic from the front end, and includes some features Workflows v1 was uncapable of, such as parallel execution, nesting, sequencing, and similar. Workflows v2 are an essential part of Dragonglass. |
| [Stargate](https://dev.azure.com/navipartner/Stargate) | Communication layer that spans all three levels of NP Retail: back end (AL), front end (JavaScript) and Major Tom (C#). Stargate is based on request messages constructed from .NET classes created through `DotNet` variables in AL, which are then serialized into JSON, passed on to JavaScript, which then passes them on to Major Tom, which then deserializes them and executes using the same version of the assembly that was used to create the request in the back end. Stargate had two iterations based on the Transcendence front-end framework, and is currently being heavily refactored to support robust and simple Workflows v2 coordination through Dragonglass. |

## Learn more

Links in the table above will take you to individual DevOps projects that contain code repositories for those components. If you want to learn more about these individual components and how they work together, please follow these links:
* General architecture (coming soon)
* Major Tom (coming soon)
* Transcendence front-end framework (coming soon)
* Dragonglass front-end framework (coming soon)
* Workflows (coming soon)
* Stargate (coming soon)

A good starting point for learning about these components, what they are and how they work together, follow the knowledge sharing session on POS Architecture Overview, recorded on December 10, 2012: [POS Architecture Overview ](https://web.microsoftstream.com/video/e6085cac-f46b-46b8-8c91-e71d7dadfbcf)