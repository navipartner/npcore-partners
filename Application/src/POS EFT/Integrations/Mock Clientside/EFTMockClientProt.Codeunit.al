codeunit 6184512 "NPR EFT Mock Client Prot."
{
    // NPR5.46/MMV /20181008 CASE 290734 Created object
    // NPR5.48/MMV /20181220 CASE 339930 Moved receipt write outside tryfunction for 2017+ support
    // NPR5.49/MMV /20190312 CASE 345188 Renamed object
    // NPR5.51/MMV /20190626 CASE 359385 Added gift card load support.


    trigger OnRun()
    begin
    end;

    var
        DialogCloseButton: Label 'Close';
        DialogForceCloseButton: Label 'Force Close';
        DialogTimeoutReached: Label 'Timeout Reached - Attempting transaction cancel';
        DialogCancelStarted: Label 'Transaction Cancel Started';
        DialogCancelError: Label 'Transaction Cancel Failed - Exiting';
        DialogCancelSuccess: Label 'Transaction Cancel Success';
        DialogTransactionError: Label 'Transaction Error';
        DialogTransactionSuccess: Label 'Transaction Success';
        DialogTransactionDone: Label 'Transaction Done';
        DialogTransactionStarted: Label 'Transaction Started';
        DialogTransactionDeclined: Label 'Transaction Declined';
        DialogTerminalIsClosed: Label 'Terminal is closed';

    local procedure IntegrationType(): Text
    begin
        exit('MOCK_CLIENT_SIDE');
    end;

    local procedure "// Stargate Requests"()
    begin
    end;

    procedure SendEftDeviceRequest(EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        case EftTransactionRequest."Processing Type" of
            EftTransactionRequest."Processing Type"::OPEN:
                OpenTerminal(EftTransactionRequest);
            EftTransactionRequest."Processing Type"::CLOSE:
                CloseTerminal(EftTransactionRequest);
            EftTransactionRequest."Processing Type"::LOOK_UP:
                LookupTransaction(EftTransactionRequest);
            EftTransactionRequest."Processing Type"::SETUP:
                VerifySetup(EftTransactionRequest);
            //-NPR5.51 [359385]
            EftTransactionRequest."Processing Type"::GIFTCARD_LOAD,
          //+NPR5.51 [359385]
          EftTransactionRequest."Processing Type"::REFUND,
          EftTransactionRequest."Processing Type"::PAYMENT:
                PaymentTransaction(EftTransactionRequest);
            EftTransactionRequest."Processing Type"::VOID:
                VoidTransaction(EftTransactionRequest);
            EftTransactionRequest."Processing Type"::AUXILIARY:
                case EftTransactionRequest."Auxiliary Operation ID" of
                    1:
                        BalanceEnquiry(EftTransactionRequest);
                    2:
                        ReprintLastReceipt(EftTransactionRequest);
                end;
        end;
    end;

    local procedure PaymentTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        Captions: DotNet NPRNetCaptions;
        TransactionRequest: DotNet NPRNetTransactionRequest1;
        State: DotNet NPRNetState5;
    begin
        State := State.State();
        State.RequestEntryNo := EftTransactionRequest."Entry No.";
        State.ReceiptNo := EftTransactionRequest."Sales Ticket No.";
        State.AmountIn := EftTransactionRequest."Amount Input";
        State.Captions := Captions.Captions();
        State.Captions.Amount := Format(EftTransactionRequest."Amount Input", 0, '<Precision,2:2><Standard Format,2>');
        case EftTransactionRequest."Processing Type" of
            EftTransactionRequest."Processing Type"::PAYMENT:
                begin
                    State.Captions.TransactionType := 'Payment';
                end;
            EftTransactionRequest."Processing Type"::REFUND:
                begin
                    State.Captions.TransactionType := 'Refund';
                end;
        end;
        SetCaptionState(State);
        State.Timeout := 30 * 1000;
        State.CancelTimeout := 5 * 1000;

        TransactionRequest := TransactionRequest.TransactionRequest();
        TransactionRequest.State := State;

        SendRequest(TransactionRequest);
    end;

    local procedure OpenTerminal(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        OpenRequest: DotNet NPRNetOpenRequest;
        State: DotNet NPRNetState5;
        EFTSetup: Record "NPR EFT Setup";
        ConnectionMethod: Integer;
        COMPort: Integer;
        IPAddr: Text;
        EFTMockClientIntegration: Codeunit "NPR EFT Mock Client Integ.";
    begin
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."POS Payment Type Code");

        State := State.State();
        State.RequestEntryNo := EftTransactionRequest."Entry No.";
        State.ReceiptNo := EftTransactionRequest."Sales Ticket No.";
        SetConnectionInitState(State, EFTSetup);

        OpenRequest := OpenRequest.OpenRequest();
        OpenRequest.State := State;

        SendRequest(OpenRequest);
    end;

    local procedure CloseTerminal(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        CloseRequest: DotNet NPRNetCloseRequest;
        State: DotNet NPRNetState5;
    begin
        State := State.State();
        State.RequestEntryNo := EftTransactionRequest."Entry No.";
        State.ReceiptNo := EftTransactionRequest."Sales Ticket No.";

        CloseRequest := CloseRequest.CloseRequest();
        CloseRequest.State := State;

        SendRequest(CloseRequest);
    end;

    local procedure VerifySetup(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        VerifySetupRequest: DotNet NPRNetVerifySetupRequest;
        State: DotNet NPRNetState5;
        EFTSetup: Record "NPR EFT Setup";
        EFTMockClientIntegration: Codeunit "NPR EFT Mock Client Integ.";
    begin
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."POS Payment Type Code");

        State := State.State();
        State.RequestEntryNo := EftTransactionRequest."Entry No.";
        State.ReceiptNo := EftTransactionRequest."Sales Ticket No.";
        SetConnectionInitState(State, EFTSetup);

        VerifySetupRequest := VerifySetupRequest.VerifySetupRequest();
        VerifySetupRequest.State := State;

        SendRequest(VerifySetupRequest);
    end;

    local procedure LookupTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        LookupTransactionRequest: DotNet NPRNetLookupTransactionRequest;
        State: DotNet NPRNetState5;
        OriginalTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        OriginalTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");

        State := State.State();
        State.RequestEntryNo := EftTransactionRequest."Entry No.";
        State.ReceiptNo := EftTransactionRequest."Sales Ticket No.";

        State.OriginalReceiptNo := OriginalTransactionRequest."Sales Ticket No.";
        State.OriginalRequestEntryNo := OriginalTransactionRequest."Entry No.";
        State.OriginalExternalReferenceNo := OriginalTransactionRequest."External Transaction ID";

        LookupTransactionRequest := LookupTransactionRequest.LookupTransactionRequest();
        LookupTransactionRequest.State := State;

        SendRequest(LookupTransactionRequest);
    end;

    local procedure VoidTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        OriginalTransactionRequest: Record "NPR EFT Transaction Request";
        VoidTransactionRequest: DotNet NPRNetVoidRequest;
        State: DotNet NPRNetState5;
    begin
        OriginalTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");

        State := State.State();
        State.RequestEntryNo := EftTransactionRequest."Entry No.";
        State.ReceiptNo := EftTransactionRequest."Sales Ticket No.";

        State.OriginalReceiptNo := OriginalTransactionRequest."Sales Ticket No.";
        State.OriginalRequestEntryNo := OriginalTransactionRequest."Entry No.";
        State.OriginalExternalReferenceNo := OriginalTransactionRequest."External Transaction ID";

        VoidTransactionRequest := VoidTransactionRequest.VoidRequest();
        VoidTransactionRequest.State := State;

        SendRequest(VoidTransactionRequest);
    end;

    local procedure BalanceEnquiry(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        BalanceEnquiryRequest: DotNet NPRNetBalanceEnquiryRequest;
        State: DotNet NPRNetState5;
    begin
        State := State.State();
        State.RequestEntryNo := EftTransactionRequest."Entry No.";
        State.ReceiptNo := EftTransactionRequest."Sales Ticket No.";

        BalanceEnquiryRequest := BalanceEnquiryRequest.BalanceEnquiryRequest();
        BalanceEnquiryRequest.State := State;

        SendRequest(BalanceEnquiryRequest);
    end;

    local procedure ReprintLastReceipt(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        ReprintReceiptRequest: DotNet NPRNetReprintReceiptRequest;
        State: DotNet NPRNetState5;
    begin
        //Note: Usually reprint does not have to be an explicit integration operation, since we store the receipts and can reprint from NAV storage.
        //This is an example of how to implement if terminal reprint last request was required as part of an integration certification, via an auxiliary function.

        State := State.State();
        State.RequestEntryNo := EftTransactionRequest."Entry No.";

        ReprintReceiptRequest := ReprintReceiptRequest.ReprintReceiptRequest();
        ReprintReceiptRequest.State := State;

        SendRequest(ReprintReceiptRequest);
    end;

    local procedure ActionCode(): Text
    begin
        exit('EFT_' + IntegrationType());
    end;

    local procedure SendRequest(Request: DotNet NPRNetGenericRequest)
    var
        FrontEnd: Codeunit "NPR POS Front End Management";
    begin
        FrontEnd.InvokeDevice(Request, ActionCode(), 'EftRequest');
    end;

    local procedure "// Stargate Responses"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150716, 'OnAppGatewayProtocol', '', false, false)]
    local procedure OnDeviceEvent(ActionName: Text; EventName: Text; Data: Text; ResponseRequired: Boolean; var ReturnData: Text; var Handled: Boolean)
    var
        PaymentRequest: Integer;
        EftTransactionRequest: Record "NPR EFT Transaction Request";
        State: DotNet NPRNetState5;
    begin

        if (ActionName <> ActionCode()) then
            exit;

        Handled := true;

        if not DeserializeResponse(Data, State) then
            Error('Critical EFT error: Response deserialization failed. %1', GetLastErrorText);

        EftTransactionRequest.Get(State.RequestEntryNo);
        if not HandleResponse(EftTransactionRequest, State, EventName) then
            EftTransactionRequest."NST Error" := CopyStr(GetLastErrorText, 1, MaxStrLen(EftTransactionRequest."NST Error"));
        //-NPR5.48 [339930]
        HandleReceipt(EftTransactionRequest, State);
        //+NPR5.48 [339930]
        EftTransactionRequest.Modify;

        OnAfterProtocolResponse(EftTransactionRequest);
    end;

    [TryFunction]
    local procedure DeserializeResponse(Data: Text; var State: DotNet NPRNetState5)
    var
        GenericResponse: DotNet NPRNetGenericResponse;
    begin
        GenericResponse := GenericResponse.Deserialize(Data);
        State := GenericResponse.State;
    end;

    [TryFunction]
    local procedure HandleResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request"; State: DotNet NPRNetState5; EventName: Text)
    begin
        EftTransactionRequest."Result Code" := State.ResultCode;
        EftTransactionRequest."Client Assembly Version" := State.ExecutingAssemblyVersion;

        case EventName of
            'PaymentTransactionEnd':
                PaymentTransactionEnd(EftTransactionRequest, State);
            'OpenTerminalEnd':
                OpenTerminalEnd(EftTransactionRequest, State);
            'CloseTerminalEnd':
                CloseTerminalEnd(EftTransactionRequest, State);
            'VerifySetupEnd':
                VerifySetupEnd(EftTransactionRequest, State);
            'LookupTransactionEnd':
                LookupTransactionEnd(EftTransactionRequest, State);
            'VoidTransactionEnd':
                VoidTransactionEnd(EftTransactionRequest, State);
            'BalanceEnquiryEnd':
                BalanceEnquiryEnd(EftTransactionRequest, State);
            'ReprintReceipt':
                ReprintReceiptEnd(EftTransactionRequest, State);
        end;
    end;

    local procedure GenericErrorCheck(var EftTransactionRequest: Record "NPR EFT Transaction Request"; State: DotNet NPRNetState5): Boolean
    begin
        case EftTransactionRequest."Result Code" of
            -100: //Closed terminal - request never started
                begin
                    EftTransactionRequest."Result Description" := 'Terminal is closed';
                    EftTransactionRequest."Result Display Text" := CopyStr(State.ResultString, 1, MaxStrLen(EftTransactionRequest."Result Display Text"));
                    EftTransactionRequest."External Result Known" := true;
                end;
            -101: //Connection failed - request never started
                begin
                    EftTransactionRequest."Result Description" := 'Connection failed';
                    EftTransactionRequest."Result Display Text" := CopyStr(State.ResultString, 1, MaxStrLen(EftTransactionRequest."Result Display Text"));
                    EftTransactionRequest."External Result Known" := true;
                end
            else
                exit(true); //No generic errors
        end;

        Message(EftTransactionRequest."Result Display Text"); //Show the error to user
    end;

    local procedure PaymentTransactionEnd(var EftTransactionRequest: Record "NPR EFT Transaction Request"; State: DotNet NPRNetState5)
    var
        OutStream: OutStream;
    begin
        //-NPR5.51 [359385]
        //IF State.AmountOut = 700 THEN
        if Abs(State.AmountOut) = 700 then
            //+NPR5.51 [359385]
            Error('Simulating Crash at NST side');

        EftTransactionRequest.Successful := State.Success;
        EftTransactionRequest."Result Description" := CopyStr(State.ResultString, 1, MaxStrLen(EftTransactionRequest."Result Description"));
        EftTransactionRequest."Result Display Text" := CopyStr(State.ResultString, 1, MaxStrLen(EftTransactionRequest."Result Display Text"));
        EftTransactionRequest."External Transaction ID" := State.ExternalReferenceNo;
        EftTransactionRequest."Reference Number Output" := State.ExternalReferenceNo;
        EftTransactionRequest."Amount Output" := State.AmountOut;
        EftTransactionRequest."Result Amount" := State.AmountOut;
        EftTransactionRequest."External Result Known" := State.ExternalResultReceived;
        EftTransactionRequest."Receipt 1".CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.Write(State.Receipt);
        //-NPR5.48 [339930]
        //HandleReceipt(EftTransactionRequest, State);
        //+NPR5.48 [339930]

        //Extra data that could also be handled at this point depending on implementation & integration type:

        // EftTransactionRequest."Card Number" := ;
        // EftTransactionRequest."Card Type" := ;
        // EftTransactionRequest."Surcharge Amount" := ; //Assuming externally calculated surcharge, instead of NAV calculated.
        // EftTransactionRequest."Authorisation Number" := ;
        // EftTransactionRequest."External Customer ID" := ; //Could be a customer token
        // EftTransactionRequest."Hardware ID" := ;
        // EftTransactionRequest."Log files ZIP" := ; //For easier troubleshooting
        // EftTransactionRequest."Receipt 2" := ; //BLOB
    end;

    local procedure OpenTerminalEnd(var EftTransactionRequest: Record "NPR EFT Transaction Request"; State: DotNet NPRNetState5)
    begin
        if not GenericErrorCheck(EftTransactionRequest, State) then
            exit;

        EftTransactionRequest.Successful := State.Success;
        EftTransactionRequest."Result Description" := CopyStr(State.ResultString, 1, MaxStrLen(EftTransactionRequest."Result Description"));
        EftTransactionRequest."Result Display Text" := CopyStr(State.ResultString, 1, MaxStrLen(EftTransactionRequest."Result Display Text"));
        if EftTransactionRequest.Successful then
            Message('Terminal opened!')
        else
            Message('Terminal could not be opened, error: %1', EftTransactionRequest."Result Display Text");
    end;

    local procedure CloseTerminalEnd(var EftTransactionRequest: Record "NPR EFT Transaction Request"; State: DotNet NPRNetState5)
    begin
        if not GenericErrorCheck(EftTransactionRequest, State) then
            exit;

        EftTransactionRequest.Successful := State.Success;
        EftTransactionRequest."Result Description" := CopyStr(State.ResultString, 1, MaxStrLen(EftTransactionRequest."Result Description"));
        EftTransactionRequest."Result Display Text" := CopyStr(State.ResultString, 1, MaxStrLen(EftTransactionRequest."Result Display Text"));
        if EftTransactionRequest.Successful then
            Message('Terminal Closed!')
        else
            Message('Terminal could not be closed, error: %1', EftTransactionRequest."Result Display Text");
    end;

    local procedure VerifySetupEnd(var EftTransactionRequest: Record "NPR EFT Transaction Request"; State: DotNet NPRNetState5)
    begin
        if not GenericErrorCheck(EftTransactionRequest, State) then
            exit;

        EftTransactionRequest.Successful := State.Success;
        EftTransactionRequest."Result Description" := CopyStr(State.ResultString, 1, MaxStrLen(EftTransactionRequest."Result Description"));
        EftTransactionRequest."Result Display Text" := CopyStr(State.ResultString, 1, MaxStrLen(EftTransactionRequest."Result Display Text"));
        if EftTransactionRequest.Successful then
            Message('Terminal connection and dependency test successful. No issues found.');
    end;

    local procedure LookupTransactionEnd(var EftTransactionRequest: Record "NPR EFT Transaction Request"; State: DotNet NPRNetState5)
    var
        OutStream: OutStream;
        OriginalTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if not GenericErrorCheck(EftTransactionRequest, State) then
            exit;

        OriginalTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");

        EftTransactionRequest.Successful := State.Success; //=Did the lookup succeed? Amount output & currency will show the details of the lookup,
        EftTransactionRequest."Result Description" := CopyStr(State.ResultString, 1, MaxStrLen(EftTransactionRequest."Result Description"));
        EftTransactionRequest."Result Display Text" := CopyStr(State.ResultString, 1, MaxStrLen(EftTransactionRequest."Result Display Text"));
        EftTransactionRequest."External Transaction ID" := State.ExternalReferenceNo;
        EftTransactionRequest."Reference Number Output" := State.ExternalReferenceNo;
        EftTransactionRequest."External Result Known" := State.ExternalResultReceived;
        EftTransactionRequest."Receipt 1".CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.Write(State.Receipt);
        //-NPR5.48 [339930]
        //HandleReceipt(EftTransactionRequest, State);
        //+NPR5.48 [339930]

        if State.OriginalSuccess then begin
            if OriginalTransactionRequest."Processing Type" = OriginalTransactionRequest."Processing Type"::VOID then
                EftTransactionRequest."Amount Output" := OriginalTransactionRequest."Amount Input" //Voids don't have an amount in the external mock terminal syntax
            else
                EftTransactionRequest."Amount Output" := State.AmountOut;

            EftTransactionRequest."Result Amount" := EftTransactionRequest."Amount Output";
            EftTransactionRequest."Currency Code" := OriginalTransactionRequest."Currency Code";
        end;
    end;

    local procedure VoidTransactionEnd(var EftTransactionRequest: Record "NPR EFT Transaction Request"; State: DotNet NPRNetState5)
    var
        OriginalTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if not GenericErrorCheck(EftTransactionRequest, State) then
            exit;

        OriginalTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");

        EftTransactionRequest.Successful := State.Success;
        EftTransactionRequest."Result Description" := CopyStr(State.ResultString, 1, MaxStrLen(EftTransactionRequest."Result Description"));
        EftTransactionRequest."Result Display Text" := CopyStr(State.ResultString, 1, MaxStrLen(EftTransactionRequest."Result Display Text"));
        EftTransactionRequest."External Transaction ID" := State.ExternalReferenceNo;
        EftTransactionRequest."Reference Number Output" := State.ExternalReferenceNo;
        EftTransactionRequest."External Result Known" := State.ExternalResultReceived;

        if EftTransactionRequest.Successful then begin
            EftTransactionRequest."Amount Output" := EftTransactionRequest."Amount Input";
            EftTransactionRequest."Result Amount" := EftTransactionRequest."Amount Input";
            Message('Void success');
        end else
            Message('Void fail');
    end;

    local procedure BalanceEnquiryEnd(var EftTransactionRequest: Record "NPR EFT Transaction Request"; State: DotNet NPRNetState5)
    begin
        if not GenericErrorCheck(EftTransactionRequest, State) then
            exit;

        EftTransactionRequest.Successful := State.Success;
        EftTransactionRequest."Result Description" := CopyStr(State.ResultString, 1, MaxStrLen(EftTransactionRequest."Result Description"));
        EftTransactionRequest."Result Display Text" := CopyStr(State.ResultString, 1, MaxStrLen(EftTransactionRequest."Result Display Text"));
        EftTransactionRequest."Amount Output" := State.AmountOut;
        EftTransactionRequest."Result Amount" := State.AmountOut;
        Message('Balance Enquiry: %1 (%2)', EftTransactionRequest."Result Display Text", EftTransactionRequest."Amount Output");
    end;

    local procedure ReprintReceiptEnd(var EftTransactionRequest: Record "NPR EFT Transaction Request"; State: DotNet NPRNetState5)
    begin
        if not GenericErrorCheck(EftTransactionRequest, State) then
            exit;

        EftTransactionRequest.Successful := State.Success;
        EftTransactionRequest."Result Description" := CopyStr(State.ResultString, 1, MaxStrLen(EftTransactionRequest."Result Description"));
        EftTransactionRequest."Result Display Text" := CopyStr(State.ResultString, 1, MaxStrLen(EftTransactionRequest."Result Display Text"));
    end;

    local procedure "// Aux"()
    begin
    end;

    local procedure SetConnectionInitState(var State: DotNet NPRNetState5; EFTSetup: Record "NPR EFT Setup")
    var
        ConnectionMethod: Integer;
        Connection: DotNet NPRNetState_Connection;
        EFTMockClientIntegration: Codeunit "NPR EFT Mock Client Integ.";
    begin
        ConnectionMethod := EFTMockClientIntegration.GetConnectionMethod(EFTSetup);

        case ConnectionMethod of
            0: //USB
                begin
                    State.ConnectionMethod := Connection.USB;
                    State.COMPort := EFTMockClientIntegration.GetVirtualCOM(EFTSetup);
                end;
            1: //Ethernet
                begin
                    State.ConnectionMethod := Connection.Ethernet;
                    State.IPAddr := EFTMockClientIntegration.GetIPAddr(EFTSetup);
                    if State.IPAddr = '' then
                        Error('Missing LAN IP in setup');
                end;
        end;
    end;

    local procedure SetCaptionState(var State: DotNet NPRNetState5)
    var
        Captions: DotNet NPRNetCaptions;
    begin
        State.Captions.CloseButton := DialogCloseButton;
        State.Captions.ForceCloseButton := DialogForceCloseButton;
        State.Captions.TimeoutReached := DialogTimeoutReached;
        State.Captions.CancelError := DialogCancelError;
        State.Captions.CancelSuccess := DialogCancelSuccess;
        State.Captions.CancelStarted := DialogCancelStarted;
        State.Captions.TransactionError := DialogTransactionError;
        State.Captions.TransactionDeclined := DialogTransactionDeclined;
        State.Captions.TransactionSuccess := DialogTransactionSuccess;
        State.Captions.TransactionStarted := DialogTransactionStarted;
        State.Captions.TransactionDone := DialogTransactionDone;
        State.Captions.TerminalIsClosed := DialogTerminalIsClosed;
    end;

    local procedure HandleReceipt(EftTransactionRequest: Record "NPR EFT Transaction Request"; var State: DotNet NPRNetState5)
    var
        CreditCardTransaction: Record "NPR EFT Receipt";
        EntryNo: Integer;
        ReceiptNo: Integer;
        StringReader: DotNet NPRNetStringReader;
        Line: DotNet NPRNetString;
    begin
        if State.Receipt = '' then
            exit;

        CreditCardTransaction.SetRange("Register No.", EftTransactionRequest."Register No.");
        CreditCardTransaction.SetRange("Sales Ticket No.", EftTransactionRequest."Sales Ticket No.");
        EntryNo := 1;
        if (CreditCardTransaction.FindLast()) then begin
            EntryNo := CreditCardTransaction."Entry No." + 1;
            ReceiptNo := CreditCardTransaction."Receipt No." + 1;
        end;

        CreditCardTransaction.Init;
        CreditCardTransaction.Date := Today;
        CreditCardTransaction."Transaction Time" := Time;
        CreditCardTransaction.Type := 0;
        CreditCardTransaction."Register No." := EftTransactionRequest."Register No.";
        CreditCardTransaction."Sales Ticket No." := EftTransactionRequest."Sales Ticket No.";
        CreditCardTransaction."EFT Trans. Request Entry No." := EftTransactionRequest."Entry No.";
        CreditCardTransaction."Receipt No." := ReceiptNo;

        StringReader := StringReader.StringReader(State.Receipt);
        Line := StringReader.ReadLine();
        while (not IsNull(Line)) do begin
            CreditCardTransaction."Entry No." := EntryNo;
            CreditCardTransaction.Text := Line;
            CreditCardTransaction.Insert;
            EntryNo += 1;
            Line := StringReader.ReadLine();
        end;
    end;

    local procedure "// Event Publishers"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterProtocolResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin
    end;
}

