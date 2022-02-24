codeunit 6184512 "NPR EFT Mock Client Prot."
{
    Access = Internal;

    procedure IntegrationType(): Text
    begin
        exit('MOCK_CLIENT_SIDE');
    end;

    local procedure HwcIntegrationName(): Text
    begin
        exit('EFTMock');
    end;

    procedure CreateHwcEftDeviceRequest(EftTransactionRequest: Record "NPR EFT Transaction Request"; HwcRequest: JsonObject)
    begin
        case EftTransactionRequest."Processing Type" of
            EftTransactionRequest."Processing Type"::OPEN:
                OpenTerminal(EftTransactionRequest, HwcRequest);
            EftTransactionRequest."Processing Type"::CLOSE:
                CloseTerminal(EftTransactionRequest, HwcRequest);
            EftTransactionRequest."Processing Type"::LOOK_UP:
                LookupTransaction(EftTransactionRequest, HwcRequest);
            EftTransactionRequest."Processing Type"::SETUP:
                VerifySetup(EftTransactionRequest, HwcRequest);
            EftTransactionRequest."Processing Type"::GIFTCARD_LOAD:
                PaymentTransaction(EftTransactionRequest, HwcRequest);
            EftTransactionRequest."Processing Type"::REFUND:
                PaymentTransaction(EftTransactionRequest, HwcRequest);
            EftTransactionRequest."Processing Type"::PAYMENT:
                PaymentTransaction(EftTransactionRequest, HwcRequest);
            EftTransactionRequest."Processing Type"::VOID:
                VoidTransaction(EftTransactionRequest, HwcRequest);
            EftTransactionRequest."Processing Type"::AUXILIARY:
                case EftTransactionRequest."Auxiliary Operation ID" of
                    1:
                        BalanceEnquiry(EftTransactionRequest, HwcRequest);
                    2:
                        ReprintLastReceipt(EftTransactionRequest, HwcRequest);
                end;
        end;

        // supply defaults if not already specified 
        if (not HwcRequest.Contains('Timeout')) then
            HwcRequest.Add('Timeout', 100000);

        if (not HwcRequest.Contains('CancelTimeout')) then
            HwcRequest.Add('CancelTimeout', 5000);

        if (not HwcRequest.Contains('Captions')) then
            HwcRequest.Add('Captions', AssignCaptions());

    end;

    local procedure PaymentTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request"; HwcRequest: JsonObject)
    begin
        HwcRequest.Add('WorkflowName', Format(Enum::"NPR POS Workflow"::EFT_MOCK_CLIENT));
        HwcRequest.Add('HwcName', HwcIntegrationName());
        HwcRequest.Add('Type', 'Transaction');
        HwcRequest.Add('EntryNo', EFTTransactionRequest."Entry No.");
        HwcRequest.Add('ReceiptNo', EFTTransactionRequest."Sales Ticket No.");
        //State.Captions.Amount := Format(EftTransactionRequest."Amount Input", 0, '<Precision,2:2><Standard Format,2>');
        HwcRequest.Add('AmountIn', Round(EftTransactionRequest."Amount Input" * 100, 1));
        HwcRequest.Add('Timeout', 30 * 1000);
        HwcRequest.Add('CancelTimeout', 5 * 1000);

        HwcRequest.Add('SalesId', EFTTransactionRequest."Sales ID");
        HwcRequest.Add('SuggestedAmountUserLocal', Format(EftTransactionRequest."Amount Input"));
        HwcRequest.Add('CurrencyCode', EFTTransactionRequest."Currency Code");
    end;

    local procedure OpenTerminal(EftTransactionRequest: Record "NPR EFT Transaction Request"; HwcRequest: JsonObject)
    var
        EFTSetup: Record "NPR EFT Setup";
    begin
        EFTSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."POS Payment Type Code");

        HwcRequest.Add('WorkflowName', Format(Enum::"NPR POS Workflow"::EFT_GENERIC_OPEN));
        HwcRequest.Add('HwcName', HwcIntegrationName());
        HwcRequest.Add('Type', 'Open');
        HwcRequest.Add('EntryNo', EftTransactionRequest."Entry No.");

        SetConnectionInitState(HwcRequest, EFTSetup);
    end;

    local procedure CloseTerminal(EftTransactionRequest: Record "NPR EFT Transaction Request"; HwcRequest: JsonObject)
    begin
        HwcRequest.Add('WorkflowName', Format(Enum::"NPR POS Workflow"::EFT_GENERIC_CLOSE));
        HwcRequest.Add('HwcName', HwcIntegrationName());
        HwcRequest.Add('Type', 'Close');
        HwcRequest.Add('ReceiptNo', EftTransactionRequest."Sales Ticket No.");
        HwcRequest.Add('EntryNo', EftTransactionRequest."Entry No.");
    end;

    local procedure VerifySetup(EftTransactionRequest: Record "NPR EFT Transaction Request"; HwcRequest: JsonObject)
    begin
        HwcRequest.Add('WorkflowName', Format(Enum::"NPR POS Workflow"::EFT_GENERIC_AUX));
        HwcRequest.Add('HwcName', HwcIntegrationName());
        HwcRequest.Add('Type', 'VerifySetup');
        HwcRequest.Add('ReceiptNo', EftTransactionRequest."Sales Ticket No.");
        HwcRequest.Add('EntryNo', EftTransactionRequest."Entry No.");
    end;

    local procedure LookupTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request"; HwcRequest: JsonObject)
    var
        OriginalTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        OriginalTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");

        HwcRequest.Add('WorkflowName', Format(Enum::"NPR POS Workflow"::EFT_MOCK_CLIENT));
        HwcRequest.Add('HwcName', HwcIntegrationName());
        HwcRequest.Add('Type', 'Lookup');
        HwcRequest.Add('EntryNo', EftTransactionRequest."Entry No.");
        HwcRequest.Add('ReceiptNo', EftTransactionRequest."Sales Ticket No.");
        HwcRequest.Add('OriginalRequestEntryNo', OriginalTransactionRequest."Entry No.");
        HwcRequest.Add('OriginalExternalReferenceNo', OriginalTransactionRequest."External Transaction ID");
        HwcRequest.Add('OriginalReceiptNo', OriginalTransactionRequest."Sales Ticket No.");

        HwcRequest.Add('SuggestedAmountUserLocal', Format(OriginalTransactionRequest."Amount Input"));
        HwcRequest.Add('CurrencyCode', OriginalTransactionRequest."Currency Code");
    end;

    local procedure VoidTransaction(EftTransactionRequest: Record "NPR EFT Transaction Request"; HwcRequest: JsonObject)
    var
        OriginalTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        OriginalTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");

        HwcRequest.Add('WorkflowName', Format(Enum::"NPR POS Workflow"::EFT_MOCK_CLIENT));
        HwcRequest.Add('HwcName', HwcIntegrationName());
        HwcRequest.Add('Type', 'Void');
        HwcRequest.Add('EntryNo', EftTransactionRequest."Entry No.");
        HwcRequest.Add('ReceiptNo', EftTransactionRequest."Sales Ticket No.");
        HwcRequest.Add('OriginalRequestEntryNo', OriginalTransactionRequest."Entry No.");
        HwcRequest.Add('OriginalExternalReferenceNo', OriginalTransactionRequest."External Transaction ID");
        HwcRequest.Add('OriginalReceiptNo', OriginalTransactionRequest."Sales Ticket No.");

        HwcRequest.Add('SuggestedAmountUserLocal', Format(OriginalTransactionRequest."Amount Input"));
        HwcRequest.Add('CurrencyCode', OriginalTransactionRequest."Currency Code");
    end;

    local procedure BalanceEnquiry(EftTransactionRequest: Record "NPR EFT Transaction Request"; HwcRequest: JsonObject)
    begin
        HwcRequest.Add('WorkflowName', Format(Enum::"NPR POS Workflow"::EFT_GENERIC_AUX));
        HwcRequest.Add('HwcName', HwcIntegrationName());
        HwcRequest.Add('Type', 'BalanceEnquiry');
        HwcRequest.Add('EntryNo', EftTransactionRequest."Entry No.");
        HwcRequest.Add('ReceiptNo', EftTransactionRequest."Sales Ticket No.");
    end;

    local procedure ReprintLastReceipt(EftTransactionRequest: Record "NPR EFT Transaction Request"; HwcRequest: JsonObject)
    begin
        HwcRequest.Add('WorkflowName', Format(Enum::"NPR POS Workflow"::EFT_GENERIC_AUX));
        HwcRequest.Add('HwcName', HwcIntegrationName());
        HwcRequest.Add('Type', 'Reprint');
        HwcRequest.Add('EntryNo', EftTransactionRequest."Entry No.");
        HwcRequest.Add('ReceiptNo', EftTransactionRequest."Sales Ticket No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR EFT Interface", 'OnHwcEftDeviceResponse', '', false, false)]
    local procedure OnDeviceResponse(HwcName: Text; HwcType: Text; Request: JsonObject; Response: JsonObject; Result: JsonObject; var Handled: Boolean)
    begin
        if (HwcName <> HwcIntegrationName()) then
            exit;
        Handled := true;

        HandleDeviceResponse(HwcName, HwcType, Request, Response, Result);
    end;

    internal procedure HandleDeviceResponse(HwcName: Text; HwcType: Text; Request: JsonObject; Response: JsonObject; Result: JsonObject) EntryNo: Integer
    var
        EftTransactionRequest: Record "NPR EFT Transaction Request";
        JToken: JsonToken;
    begin
        Request.Get('EntryNo', JToken);
        EftTransactionRequest.Get(JToken.AsValue().AsInteger());

        if (Response.Get('ResultCode', JToken)) then
            EftTransactionRequest."Result Code" := JToken.AsValue().AsInteger();

        if (Response.Get('ExecutingAssemblyVersion', JToken)) then
            EftTransactionRequest."Client Assembly Version" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."Client Assembly Version"));

        if (not HandleResponseType(HwcType, Response, Result, EftTransactionRequest)) then begin
            EftTransactionRequest."NST Error" := CopyStr(GetLastErrorText, 1, MaxStrLen(EftTransactionRequest."NST Error"));
            EftTransactionRequest."POS Description" := CopyStr(GetLastErrorText, 1, MaxStrLen(EftTransactionRequest."POS Description"));
            EftTransactionRequest.Successful := false;
            if (not Result.Contains('Message')) then
                Result.Add('Message', EftTransactionRequest."NST Error");
        end;

        if (Response.Get('Receipt', JToken)) then
            if (not (JToken.AsValue().IsNull())) then
                CreateCustomerReceipt(EftTransactionRequest);

        EftTransactionRequest.Modify();

        Result.Add('Success', EftTransactionRequest.Successful);
        exit(EftTransactionRequest."Entry No.");
    end;

    [TryFunction]
    local procedure HandleResponseType(HwcType: Text; Response: JsonObject; Result: JsonObject; var EftTransactionRequest: Record "NPR EFT Transaction Request")
    begin

        case HwcType of
            'Open':
                OpenTerminalEnd(EftTransactionRequest, Response, Result);
            'Close':
                CloseTerminalEnd(EftTransactionRequest, Response, Result);
            'Transaction':
                PaymentTransactionEnd(EftTransactionRequest, Response, Result);
            'Lookup':
                LookupTransactionEnd(EftTransactionRequest, Response, Result);
            'Void':
                VoidTransactionEnd(EftTransactionRequest, Response, Result);
            'VerifySetup':
                VerifySetupEnd(EftTransactionRequest, Response, Result);
            'BalanceEnquiry':
                BalanceEnquiryEnd(EftTransactionRequest, Response, Result);
            'Reprint':
                ReprintReceiptEnd(EftTransactionRequest, Response);
            else
                Error('%1 not handled.', HwcType);
        end;
    end;

    local procedure GenericErrorCheck(var EftTransactionRequest: Record "NPR EFT Transaction Request"; Response: JsonObject): Boolean
    var
        JToken: JsonToken;
    begin
        case EftTransactionRequest."Result Code" of
            -100: //Closed terminal - request never started
                begin
                    if (Response.Get('ResultString', JToken)) then
                        EftTransactionRequest."Result Display Text" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."Result Display Text"));
                    EftTransactionRequest."Result Description" := 'Terminal is closed';
                    EftTransactionRequest."External Result Known" := true;
                end;
            -101: //Connection failed - request never started
                begin
                    if (Response.Get('ResultString', JToken)) then
                        EftTransactionRequest."Result Display Text" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."Result Display Text"));
                    EftTransactionRequest."Result Description" := 'Connection failed';
                    EftTransactionRequest."External Result Known" := true;
                end
            else
                exit(true); //No generic errors
        end;

        Message(EftTransactionRequest."Result Display Text"); //Show the error to user
    end;

    local procedure PaymentTransactionEnd(var EftTransactionRequest: Record "NPR EFT Transaction Request"; Response: JsonObject; Result: JsonObject)
    var
        ReceiptStream: OutStream;
        JToken: JsonToken;
        Amount: Decimal;
        SuccessMsg: Label 'Transaction Successful.';
        FailMsg: Label 'Transaction failed, error: %1';
    begin

        if (Response.Get('AmountOut', JToken)) then;
        Amount := JToken.AsValue().AsDecimal();

        if (Abs(Amount) = 700) then
            Error('EFT Mock - Simulating crash at NST side.');

        if (Response.Get('Success', JToken)) then
            EftTransactionRequest.Successful := JToken.AsValue().AsBoolean();

        if (Response.Get('ResultString', JToken)) then begin
            EftTransactionRequest."Result Description" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."Result Description"));
            EftTransactionRequest."Result Display Text" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."Result Display Text"));
        end;

        if (Response.Get('ExternalReferenceNo', JToken)) then begin
            EftTransactionRequest."External Transaction ID" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."External Transaction ID"));
            EftTransactionRequest."Reference Number Output" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."Reference Number Output"));
        end;

        EFTTransactionRequest."POS Description" := CopyStr(StrSubstNo('** TEST ** EFT Mock: %1 - %2', EFTTransactionRequest."Result Code", EFTTransactionRequest."Result Description"), 1, MaxStrLen(EFTTransactionRequest."POS Description"));

        EftTransactionRequest."Amount Output" := Amount / 100;
        EftTransactionRequest."Result Amount" := Amount / 100;

        if (Response.Get('ExternalResultReceived', JToken)) then
            EftTransactionRequest."External Result Known" := JToken.AsValue().AsBoolean();

        if (Response.Get('Receipt', JToken)) then begin
            EftTransactionRequest."Receipt 1".CreateOutStream(ReceiptStream, TEXTENCODING::UTF8);
            ReceiptStream.Write(JToken.AsValue().AsText());
        end;

        if (EftTransactionRequest.Successful) then
            Result.Add('Message', SuccessMsg);
        if (not EftTransactionRequest.Successful) then
            Result.Add('Message', StrSubstNo(FailMsg, EftTransactionRequest."Result Display Text"));
    end;

    local procedure OpenTerminalEnd(var EftTransactionRequest: Record "NPR EFT Transaction Request"; Response: JsonObject; Result: JsonObject)
    var
        JToken: JsonToken;
        SuccessMsg: Label 'Terminal is open.';
        FailMsg: Label 'Terminal could not be opened, error: %1';
    begin
        if (not GenericErrorCheck(EftTransactionRequest, Response)) then
            exit;

        if (Response.Get('Success', JToken)) then
            EftTransactionRequest.Successful := JToken.AsValue().AsBoolean();

        if (Response.Get('ResultString', JToken)) then begin
            EftTransactionRequest."Result Description" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."Result Description"));
            EftTransactionRequest."Result Display Text" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."Result Display Text"));
        end;

        if (EftTransactionRequest.Successful) then
            Result.Add('Message', SuccessMsg);
        if (not EftTransactionRequest.Successful) then
            Result.Add('Message', StrSubstNo(FailMsg, EftTransactionRequest."Result Display Text"));
    end;

    local procedure CloseTerminalEnd(var EftTransactionRequest: Record "NPR EFT Transaction Request"; Response: JsonObject; Result: JsonObject)
    var
        JToken: JsonToken;
        SuccessMsg: Label 'Terminal is closed.';
        FailMsg: Label 'Terminal could not be closed, error: %1';
    begin
        if (not GenericErrorCheck(EftTransactionRequest, Response)) then
            exit;

        if (Response.Get('Success', JToken)) then
            EftTransactionRequest.Successful := JToken.AsValue().AsBoolean();

        if (Response.Get('ResultString', JToken)) then begin
            EftTransactionRequest."Result Description" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."Result Description"));
            EftTransactionRequest."Result Display Text" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."Result Display Text"));
        end;

        if (EftTransactionRequest.Successful) then
            Result.Add('Message', SuccessMsg);
        if (not EftTransactionRequest.Successful) then
            Result.Add('Message', StrSubstNo(FailMsg, EftTransactionRequest."Result Display Text"));
    end;

    local procedure VerifySetupEnd(var EftTransactionRequest: Record "NPR EFT Transaction Request"; Response: JsonObject; Result: JsonObject)
    var
        JToken: JsonToken;
        SuccessMsg: Label 'Connection test was successful.';
        FailMsg: Label 'Connection test fail, error: %1';
    begin
        if (not GenericErrorCheck(EftTransactionRequest, Response)) then
            exit;

        if (Response.Get('Success', JToken)) then
            EftTransactionRequest.Successful := JToken.AsValue().AsBoolean();

        if (Response.Get('ResultString', JToken)) then begin
            EftTransactionRequest."Result Description" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."Result Description"));
            EftTransactionRequest."Result Display Text" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."Result Display Text"));
        end;

        if (EftTransactionRequest.Successful) then
            Result.Add('Message', SuccessMsg);
        if (not EftTransactionRequest.Successful) then
            Result.Add('Message', StrSubstNo(FailMsg, EftTransactionRequest."Result Display Text"));
    end;

    local procedure LookupTransactionEnd(var EftTransactionRequest: Record "NPR EFT Transaction Request"; Response: JsonObject; Result: JsonObject)
    var
        OriginalTransactionRequest: Record "NPR EFT Transaction Request";
        ReceiptStream: OutStream;
        JToken: JsonToken;
        Amount: Decimal;
        SuccessMsg: Label 'Transaction Successful.';
        FailMsg: Label 'Transaction failed, error: %1';
    begin

        if (not GenericErrorCheck(EftTransactionRequest, Response)) then
            exit;

        OriginalTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");

        if (Response.Get('AmountOut', JToken)) then;
        Amount := JToken.AsValue().AsDecimal();

        if (Abs(Amount) = 701) then
            Error('EFT Mock - Simulating crash at NST side.');

        if (Response.Get('Success', JToken)) then
            EftTransactionRequest.Successful := JToken.AsValue().AsBoolean();

        if (Response.Get('ResultString', JToken)) then begin
            EftTransactionRequest."Result Description" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."Result Description"));
            EftTransactionRequest."Result Display Text" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."Result Display Text"));
        end;

        if (Response.Get('ExternalReferenceNo', JToken)) then begin
            EftTransactionRequest."External Transaction ID" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."External Transaction ID"));
            EftTransactionRequest."Reference Number Output" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."Reference Number Output"));
        end;

        EFTTransactionRequest."POS Description" := CopyStr(StrSubstNo('** TEST ** EFT Mock: %1 - %2', EFTTransactionRequest."Result Code", EFTTransactionRequest."Result Description"), 1, MaxStrLen(EFTTransactionRequest."POS Description"));

        if (Response.Get('ExternalResultReceived', JToken)) then
            EftTransactionRequest."External Result Known" := JToken.AsValue().AsBoolean();

        if (Response.Get('Receipt', JToken)) then begin
            EftTransactionRequest."Receipt 1".CreateOutStream(ReceiptStream, TEXTENCODING::UTF8);
            ReceiptStream.Write(JToken.AsValue().AsText());
        end;

        if (EftTransactionRequest.Successful) then
            Result.Add('Message', SuccessMsg);
        if (not EftTransactionRequest.Successful) then
            Result.Add('Message', StrSubstNo(FailMsg, EftTransactionRequest."Result Display Text"));

        if (Response.Get('OriginalSuccess', JToken)) then begin
            if (JToken.AsValue().AsBoolean()) then begin
                if (OriginalTransactionRequest."Processing Type" = OriginalTransactionRequest."Processing Type"::VOID) then
                    EftTransactionRequest."Amount Output" := OriginalTransactionRequest."Amount Input" //Voids don't have an amount in the external mock terminal syntax
                else
                    EftTransactionRequest."Amount Output" := Amount / 100;

                EftTransactionRequest."Result Amount" := EftTransactionRequest."Amount Output";
                EftTransactionRequest."Currency Code" := OriginalTransactionRequest."Currency Code";
            end;
        end;
    end;

    local procedure VoidTransactionEnd(var EftTransactionRequest: Record "NPR EFT Transaction Request"; Response: JsonObject; Result: JsonObject)
    var
        JToken: JsonToken;
        Amount: Decimal;
        ReceiptStream: OutStream;
        SuccessMsg: Label 'Void was successful.';
        FailMsg: Label ' Void failed. Error: %1';
    begin
        if (not GenericErrorCheck(EftTransactionRequest, Response)) then
            exit;

        if (Response.Get('AmountOut', JToken)) then;
        Amount := JToken.AsValue().AsDecimal();

        if (Abs(Amount) = 702) then
            Error('EFT Mock - Simulating crash at NST side.');

        if (Response.Get('Success', JToken)) then
            EftTransactionRequest.Successful := JToken.AsValue().AsBoolean();

        if (Response.Get('ResultString', JToken)) then begin
            EftTransactionRequest."Result Description" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."Result Description"));
            EftTransactionRequest."Result Display Text" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."Result Display Text"));
        end;

        if (Response.Get('ExternalReferenceNo', JToken)) then begin
            EftTransactionRequest."External Transaction ID" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."External Transaction ID"));
            EftTransactionRequest."Reference Number Output" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."Reference Number Output"));
        end;

        EFTTransactionRequest."POS Description" := CopyStr(StrSubstNo('** TEST ** EFT Mock: %1 - %2', EFTTransactionRequest."Result Code", EFTTransactionRequest."Result Description"), 1, MaxStrLen(EFTTransactionRequest."POS Description"));

        if (Response.Get('ExternalResultReceived', JToken)) then
            EftTransactionRequest."External Result Known" := JToken.AsValue().AsBoolean();

        if (EftTransactionRequest.Successful) then begin
            EftTransactionRequest."Amount Output" := Amount / 100;
            EftTransactionRequest."Result Amount" := Amount / 100 * -1;
        end;

        if (Response.Get('Receipt', JToken)) then begin
            EftTransactionRequest."Receipt 1".CreateOutStream(ReceiptStream, TEXTENCODING::UTF8);
            ReceiptStream.Write(JToken.AsValue().AsText());
        end;

        if (EftTransactionRequest.Successful) then
            Result.Add('Message', SuccessMsg);
        if (not EftTransactionRequest.Successful) then
            Result.Add('Message', StrSubstNo(FailMsg, EftTransactionRequest."Result Display Text"));
    end;

    local procedure BalanceEnquiryEnd(var EftTransactionRequest: Record "NPR EFT Transaction Request"; Response: JsonObject; Result: JsonObject)
    var
        JToken: JsonToken;
        Amount: Decimal;
        ReceiptStream: OutStream;
        SuccessMsg: Label 'Balance Enquiry: %1 (%2)';
        FailMsg: Label ' Balancy Enquiry failed. Error: %1';
    begin
        if (not GenericErrorCheck(EftTransactionRequest, Response)) then
            exit;

        if (Response.Get('Success', JToken)) then
            EftTransactionRequest.Successful := JToken.AsValue().AsBoolean();

        if (Response.Get('ResultString', JToken)) then begin
            EftTransactionRequest."Result Description" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."Result Description"));
            EftTransactionRequest."Result Display Text" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."Result Display Text"));
        end;

        if (Response.Get('ExternalReferenceNo', JToken)) then begin
            EftTransactionRequest."External Transaction ID" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."External Transaction ID"));
            EftTransactionRequest."Reference Number Output" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."Reference Number Output"));
        end;

        if (Response.Get('ExternalResultReceived', JToken)) then
            EftTransactionRequest."External Result Known" := JToken.AsValue().AsBoolean();

        if (EftTransactionRequest.Successful) then begin
            if (Response.Get('AmountOut', JToken)) then
                Amount := JToken.AsValue().AsDecimal();

            EftTransactionRequest."Amount Output" := Amount / 100;
            EftTransactionRequest."Result Amount" := Amount / 100;
        end;

        if (Response.Get('Receipt', JToken)) then begin
            EftTransactionRequest."Receipt 1".CreateOutStream(ReceiptStream, TEXTENCODING::UTF8);
            ReceiptStream.Write(JToken.AsValue().AsText());
        end;

        if (EftTransactionRequest.Successful) then
            Result.Add('Message', StrSubstNo(SuccessMsg, EftTransactionRequest."Result Display Text", EftTransactionRequest."Amount Output"));
        if (not EftTransactionRequest.Successful) then
            Result.Add('Message', StrSubstNo(FailMsg, EftTransactionRequest."Result Display Text"));
    end;

    local procedure ReprintReceiptEnd(var EftTransactionRequest: Record "NPR EFT Transaction Request"; Response: JsonObject)
    var
        JToken: JsonToken;
        ReceiptStream: OutStream;
    begin
        if (not GenericErrorCheck(EftTransactionRequest, Response)) then
            exit;

        if (Response.Get('Success', JToken)) then
            EftTransactionRequest.Successful := JToken.AsValue().AsBoolean();

        if (Response.Get('ResultString', JToken)) then begin
            EftTransactionRequest."Result Description" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."Result Description"));
            EftTransactionRequest."Result Display Text" := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(EftTransactionRequest."Result Display Text"));
        end;

        if (Response.Get('ExternalResultReceived', JToken)) then
            EftTransactionRequest."External Result Known" := JToken.AsValue().AsBoolean();

        if (Response.Get('Receipt', JToken)) then begin
            EftTransactionRequest."Receipt 1".CreateOutStream(ReceiptStream, TEXTENCODING::UTF8);
            ReceiptStream.Write(JToken.AsValue().AsText());
        end;

    end;

    local procedure SetConnectionInitState(HwcRequest: JsonObject; EFTSetup: Record "NPR EFT Setup")
    var
        ConnectionMethod: Integer;
        EFTMockClientIntegration: Codeunit "NPR EFT Mock Client Integ.";
        JToken: JsonToken;
    begin
        ConnectionMethod := EFTMockClientIntegration.GetConnectionMethod(EFTSetup);
        HwcRequest.Add('ConnectionMethod', ConnectionMethod);

        case ConnectionMethod of
            0: //USB
                begin
                    HwcRequest.Add('COMPort', EFTMockClientIntegration.GetVirtualCOM(EFTSetup));
                end;
            1: //Ethernet
                begin
                    HwcRequest.Add('IPAddr', EFTMockClientIntegration.GetIPAddr(EFTSetup));
                    HwcRequest.Get('IPAddr', JToken);
                    if (JToken.AsValue().AsText() = '') then
                        Error('Missing LAN IP in setup');
                end;
        end;
    end;

    local procedure AssignCaptions() Captions: JsonObject
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
        DialogForceClosing: Label 'Force aborting transaction';
        DialogAuthorizing: Label 'Authorizing...';
    begin
        Captions.Add('CloseButton', DialogCloseButton);
        Captions.Add('ForceCloseButton', DialogForceCloseButton);
        Captions.Add('TimeoutReached', DialogTimeoutReached);
        Captions.Add('CancelError', DialogCancelError);
        Captions.Add('CancelSuccess', DialogCancelSuccess);
        Captions.Add('CancelStarted', DialogCancelStarted);
        Captions.Add('TransactionError', DialogTransactionError);
        Captions.Add('TransactionDeclined', DialogTransactionDeclined);
        Captions.Add('TransactionSuccess', DialogTransactionSuccess);
        Captions.Add('TransactionStarted', DialogTransactionStarted);
        Captions.Add('TransactionDone', DialogTransactionDone);
        Captions.Add('TerminalIsClosed', DialogTerminalIsClosed);
        Captions.Add('ForceClosing', DialogForceClosing);
        Captions.Add('Authorizing', DialogAuthorizing);
    end;

    local procedure CreateCustomerReceipt(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        CreditCardTransaction: Record "NPR EFT Receipt";
        EntryNo: Integer;
        ReceiptNo: Integer;
        StreamIn: InStream;
        ReceiptLineText: Text;
    begin

        if (not EFTTransactionRequest."Receipt 1".HasValue()) then
            exit;

        EftTransactionRequest.CalcFields("Receipt 1");
        EFTTransactionRequest."Receipt 1".CreateInStream(StreamIn);

        CreditCardTransaction.SetRange("Register No.", EftTransactionRequest."Register No.");
        CreditCardTransaction.SetRange("Sales Ticket No.", EftTransactionRequest."Sales Ticket No.");
        EntryNo := 1;
        if (CreditCardTransaction.FindLast()) then begin
            EntryNo := CreditCardTransaction."Entry No." + 1;
            ReceiptNo := CreditCardTransaction."Receipt No." + 1;
        end;

        CreditCardTransaction.Init();
        CreditCardTransaction.Date := Today();
        CreditCardTransaction."Transaction Time" := Time;
        CreditCardTransaction.Type := 0;
        CreditCardTransaction."Register No." := EftTransactionRequest."Register No.";
        CreditCardTransaction."Sales Ticket No." := EftTransactionRequest."Sales Ticket No.";
        CreditCardTransaction."EFT Trans. Request Entry No." := EftTransactionRequest."Entry No.";
        CreditCardTransaction."Receipt No." := ReceiptNo;

        repeat
            StreamIn.ReadText(ReceiptLineText);
            CreditCardTransaction."Entry No." := EntryNo;
            CreditCardTransaction.Text := ReceiptLineText;
            CreditCardTransaction.Insert();
            EntryNo += 1;
        until (StreamIn.EOS);

    end;

}


