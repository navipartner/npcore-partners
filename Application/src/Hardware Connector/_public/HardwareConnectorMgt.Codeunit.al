codeunit 6014587 "NPR Hardware Connector Mgt."
{
    // This object invokes the local machine from a browser via a modal page, intended to be run from outside the POS.
    // If you have the option to invoke the client socket from javascript via a more direct route, for example because you are writing a V2 action, please do so instead of using this object
    // as the final result will be cleaner and allow for more fine tuned control.
    // 
    // See repo for "server" .NET core and client javascript (function SocketWrapperScript() returns a minified version of the client js):
    // https://navipartner.visualstudio.com/Hardware%20Connector
    // 
    // TODO: Move the modal flow to a simple custom add-in in AL with the javascript nicely bundled inside, instead of using the bridge (which includes jquery) and minified js in a string.
    var
        SocketErr: Label 'Connection failure with hardware connector on the local machine.\Please verify that it is running and try again.';
        PrintLbl: Label 'Printing...';
        ClosedPageErr: Label 'The hardware connector page does not work if you manually close it. Please try again and keep it open.';
        OperationLbl: Label 'operation', Locked = true;
        PathLbl: Label 'path', Locked = true;
        FileLbl: Label 'File', Locked = true;
        SourceLbl: Label 'source', Locked = true;
        DestinationLbl: Label 'destination', Locked = true;
        ContentsLbl: Label 'contents', Locked = true;

    procedure SendRawPrintRequest(PrinterName: Text; PrintBytes: Text; TargetCodepage: Integer)
    var
        Base64: Codeunit "Base64 Convert";
        Request: JsonObject;
        Response: JsonObject;
    begin
        PrintBytes := Base64.ToBase64(PrintBytes, TextEncoding::Windows, TargetCodepage);

        Request.Add('PrinterName', PrinterName);
        Request.Add('PrintJob', PrintBytes);

        //Open modal dialog page using JS bridge to invoke socket client.
        Commit();

        if not TrySendGenericRequest('RawPrint', Request, PrintLbl, Response) then
            Message(GetLastErrorText);
    end;

    procedure SendRawBytesPrintRequest(PrinterName: Text; var TempBlob: Codeunit "Temp Blob")
    var
        Base64: Codeunit "Base64 Convert";
        InStream: InStream;
        Request: JsonObject;
        PrintBytes: Text;
        Response: JsonObject;
    begin
        TempBlob.CreateInStream(InStream);
        PrintBytes := Base64.ToBase64(InStream);

        Request.Add('PrinterName', PrinterName);
        Request.Add('PrintJob', PrintBytes);

        if not TrySendGenericRequest('RawPrint', Request, PrintLbl, Response) then
            Message(GetLastErrorText);
    end;

    procedure ExistsFileRequest(Path: Text): JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Checking if file exists...';

    begin
        Request.Add(OperationLbl, 'exists');
        Request.Add(PathLbl, Path);

        exit(SendGenericRequest(FileLbl, Request, Caption));
    end;

    procedure CopyFileRequest(SourcePath: Text; DestinationPath: Text): JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Copying file...';

    begin
        Request.Add(OperationLbl, 'copy');
        Request.Add(SourceLbl, SourcePath);
        Request.Add(DestinationLbl, DestinationPath);

        exit(SendGenericRequest(FileLbl, Request, Caption));
    end;

    procedure MoveFileRequest(SourcePath: Text; DestinationPath: Text): JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Moving file...';

    begin
        Request.Add(OperationLbl, 'move');
        Request.Add(SourceLbl, SourcePath);
        Request.Add(DestinationLbl, DestinationPath);

        exit(SendGenericRequest(FileLbl, Request, Caption));
    end;

    procedure DeleteFileRequest(Path: Text): JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Deleting file...';

    begin
        Request.Add(OperationLbl, 'delete');
        Request.Add(PathLbl, Path);

        exit(SendGenericRequest(FileLbl, Request, Caption));
    end;

    procedure WriteTextRequest(Path: Text; Content: Text): JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Writing text into file...';

    begin
        Request.Add(OperationLbl, 'writeText');
        Request.Add(PathLbl, Path);
        Request.Add(ContentsLbl, Content);

        exit(SendGenericRequest(FileLbl, Request, Caption));
    end;

    procedure WriteLinesRequest(Path: Text; Content: JsonToken): JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Writing lines into file...';

    begin
        Request.Add(OperationLbl, 'writeLines');
        Request.Add(PathLbl, Path);
        Request.Add(ContentsLbl, Content.AsArray());

        exit(SendGenericRequest(FileLbl, Request, Caption));
    end;

    procedure WriteBinaryRequest(Path: Text; var TempBlob: Codeunit "Temp Blob"): JsonObject
    var
        Base64: Codeunit "Base64 Convert";
        InStream: InStream;
        Bytes: Text;
        Request: JsonObject;
        Caption: Label 'Writing binary into file...';
    begin
        TempBlob.CreateInStream(InStream);
        Bytes := Base64.ToBase64(InStream);

        Request.Add(OperationLbl, 'writeBinary');
        Request.Add(PathLbl, Path);
        Request.Add(ContentsLbl, Bytes);

        exit(SendGenericRequest(FileLbl, Request, Caption));
    end;

    procedure AppendTextRequest(Path: Text; Content: Text): JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Appending text into file...';

    begin
        Request.Add(OperationLbl, 'appendText');
        Request.Add(PathLbl, Path);
        Request.Add(ContentsLbl, Content);

        exit(SendGenericRequest(FileLbl, Request, Caption));
    end;

    procedure AppendLinesRequest(Path: Text; Content: JsonToken): JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Appending lines into file...';

    begin
        Request.Add(OperationLbl, 'appendLines');
        Request.Add(PathLbl, Path);
        Request.Add(ContentsLbl, Content.AsArray());

        exit(SendGenericRequest(FileLbl, Request, Caption));
    end;

    procedure ReadTextRequest(Path: Text): JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Reading text from file...';

    begin
        Request.Add(OperationLbl, 'readText');
        Request.Add(PathLbl, Path);

        exit(SendGenericRequest(FileLbl, Request, Caption));
    end;

    procedure ReadLinesRequest(Path: Text): JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Reading lines from file...';

    begin
        Request.Add(OperationLbl, 'readLines');
        Request.Add(PathLbl, Path);

        exit(SendGenericRequest(FileLbl, Request, Caption));
    end;

    procedure ReadBinaryRequest(Path: Text): JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Reading binary from file...';

    begin
        Request.Add(OperationLbl, 'readBinary');
        Request.Add(PathLbl, Path);

        exit(SendGenericRequest(FileLbl, Request, Caption));
    end;

    procedure ExistsDirectoryRequest(Path: Text): JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Checking if directory exists...';

    begin
        Request.Add(OperationLbl, 'directory.exists');
        Request.Add(PathLbl, Path);

        exit(SendGenericRequest(FileLbl, Request, Caption));
    end;

    procedure CopyDirectoryRequest(SourcePath: Text; DestinationPath: Text): JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Copying directory...';

    begin
        Request.Add(OperationLbl, 'directory.copy');
        Request.Add(SourceLbl, SourcePath);
        Request.Add(DestinationLbl, DestinationPath);

        exit(SendGenericRequest(FileLbl, Request, Caption));
    end;

    procedure MoveDirectoryRequest(SourcePath: Text; DestinationPath: Text): JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Moving directory...';

    begin
        Request.Add(OperationLbl, 'directory.move');
        Request.Add(SourceLbl, SourcePath);
        Request.Add(DestinationLbl, DestinationPath);

        exit(SendGenericRequest(FileLbl, Request, Caption));
    end;

    procedure DeleteDirectoryRequest(Path: Text; Force: Boolean): JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Deleting directory...';

    begin
        Request.Add(OperationLbl, 'directory.delete');
        Request.Add(PathLbl, Path);
        Request.Add('force', Force);


        exit(SendGenericRequest(FileLbl, Request, Caption));
    end;

    procedure GetDirectoryContentRequest(Path: Text): JsonObject
    var
        Request: JsonObject;
        Caption: Label 'Getting directory content...';

    begin
        Request.Add(OperationLbl, 'directory.getContents');
        Request.Add(PathLbl, Path);

        exit(SendGenericRequest(FileLbl, Request, Caption));
    end;

    procedure SendGenericRequest(RequestType: Text; Request: JsonObject; WindowCaption: Text) Response: JsonObject
    begin
        Commit();

        if not TrySendGenericRequest(RequestType, Request, WindowCaption, Response) then
            Message(GetLastErrorText);
    end;
    // Auxilliary functions

    [TryFunction]
    local procedure TrySendGenericRequest(Handler: Text; Request: JsonObject; Caption: Text; var ResponseOut: JsonObject)
    begin
        ResponseOut := SendRequestOutsidePOS(Handler, Request, Caption);
    end;

    local procedure SendRequestOutsidePOS(Handler: Text; Request: JsonObject; Caption: Text): JsonObject
    var
        Content: Text;
        HardwareConnector: Page "NPR Hardware Connector";
        Response: JsonObject;
        JToken: JsonToken;
        ResponseMethod: Text;
        SuccessResponse: Boolean;
    begin
        Request.WriteTo(Content);

        HardwareConnector.SetModule('', '',
          GetSocketClientScript() +
          'n$.ready((async () => {' +
            'try {' +
              'let response = await window._np_hardware_connector.sendRequestAndWaitForResponseAsync("' + Handler + '",' + Content + ');' +
              'new n$.Event.Method("result").raise(response);' +
            '} catch (exception) {' +
              'new n$.Event.Method("error").raise(exception);' +
            '}' +
          '}))', Caption);

        HardwareConnector.RunModal();
        if HardwareConnector.DidAutoClose() then begin
            HardwareConnector.GetResponse(ResponseMethod, Response);

            if ResponseMethod = 'error' then
                Error(SocketErr);
        end else begin
            Error(ClosedPageErr);
        end;

        if Response.Get('Success', JToken) then
            SuccessResponse := JToken.AsValue().AsBoolean();

        // TODO verify reason key
        if not SuccessResponse then begin
            Response.Get('errorText', JToken);
            Error(JToken.AsValue().AsText());
        end;

        exit(Response);
    end;

    procedure GetSocketClientScript(): Text
    begin
        exit(
        'class HandlerMessage{constructor(id,context,handler,handl' +
        'erContent){this.Type="Handler",this.Id=id,this.Context=context,this.Ha' +
        'ndler=handler,this.HandlerContent=handlerContent}}class AckMessage{con' +
        'structor(id,acknowledgeId){this.Type="Acknowledgement",this.Id=id,this' +
        '.AcknowledgeId=acknowledgeId}}class ResponseCallback{constructor(conte' +
        'xt,callback){this.lastId=0,this.context=context,this.callback=callback' +
        '}}class HardwareConnector{constructor(){this.setupObject()}async sendR' +
        'equestAndWaitForResponseAsync(handler,content){let message=new Handler' +
        'Message(++this.lastMessageIdSend,this.generateContextID(),handler,cont' +
        'ent);this.socket.readyState!==this.socket.OPEN&&await this.socketConne' +
        'ctionDoneAsync();let responseResult=this.waitForFirstResponse(message)' +
        ',sendResult=this.sendRequestAndWaitForAckAsync(message);return(await P' +
        'romise.all([sendResult,responseResult]))[1].HandlerContent}async sendR' +
        'equestAsync(handler,content,context){let message=new HandlerMessage(++' +
        'this.lastMessageIdSend,context,handler,content);return this.socket.rea' +
        'dyState!==this.socket.OPEN&&await this.socketConnectionDoneAsync(),awa' +
        'it this.sendRequestAndWaitForAckAsync(message)}registerResponseHandler' +
        '(callback){let context=this.generateContextID();return this.responseCa' +
        'llbacks.push(new ResponseCallback(context,callback)),context}unregiste' +
        'rResponseHandler(context){this.responseCallbacks=this.responseCallback' +
        's.filter(value=>value.context!==context)}getSocketState(){return this.' +
        'socket.readyState}async socketConnectionDoneAsync(){return new Promise' +
        '((resolve,reject)=>{this.socket.addEventListener("close",()=>reject())' +
        ',this.socket.addEventListener("open",()=>resolve()),this.socket.readyS' +
        'tate===this.socket.OPEN&&resolve()})}async sendRequestAndWaitForAckAsy' +
        'nc(message){return new Promise((resolve,reject)=>{this.socket.addEvent' +
        'Listener("close",event=>{clearInterval(intervalId),reject(event)}),thi' +
        's.socket.addEventListener("message",event=>{let response=JSON.parse(ev' +
        'ent.data);"Acknowledgement"===response.Type&&response.AcknowledgeId===' +
        'message.Id&&(clearInterval(intervalId),resolve())});let rawMessage=JSO' +
        'N.stringify(message),intervalId=setInterval(()=>{this.socket.send(rawM' +
        'essage),console.log("[HardwareConnector] Data sent to localhost: "+raw' +
        'Message)},100)})}async waitForFirstResponse(message){return new Promis' +
        'e((resolve,reject)=>{this.socket.addEventListener("close",event=>rejec' +
        't(event)),this.socket.addEventListener("message",event=>{let response=' +
        'JSON.parse(event.data);"Handler"===response.Type&&response.Context===m' +
        'essage.Context&&resolve(response)})})}handleMessage(rawMessage){consol' +
        'e.log(`[HardwareConnector] Data received from localhost: ${rawMessage.' +
        'data}`);let message=JSON.parse(rawMessage.data);if("Handler"===message' +
        '.Type){let ack=JSON.stringify(new AckMessage(++this.lastMessageIdSend,' +
        'message.Id));this.socket.send(ack),console.log("[HardwareConnector] Da' +
        'ta sent to localhost: "+ack),this.responseCallbacks.filter(value=>valu' +
        'e.context===message.Context&&value.lastId<message.Id).forEach(value=>{' +
        'value.lastId=message.Id,console.log("[HardwareConnector] Invoking regi' +
        'stered response handler for context: "+message.Context),value.callback' +
        '(message.HandlerContent)})}}handleClose(event){event.wasClean?console.' +
        'log(`[HardwareConnector] Connection with localhost closed, code=${even' +
        't.code} reason=${event.reason}`):console.log("[HardwareConnector] Conn' +
        'ection with localhost died unexpectedly")}generateContextID(){return c' +
        'rypto.getRandomValues(new Uint32Array(4)).join("")}setupObject(){this.' +
        'lastMessageIdSend=0,this.responseCallbacks=[],this.socket=new WebSocke' +
        't("ws://127.0.0.1:60992"),this.socket.addEventListener("open",()=>cons' +
        'ole.log("[HardwareConnector] Connection established with localhost")),' +
        'this.socket.addEventListener("error",error=>console.log(`[HardwareConn' +
        'ector] Error: ${error}`)),this.socket.addEventListener("message",event' +
        '=>this.handleMessage(event)),this.socket.addEventListener("close",even' +
        't=>this.handleClose(event))}}window._np_hardware_connector?window._np_' +
        'hardware_connector.getSocketState()>1&&(window._np_hardware_connector=' +
        'new HardwareConnector):window._np_hardware_connector=new HardwareConne' +
        'ctor;');
    end;
}
