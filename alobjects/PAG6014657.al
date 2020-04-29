page 6014657 "Proxy Dialog"
{
    // NPR4.15/VB/20150904 CASE 219606 Proxy utility for handling hardware communication
    // NPR4.15/VB/20150909 CASE 222602 Version increase for NaviPartner.POS.Web assembly reference(s)
    // NPR4.17/VB/20151013 CASE 220508 Added ClosePage function
    // NPR4.17/VB/20150104 CASE 225607 Changed references for compiling under NAV 2016
    // NPR5.20/VB/20151130 CASE 226832 Page modified to support new functionality
    // NPR5.00/VB/20160106 CASE 231100 Update .NET version from 1.9.1.305 to 1.9.1.369
    // NPR5.00/NPKNAV/20160113  CASE 226832 NP Retail 2016
    // NPR5.00.02/VB/20160128 CASE 233260 Allowing Proxy Dialog to run without having Stargate on client-side
    // NPR5.00.03/VB/20160106 CASE 231100 Update .NET version from 1.9.1.369 to 5.0.398.0
    // NPR5.20/TSA/20160223  CASE 235337 Changed signature on the ProtocolEvent to include CodeunitID
    // NPR5.29/VB/20161104 CASE 256944 Changed the control add-in to use a specific, lightweight proxy add-in instead of full-fledged IFramework
    // NPR5.41/VB/20180417 CASE 311404 Changed the error handling logic to show exception when web exception cannot be retrieved

    Caption = 'Proxy Dialog';
    PageType = List;

    layout
    {
        area(content)
        {
            usercontrol(Proxy;"NaviPartner.Retail.Controls.IProxyFramework")
            {

                trigger OnFrameworkReady()
                begin
                    ProxyAddInReady();
                end;

                trigger OnInvokeMethodResponse(envelope: Text)
                begin
                    ProxyInvokeMethodResponse(envelope);
                end;

                trigger OnServiceCallError(message: Text)
                begin
                    ProxyServiceCallError(message);
                end;

                trigger OnObjectModel(id: Text;eventName: Text;jsonData: Text)
                begin
                    ProtocolManager.Model.RaiseEvent(id,eventName,jsonData);
                end;

                trigger OnProtocol(eventName: Text;serializedData: Text;doCallback: Boolean)
                begin
                    ProxyProtocol(eventName,serializedData,doCallback);
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnClosePage()
    begin
        if ErrorAtClose <> '' then
          Message(ErrorAtClose);
    end;

    trigger OnOpenPage()
    begin
        ProtocolManager := ProtocolManager.ProtocolManager();
        ProxyManager.RegisterProtocolManager(ProtocolManager);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if not ProtocolClosing then
          QueryClosePage();

        exit(ProtocolClosing);
    end;

    var
        ProxyManager: Codeunit "POS Device Proxy Manager";
        [WithEvents]
        ProtocolManager: DotNet npNetProtocolManager;
        ErrorAtClose: Text;
        CodeunitId: Integer;
        Text001: Label 'A critical error has occurred communicating with local device hardware manager. The error details are:\\Error message: %1\\Please verify that the device proxy service is running and then restart the activity. This page will now close.';
        ProtocolClosing: Boolean;
        SkipStargate: Boolean;

    procedure RunProtocolModal(CodeunitIdIn: Integer)
    begin
        // Note for further merge (if ever needed):
        // - this (function rename) is intended to be a breaking change - all dependant code must be recompiled or refactored
        CodeunitId := CodeunitIdIn;
        CurrPage.RunModal();
    end;

    procedure ClosePage()
    begin
        //-NPR4.17
        CurrPage.Close ();
        //+NPR4.17
    end;

    local procedure QueryClosePage()
    var
        QueryClosePage: DotNet npNetQueryClosePage;
    begin
        ProxyManager.QueryClosePage(ProtocolManager);
    end;

    local procedure ProxyAddInReady()
    begin
        //-NPR5.00.02
        ProxyManager.SetSkipStargate(SkipStargate);
        //+NPR5.00.02
        ProxyManager.ProtocolBegin(ProtocolManager);
    end;

    local procedure ProxyInvokeMethodResponse(Envelope: Text)
    var
        ResponseEnvelope: DotNet npNetResponseEnvelope;
    begin
        ResponseEnvelope := ResponseEnvelope.FromString(Envelope,GetDotNetType(ResponseEnvelope));
        ProxyManager.ProcessResponse(ProtocolManager,ResponseEnvelope);
    end;

    local procedure ProxyServiceCallError(Msg: Text)
    begin
        ErrorAtClose := StrSubstNo(Text001,Msg);
        ProtocolClosing := true;
        CurrPage.Close();
    end;

    local procedure ProxyProtocol(EventName: Text;SerializedData: Text;DoCallback: Boolean)
    var
        ResponseData: Text;
    begin
        ResponseData := SerializedData;
        ProtocolEvent(CodeunitId,EventName,SerializedData,DoCallback,ResponseData);

        if DoCallback then
          CurrPage.Proxy.ProtocolResponse(EventName, ResponseData);
    end;

    local procedure ProtocolOnAbort(errorMessage: Text)
    begin
        ProtocolClosing := true;
        ErrorAtClose := errorMessage;
        CurrPage.Close();
    end;

    local procedure ProtocolOnSendMessage(Request: DotNet npNetRequestEnvelope)
    begin
        CurrPage.Proxy.InvokeDeviceMethod(Request.ToString());
    end;

    local procedure ProtocolOnSignal(Signal: DotNet npNetSignal)
    var
        TempBlob: Record TempBlob;
        Serializer: DotNet npNetXmlSerializer;
        OutStream: OutStream;
    begin
        Clear(TempBlob.Blob);
        TempBlob.Blob.CreateOutStream(OutStream);
        Serializer := Serializer.XmlSerializer(Signal.GetType());
        Serializer.Serialize(OutStream,Signal);

        if not CODEUNIT.Run(CodeunitId,TempBlob) then begin
          ErrorAtClose := GetLastErrorText;
          ProcessErrorObject();
          CurrPage.Close();
        end;
    end;

    local procedure ProtocolOnStateChange(PreviousState: Integer;NewState: Integer)
    var
        ProtocolState: DotNet npNetProtocolState;
    begin
        case true of
          ProtocolManager.State.Equals(ProtocolState.AbortedByUserRequest):
            begin
              ProtocolClosing := true;
              CurrPage.Close();
            end;
          ProtocolManager.State.Equals(ProtocolState.Closed):
            begin
              ProtocolClosing := true;
              ErrorAtClose := '';
              CurrPage.Close();
            end;
        end;

        ProxyManager.ProtocolStateChange(ProtocolManager,PreviousState,NewState);
    end;

    local procedure ProtocolModelUpdate(Model: DotNet npNetModel)
    var
        Html: Text;
        Css: Text;
        Script: Text;
        String: DotNet npNetString;
    begin
        Html := Model.ToString();
        Css := Model.GetStyles();
        Script := Model.GetScripts();
        if (String.IsNullOrWhiteSpace(Html) and String.IsNullOrWhiteSpace(Css) and String.IsNullOrWhiteSpace(Script)) then
          exit;
        CurrPage.Proxy.SetContent(Html,Css,Script);
    end;

    [BusinessEvent(false)]
    local procedure ProtocolEvent(ProtocolCodeunitID: Integer;EventName: Text;Data: Text;ResponseRequired: Boolean;var ReturnData: Text)
    begin
        //NPR5.20 Changed signature on the ProtocolEvent to include CodeunitID
    end;

    local procedure ProcessErrorObject()
    var
        Exc: DotNet npNetException;
        WebExc: DotNet npNetWebException;
        Reader: DotNet npNetStreamReader;
    begin
        Exc := GetLastErrorObject;
        if (not IsNull(Exc.InnerException)) then begin
          if (Exc.InnerException.GetType().Equals(GetDotNetType(WebExc))) then begin
            WebExc := Exc.InnerException;
            //-NPR5.41 [311404]
            //Reader := Reader.StreamReader(WebExc.Response.GetResponseStream());
            //ErrorAtClose := 'Web exception: ' + Reader.ReadToEnd();
            if not IsNull(WebExc.Response) then begin
              Reader := Reader.StreamReader(WebExc.Response.GetResponseStream());
              ErrorAtClose := 'Web exception: ' + Reader.ReadToEnd();
            end else
              ErrorAtClose := 'Exception: ' + Exc.Message;
            //+NPR5.41 [311404]
          end;
        end;
    end;

    procedure SetSkipStargate(SkipStargateIn: Boolean)
    begin
        //-NPR5.00.02
        SkipStargate := SkipStargateIn;
        //+NPR5.00.02
    end;

    trigger ProtocolManager::OnSendMessage(request: DotNet npNetRequestEnvelope)
    begin
        ProtocolOnSendMessage(request);
    end;

    trigger ProtocolManager::OnSignal(signal: DotNet npNetSignal)
    begin
        ProtocolOnSignal(signal);
    end;

    trigger ProtocolManager::OnAbort(errorMessage: Text)
    begin
        ProtocolOnAbort(errorMessage);
    end;

    trigger ProtocolManager::OnProtocolStateChange(previousState: Integer;newState: Integer)
    begin
        ProtocolOnStateChange(previousState,newState);
    end;

    trigger ProtocolManager::OnModelUpdate(model: DotNet npNetModel)
    begin
        ProtocolModelUpdate(model);
    end;
}

