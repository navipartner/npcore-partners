# Customer Display
The HTML Display is new version of the Customer display, where he old had origins with dotnet variables in bc together with Stargate functionality.
Now that we have moved away from that and we are utilising the Hardware Connector it was time for an upgrade so we could improve the quality of this service.
Before the Customer display had too many configs in BC and used 2 WinForm windows on top of eachother for displaying media and showing receipt content. Now we have limited the windows to a single one, which is utilising the Webview2 functionality from Windows. This way we have access to more regular updates and better browser compatability, using chromiom.

Documentation on how to setup the Customer display can be found on https://docs.navipartner.dk. This Readme file serves as a developer reference for how to maintain and extend this feature, to ensure backwards compatability, so Np Retail and Hardware Connector can always stay in sync.

## HTML Files and Websites
Since we are using a WebView2 we are displaying HTML files, this is done by creating HTML files in the Customer Display Project and uploading them to our base data blob storage on Azure, where they available for BC to fetch and send down to HWC on Pos Initialisation. We can also display Customer content by displaying their website in the WebView either as the top frame or a nested iframe.

## Concepts
### HTML Profile
The Profile in BC is a setup for specifying the automatic details of the Customer Display, this includes specifying the HTML file that contains logic to display Media, Customer Receipt Content, QR Payment Code and Signature input.
It also contains a link to Display Content which is where we specify the Media that should be shown on the Display during a sale and between sales.

### Media
Media

## Version hell...
There is 3 versions to keep track of. NpCore, Hardware Connector and the Html to be displayed.
Customer can be on different versions of NpCore, which mean that the Hardware connector should work with all version active.
Customer can be on different versions of Hardware Connector, but this gap is closed rather soon.
Customers can run different Html files and version. This should be tied to Np Core in the future.

The 3 different solutions all have different Deployment times, NpCore is the slowest, then Hwc, and Html can be instant.
So it makes sense that NpCore should dictate the version running.

NpCore should ask Hardware Connector for the latest version and assume 0 on failure.
Hardware connector should look for version in request, and assume 0 on failure.

NpCore should determine which Html version is used, to align the JsParameter correctly.
And wrap this into the request aligning with the Hardware Connector Version Request.
NpCore should find out based on Url which version is available and use the latest.


### Version 0 feature
The Feature set:
- Open Display (Download files if exist)
- Close Display
- SendJS
- - QRPaymentScan (Provider, Amount, Content)
- - UpdateReceipt
- - GetInput
- - InitMedia
