codeunit 6014587 "Hardware Connector Mgt."
{
    // NPR5.51/MMV /20190731 CASE 360975 Created object
    // 
    // This object invokes the local machine from a browser via a modal page, intended to be run from outside the POS.
    // If you have the option to invoke the client socket from javascript via a more direct route, for example because you are writing a V2 action, please do so instead of using this object
    // as the final result will be cleaner and allow for more fine tuned control.
    // 
    // See repo for "server" .NET core and client javascript (function SocketWrapperScript() returns a minified version of the client js):
    // https://navipartner.visualstudio.com/Hardware%20Connector
    // 
    // TODO: Move the modal flow to a simple custom add-in in AL with the javascript nicely bundled inside, instead of using the bridge (which includes jquery) and minified js in a string.


    trigger OnRun()
    begin
    end;

    var
        PAGE_CLOSED: Label 'The hardware connector page does not work if you manually close it. Please try again and keep it open.';

    procedure SendRawPrintRequest(PrinterName: Text; PrintBytes: Text; TargetEncoding: Text)
    var
        Content: Text;
        Success: Boolean;
        Encoding: DotNet npNetEncoding;
        Convert: DotNet npNetConvert;
    begin
        PrintBytes := Convert.ToBase64String(Encoding.GetEncoding(TargetEncoding).GetBytes(PrintBytes));

        Content := '{ "PrinterName": "' + EscapeJSON(PrinterName) + '", "PrintJob": "' + PrintBytes + '" }';

        if not TrySendGenericRequest('RawPrint', Content) then
            Message(GetLastErrorText);
    end;

    local procedure "// Aux"()
    begin
    end;

    [TryFunction]
    local procedure TrySendGenericRequest(Handler: Text; Content: Text)
    var
        POSSession: Codeunit "POS Session";
        POSActionHardwareConnect: Codeunit "POS Action - Hardware Connect";
    begin
        if POSSession.GetSession(POSSession, false) then begin
            //Send via V2 action running JS inside POS, asynchronously.
            POSActionHardwareConnect.QueueRequest(Handler, Content);
        end else begin
            //Open modal page to run JS outside POS, synchronously.
            SendRequestOutsidePOS(Handler, Content);
        end;
    end;

    local procedure SendRequestOutsidePOS(Handler: Text; Content: Text)
    var
        HardwareConnector: Page "Hardware Connector";
        ResponseMethod: Text;
        Success: Boolean;
        ResponseOut: JsonObject;
        DummyJsonToken: JsonToken;
    begin
        //Open modal dialog page using JS bridge to invoke socket client.
        Commit;

        HardwareConnector.SetModule('', '',
          GetSocketClientScript() +
          'n$.ready((async () => {' +
            'try {' +
              'let response = await window._np_hardware_connector.sendRequestAndWaitForResponseAsync("' + Handler + '",' + Content + ');' +
              'new n$.Event.Method("result").raise(response);' +
            '} catch (exception) {' +
              'new n$.Event.Method("error").raise(exception);' +
            '}' +
          '}))');

        HardwareConnector.RunModal;
        if HardwareConnector.DidAutoClose() then begin
            HardwareConnector.GetResponse(ResponseMethod, ResponseOut);

            if ResponseMethod = 'error' then
                Error(ResponseOut.AsToken().AsValue().AsText());
        end else begin
            Error(PAGE_CLOSED);
        end;

        Success := (ResponseOut.Get('success', DummyJsonToken));
        if not Success then begin
            ResponseOut.Get('errorText', DummyJsonToken);
            Error(DummyJsonToken.AsValue().AsText());
        end;
    end;

    local procedure EscapeJSON(Value: Text): Text
    var
        JValue: DotNet npNetJValue;
    begin
        exit(JValue.JValue(Value).ToString());
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

