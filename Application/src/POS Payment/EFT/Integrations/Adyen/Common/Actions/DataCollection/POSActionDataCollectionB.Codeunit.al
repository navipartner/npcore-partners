codeunit 6150804 "NPR POS Action DataCollectionB"
{
    Access = Internal;

    var
        _EftTransactionEntryNo: Integer;
        _ResponseType: Enum "NPR EFT Adyen Response Type";
        _Data: Text;
        TerminalCanceledTrxLbl: Label 'Transaction canceled on terminal.';
        ShopperAbortedTrxLbl: Label 'Shopper aborted transaction.';

    internal procedure RequestSignature(SalePOS: Record "NPR POS Sale"; var TerminalConfirmationEntryNo: Integer): Boolean
    var
        SignatureEFTTransactionRequest: Record "NPR EFT Transaction Request";
        MMMemberInfoIntSetup: Record "NPR MM Member Info. Int. Setup";
        ReturnInfoCollectSetup: Record "NPR Return Info Collect Setup";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
    begin
        MMMemberInfoIntSetup.Get();
        if MMMemberInfoIntSetup."Request Return Info" <> MMMemberInfoIntSetup."Request Return Info"::Adyen then
            exit;

        if not ReturnInfoCollectSetup.Get() then
            exit;

        if not ReturnInfoCollectSetup."Collect Signature" then
            exit;

        EFTFrameworkMgt.CreateAuxRequest(SignatureEFTTransactionRequest, 9, SalePOS."Register No.", SalePOS."Sales Ticket No.", '');
        SignatureEFTTransactionRequest.Insert();
        SignatureEFTTransactionRequest."Reference Number Input" := Format(SignatureEFTTransactionRequest."Entry No.");
        SignatureEFTTransactionRequest.Modify();
        Commit();

        TerminalConfirmationEntryNo := SignatureEFTTransactionRequest."Entry No.";
        exit(true);
    end;

    internal procedure RequestPhoneNo(SalePOS: Record "NPR POS Sale"; var TerminalConfirmationEntryNo: Integer): Boolean
    var
        PhoneNoEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        MMMemberInfoIntSetup: Record "NPR MM Member Info. Int. Setup";
        Customer: Record Customer;
        ReturnInfoCollectSetup: Record "NPR Return Info Collect Setup";
    begin
        MMMemberInfoIntSetup.Get();
        if MMMemberInfoIntSetup."Request Return Info" <> MMMemberInfoIntSetup."Request Return Info"::Adyen then
            exit;

        if not ReturnInfoCollectSetup.Get() then
            exit;

        if not ReturnInfoCollectSetup."Collect Phone No." then
            exit;

        if SalePOS."Customer No." <> '' then begin
            Customer.SetLoadFields("Phone No.");
            if Customer.Get(SalePOS."Customer No.") and (Customer."Phone No." <> '') then
                exit;
        end;

        EFTFrameworkMgt.CreateAuxRequest(PhoneNoEFTTransactionRequest, 10, SalePOS."Register No.", SalePOS."Sales Ticket No.", '');
        PhoneNoEFTTransactionRequest.Insert();
        PhoneNoEFTTransactionRequest."Reference Number Input" := Format(PhoneNoEFTTransactionRequest."Entry No.");
        PhoneNoEFTTransactionRequest.Modify();
        Commit();

        TerminalConfirmationEntryNo := PhoneNoEFTTransactionRequest."Entry No.";

        exit(true);
    end;

    internal procedure RequestEMail(SalePOS: Record "NPR POS Sale"; var TerminalConfirmationEntryNo: Integer): Boolean
    var
        EMailEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        MMMemberInfoIntSetup: Record "NPR MM Member Info. Int. Setup";
        Customer: Record Customer;
        ReturnInfoCollectSetup: Record "NPR Return Info Collect Setup";
    begin
        MMMemberInfoIntSetup.Get();
        if MMMemberInfoIntSetup."Request Return Info" <> MMMemberInfoIntSetup."Request Return Info"::Adyen then
            exit;

        if not ReturnInfoCollectSetup.Get() then
            exit;

        if not ReturnInfoCollectSetup."Collect E-Mail" then
            exit(false);

        if SalePOS."Customer No." <> '' then begin
            Customer.SetLoadFields("E-Mail");
            if Customer.Get(SalePOS."Customer No.") and (Customer."E-Mail" <> '') then
                exit;
        end;

        EFTFrameworkMgt.CreateAuxRequest(EMailEFTTransactionRequest, 11, SalePOS."Register No.", SalePOS."Sales Ticket No.", '');
        EMailEFTTransactionRequest.Insert();
        EMailEFTTransactionRequest."Reference Number Input" := Format(EMailEFTTransactionRequest."Entry No.");
        EMailEFTTransactionRequest.Modify();
        Commit();

        TerminalConfirmationEntryNo := EMailEFTTransactionRequest."Entry No.";

        exit(true);
    end;

    internal procedure ContinueAfterDataCollectionVerification(TransactionEntryNo: Integer; var ContinueOnTransactionEntryNo: Integer): Boolean
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if not EFTTransactionRequest.Get(TransactionEntryNo) then
            exit(false);

        if EFTTransactionRequest."Processing Type" <> EFTTransactionRequest."Processing Type"::AUXILIARY then
            exit(false);

        case EFTTransactionRequest."Auxiliary Operation ID" of
            "NPR EFT Adyen Aux Operation"::ACQUIRE_SIGNATURE.AsInteger(),
            "NPR EFT Adyen Aux Operation"::ACQUIRE_PHONE_NO.AsInteger(),
            "NPR EFT Adyen Aux Operation"::ACQUIRE_EMAIL.AsInteger():
                begin
                    exit(ShouldProceedToTransactionAfterDataStepCollectConfirmation(EFTTransactionRequest, ContinueOnTransactionEntryNo));
                end;
            else
                EFTTransactionRequest.FieldError("Auxiliary Operation ID");
        end;
    end;

    local procedure ShouldProceedToTransactionAfterDataStepCollectConfirmation(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var ContinueOnTransactionEntryNo: Integer): Boolean
    begin
        if not EFTTransactionRequest.Successful then
            exit(false);

        if not EFTTransactionRequest."Confirmed Flag" then
            exit(false);

        ContinueOnTransactionEntryNo := EFTTransactionRequest."Entry No.";
        exit(true);
    end;

    internal procedure ProcessResponse(RequestEntryNo: Integer; Response: Text; Completed: Boolean; Started: Boolean; ErrorText: Text)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.Get(RequestEntryNo);

        if Completed then begin
            case EFTTransactionRequest."Processing Type" of
                EFTTransactionRequest."Processing Type"::AUXILIARY:
                    case EFTTransactionRequest."Auxiliary Operation ID" of
                        "NPR EFT Adyen Aux Operation"::ABORT_TRX.AsInteger():
                            EndAbortTransaction(EFTTransactionRequest);
                        "NPR EFT Adyen Aux Operation"::ACQUIRE_SIGNATURE.AsInteger():
                            EndAcquireSignature(EFTTransactionRequest, Response);
                        "NPR EFT Adyen Aux Operation"::ACQUIRE_PHONE_NO.AsInteger():
                            EndAcquirePhoneNo(EFTTransactionRequest, Response);
                        "NPR EFT Adyen Aux Operation"::ACQUIRE_EMAIL.AsInteger():
                            EndAcquireEMail(EFTTransactionRequest, Response);
                    end;
            end;
        end else begin
            EFTTransactionRequest."NST Error" := CopyStr(ErrorText, 1, MaxStrLen(EFTTransactionRequest."NST Error"));
            EFTTransactionRequest."External Result Known" := not Started;
            HandleProtocolResponse(EFTTransactionRequest);
        end;
    end;

    local procedure EndAbortTransaction(var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        EFTTransactionRequest."External Result Known" := true;
        EFTTransactionRequest.Successful := true;

        EFTTransactionRequest.Modify();
        HandleProtocolResponse(EFTTransactionRequest);
    end;

    local procedure HandleProtocolResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTInterface: Codeunit "NPR EFT Interface";
    begin
        EFTInterface.EftIntegrationResponse(EftTransactionRequest);
    end;

    local procedure EndAcquireSignature(var EftTransactionRequest: Record "NPR EFT Transaction Request"; Response: Text)
    var
        ParseError: Text;
        ParseSuccess: Boolean;
    begin
        SetResponseData(Enum::"NPR EFT Adyen Response Type"::SignatureAcquisition, Response, EftTransactionRequest."Entry No.");
        ParseSuccess := RunParser();

        if not ParseSuccess then begin
            ParseError := GetLastErrorText;
            SetResponseData(Enum::"NPR EFT Adyen Response Type"::RejectNotification, Response, EftTransactionRequest."Entry No.");
            ParseSuccess := RunParser();
        end;

        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EftTransactionRequest, ParseError);
            EftTransactionRequest.Modify();
        end;

        HandleProtocolResponse(EftTransactionRequest);
    end;


    local procedure EndAcquirePhoneNo(var EftTransactionRequest: Record "NPR EFT Transaction Request"; Response: Text)
    var
        ParseError: Text;
        ParseSuccess: Boolean;
    begin
        SetResponseData(Enum::"NPR EFT Adyen Response Type"::PhoneNoAcquisition, Response, EftTransactionRequest."Entry No.");
        ParseSuccess := RunParser();

        if not ParseSuccess then begin
            ParseError := GetLastErrorText;
            SetResponseData(Enum::"NPR EFT Adyen Response Type"::RejectNotification, Response, EftTransactionRequest."Entry No.");
            ParseSuccess := RunParser();
        end;

        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EftTransactionRequest, ParseError);
            EftTransactionRequest.Modify();
        end;

        HandleProtocolResponse(EftTransactionRequest);
    end;

    local procedure EndAcquireEMail(var EftTransactionRequest: Record "NPR EFT Transaction Request"; Response: Text)
    var
        ParseError: Text;
        ParseSuccess: Boolean;
    begin
        SetResponseData(Enum::"NPR EFT Adyen Response Type"::EMailAcquisition, Response, EftTransactionRequest."Entry No.");
        ParseSuccess := RunParser();

        if not ParseSuccess then begin
            ParseError := GetLastErrorText;
            SetResponseData(Enum::"NPR EFT Adyen Response Type"::RejectNotification, Response, EftTransactionRequest."Entry No.");
            ParseSuccess := RunParser();
        end;

        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EftTransactionRequest, ParseError);
            EftTransactionRequest.Modify();
        end;

        HandleProtocolResponse(EftTransactionRequest);
    end;

    local procedure RunParser(): Boolean
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        ERROR_RESPONSE_TYPE: Label 'Unknown response type %1';
    begin
        EFTTransactionRequest.Get(_EftTransactionEntryNo);
        case _ResponseType of
            Enum::"NPR EFT Adyen Response Type"::SignatureAcquisition:
                ParseSignatureAcquisition(_Data, EFTTransactionRequest);
            Enum::"NPR EFT Adyen Response Type"::PhoneNoAcquisition:
                ParsePhoneNoAcquisition(_Data, EFTTransactionRequest);
            Enum::"NPR EFT Adyen Response Type"::EMailAcquisition:
                ParseEMailAcquisition(_Data, EFTTransactionRequest);
            else
                Error(ERROR_RESPONSE_TYPE, _ResponseType);
        end;

        EFTTransactionRequest.Modify();
        exit(true);
    end;

    internal procedure ParseSignatureAcquisition(Response: Text; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTAdyenResponseParser: Codeunit "NPR EFT Adyen Response Parser";
        EFTAdyenSignatureBuffer: Codeunit "NPR EFT Adyen Signature Buffer";
        TypeHelper: Codeunit "Type Helper";
        JObject: JsonObject;
        JToken: JsonToken;
        SignatureBitmap: Text;
        SignatureDataJsonText: Text;
        TextSignatureData: Text;
        OutStr: OutStream;
        ScreenTimeoutLbl: Label 'Terminal screen timed out.';
    begin
        JObject.ReadFrom(Response);

        EFTAdyenResponseParser.TrySelectToken(JObject, 'ConfirmedFlag', JToken, true);
        EFTTransactionRequest."Confirmed Flag" := JToken.AsValue().AsBoolean();

        EFTAdyenResponseParser.TrySelectToken(JObject, 'ErrorCondition', JToken, false);
        if (JToken.AsValue().AsText() = 'Aborted') and (not EFTTransactionRequest."Confirmed Flag") then
            EFTTransactionRequest."Result Display Text" := ShopperAbortedTrxLbl;

        if (not EFTTransactionRequest."Confirmed Flag") and (EFTTransactionRequest."Result Display Text" = '') then
            EFTTransactionRequest."Result Display Text" := TerminalCanceledTrxLbl;

        EFTAdyenResponseParser.TrySelectToken(JObject, 'ScreenTimeout', JToken, false);
        if JToken.AsValue().AsBoolean() then
            EFTTransactionRequest."Result Display Text" := ScreenTimeoutLbl;

        EFTAdyenResponseParser.TrySelectToken(JObject, 'Success', JToken, true);
        if JToken.AsValue().AsBoolean() and EFTTransactionRequest."Confirmed Flag" then
            EFTTransactionRequest.Successful := true;

        if EFTAdyenResponseParser.TrySelectToken(Jobject, 'Signature', JToken, false) then begin
            JToken.WriteTo(SignatureDataJsonText);
            SignatureBitmap := Format(JToken);
            SignatureBitmap := TypeHelper.UrlDecode(SignatureBitmap);
            SignatureBitmap := SignatureBitmap.Replace('responseData=', '');
            SignatureBitmap := SignatureBitmap.TrimStart('"');
            SignatureBitmap := SignatureBitmap.TrimEnd('"');
            if JObject.ReadFrom(SignatureBitmap) then;
            EFTAdyenResponseParser.TrySelectToken(JObject, 'signature.data', JToken, false);
            TextSignatureData := Format(JToken);
        end else
            TextSignatureData := '[{"x":"FFFF","y":"FFFF"}]';

        EFTAdyenSignatureBuffer.SetSignatureData(TextSignatureData, EFTTransactionRequest."Entry No.");

        EFTTransactionRequest."Signature Data".CreateOutStream(OutStr);
        OutStr.Write(TextSignatureData);

        EFTTransactionRequest."External Result Known" := true;
        EFTTransactionRequest."Auto Voidable" := true;
    end;

    local procedure ParsePhoneNoAcquisition(Response: Text; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTAdyenResponseParser: Codeunit "NPR EFT Adyen Response Parser";
        ResponseResult: Text;
        HelperTextVar: Text;
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        JObject.ReadFrom(Response);

        EFTAdyenResponseParser.TrySelectToken(JObject, 'Success', JToken, true);
        EFTTransactionRequest.Successful := JToken.AsValue().AsBoolean();
        EFTAdyenResponseParser.TrySelectToken(JObject, 'ConfirmedFlag', JToken, true);
        EFTTransactionRequest."Confirmed Flag" := JToken.AsValue().AsBoolean();

        if EFTAdyenResponseParser.TrySelectToken(JObject, 'ResponseResult', JToken, true) then
            ResponseResult := JToken.AsValue().AsText();

        if ResponseResult = 'Failure' then
            EFTTransactionRequest.Successful := false;

        if not EFTTransactionRequest.Successful and (ResponseResult = 'Failure') then
            if TrySelectToken(JObject, 'ErrorCondition', JToken, false) and ((JToken.AsValue().AsText() = 'Cancel') or (JToken.AsValue().AsText() = 'Aborted')) then begin
                if (JToken.AsValue().AsText() = 'Cancel') then
                    EFTTransactionRequest."Result Display Text" := TerminalCanceledTrxLbl;
                if (JToken.AsValue().AsText() = 'Aborted') then
                    EFTTransactionRequest."Result Display Text" := ShopperAbortedTrxLbl;
                if JToken.AsValue().AsText() in ['Busy', 'InProgress'] then begin
                    EFTTransactionRequest."Result Code" := -10;
                end;
            end;

        EFTAdyenResponseParser.TrySelectToken(Jobject, 'PhoneNo', JToken, true);
        JToken.WriteTo(HelperTextVar);
        EFTTransactionRequest."Result Description" := CopyStr(HelperTextVar.TrimStart('"').TrimEnd('"'), 1, MaxStrLen(EFTTransactionRequest."Result Description"));

        EFTTransactionRequest."External Result Known" := true;
        EFTTransactionRequest."Auto Voidable" := true;
    end;

    local procedure ParseEMailAcquisition(Response: Text; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTAdyenResponseParser: Codeunit "NPR EFT Adyen Response Parser";
        ResponseResult: Text;
        HelperTextVar: Text;
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        JObject.ReadFrom(Response);

        EFTAdyenResponseParser.TrySelectToken(JObject, 'Success', JToken, true);
        EFTTransactionRequest.Successful := JToken.AsValue().AsBoolean();
        EFTAdyenResponseParser.TrySelectToken(JObject, 'ConfirmedFlag', JToken, true);
        EFTTransactionRequest."Confirmed Flag" := JToken.AsValue().AsBoolean();

        if EFTAdyenResponseParser.TrySelectToken(JObject, 'ResponseResult', JToken, true) then
            ResponseResult := JToken.AsValue().AsText();

        if ResponseResult = 'Failure' then
            EFTTransactionRequest.Successful := false;

        if not EFTTransactionRequest.Successful and (ResponseResult = 'Failure') then
            if TrySelectToken(JObject, 'ErrorCondition', JToken, false) and ((JToken.AsValue().AsText() = 'Cancel') or (JToken.AsValue().AsText() = 'Aborted')) then begin
                if (JToken.AsValue().AsText() = 'Cancel') then
                    EFTTransactionRequest."Result Display Text" := TerminalCanceledTrxLbl;
                if (JToken.AsValue().AsText() = 'Aborted') then
                    EFTTransactionRequest."Result Display Text" := ShopperAbortedTrxLbl;
                if JToken.AsValue().AsText() in ['Busy', 'InProgress'] then begin
                    EFTTransactionRequest."Result Code" := -10;
                end;
            end;

        EFTAdyenResponseParser.TrySelectToken(Jobject, 'EMail', JToken, true);
        JToken.WriteTo(HelperTextVar);
        EFTTransactionRequest."Result Description" := CopyStr(HelperTextVar.TrimStart('"').TrimEnd('"'), 1, MaxStrLen(EFTTransactionRequest."Result Description"));

        EFTTransactionRequest."External Result Known" := true;
        EFTTransactionRequest."Auto Voidable" := true;
    end;

    internal procedure PopulateCollectedInformation(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; var ReturnDataCollection: Record "NPR Return Data Collection")
    var
        OutStr: OutStream;
        InStr: InStream;
        SignatureText: Text;
    begin
        case EFTTransactionRequest."Auxiliary Operation ID" of
            Enum::"NPR EFT Adyen Aux Operation"::ACQUIRE_SIGNATURE.AsInteger():
                begin
                    EFTTransactionRequest.CalcFields("Signature Data");
                    EFTTransactionRequest."Signature Data".CreateInStream(InStr);
                    InStr.ReadText(SignatureText);
                    if SignatureText <> '""' then begin
                        ReturnDataCollection."Signature Data".CreateOutStream(OutStr);
                        OutStr.WriteText(SignatureText);
                    end;
                end;
            Enum::"NPR EFT Adyen Aux Operation"::ACQUIRE_PHONE_NO.AsInteger():
                begin
                    ReturnDataCollection."Phone No." := EFTTransactionRequest."Result Description";
                    PopulatePhoneNo(EFTTransactionRequest);
                end;
            Enum::"NPR EFT Adyen Aux Operation"::ACQUIRE_EMAIL.AsInteger():
                begin
                    ReturnDataCollection."E-Mail" := EFTTransactionRequest."Result Description";
                    PopulateEMail(EFTTransactionRequest);
                end;
        end;
    end;

    local procedure PopulatePhoneNo(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        SalePOS: Record "NPR POS Sale";
        Customer: Record Customer;
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
    begin
        if not ((EftTransactionRequest."Processing Type" = EftTransactionRequest."Processing Type"::AUXILIARY) and (EftTransactionRequest."Auxiliary Operation ID" = Enum::"NPR EFT Adyen Aux Operation"::ACQUIRE_PHONE_NO.AsInteger())) then
            exit;

        SalePOS.SetLoadFields("Customer No.");
        if not SalePOS.Get(EftTransactionRequest."Register No.", EftTransactionRequest."Sales Ticket No.") then
            exit;

        if SalePOS."Customer No." = '' then
            exit;

        Customer.SetLoadFields("Phone No.");
        if Customer.Get(SalePOS."Customer No.") then
            if Customer."Phone No." = '' then begin
                Customer."Phone No." := CopyStr(EftTransactionRequest."Result Description".TrimStart('"').TrimEnd('"'), 1, MaxStrLen(Customer."Phone No."));
                Customer.Modify();
            end;

        Membership.SetCurrentKey("Customer No.");
        Membership.SetRange("Customer No.", SalePOS."Customer No.");
        Membership.SetLoadFields("Entry No.");
        if not Membership.FindFirst() then
            exit;
        MembershipRole.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipRole.SetLoadFields("Member Entry No.");
        if MembershipRole.FindSet() then
            repeat
                Member.SetRange("Entry No.", MembershipRole."Member Entry No.");
                Member.ModifyAll("Phone No.", CopyStr(EftTransactionRequest."Result Description".TrimStart('"').TrimEnd('"'), 1, MaxStrLen(Customer."Phone No.")));
            until MembershipRole.Next() = 0;
    end;

    local procedure PopulateEMail(EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        SalePOS: Record "NPR POS Sale";
        Customer: Record Customer;
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
    begin
        if not ((EftTransactionRequest."Processing Type" = EftTransactionRequest."Processing Type"::AUXILIARY) and (EftTransactionRequest."Auxiliary Operation ID" = Enum::"NPR EFT Adyen Aux Operation"::ACQUIRE_EMAIL.AsInteger())) then
            exit;

        SalePOS.SetLoadFields("Customer No.");
        if not SalePOS.Get(EftTransactionRequest."Register No.", EftTransactionRequest."Sales Ticket No.") then
            exit;

        if SalePOS."Customer No." = '' then
            exit;

        Customer.SetLoadFields("E-Mail");
        if Customer.Get(SalePOS."Customer No.") then
            if Customer."E-Mail" = '' then begin
                Customer."E-Mail" := CopyStr(EftTransactionRequest."Result Description".TrimStart('"').TrimEnd('"'), 1, MaxStrLen(Customer."E-Mail"));
                Customer.Modify();
            end;

        Membership.SetCurrentKey("Customer No.");
        Membership.SetRange("Customer No.", SalePOS."Customer No.");
        Membership.SetLoadFields("Entry No.");
        if not Membership.FindFirst() then
            exit;
        MembershipRole.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipRole.SetLoadFields("Member Entry No.");
        if MembershipRole.FindSet() then
            repeat
                Member.SetRange("Entry No.", MembershipRole."Member Entry No.");
                Member.ModifyAll("E-Mail Address", CopyStr(EftTransactionRequest."Result Description".TrimStart('"').TrimEnd('"'), 1, MaxStrLen(Customer."E-Mail")));
            until MembershipRole.Next() = 0;
    end;

    local procedure HandleError(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; ErrorText: Text)
    begin
        EFTTransactionRequest.Successful := false;
        EFTTransactionRequest."External Result Known" := false; //Could not parse response correctly - needs to go to lookup.
        EFTTransactionRequest."Amount Output" := 0;
        EFTTransactionRequest."Result Amount" := 0;
        EFTTransactionRequest."NST Error" := CopyStr(ErrorText, 1, MaxStrLen(EFTTransactionRequest."NST Error"));
    end;


    internal procedure TrySelectToken(JObject: JsonObject; Path: Text; var JToken: JsonToken; WithError: Boolean): Boolean
    begin
        if WithError then begin
            JObject.SelectToken(Path, JToken);
        end else begin
            if not JObject.SelectToken(Path, JToken) then
                exit(false);
        end;
        exit(true);
    end;

    internal procedure TrySelectValue(JObject: JsonObject; Path: Text; var JValue: JsonValue; WithError: Boolean): Boolean
    var
        JToken: JsonToken;
    begin
        if WithError then begin
            JObject.SelectToken(Path, JToken);
            JValue := JToken.AsValue();
        end else begin
            if not JObject.SelectToken(Path, JToken) then
                exit(false);
            if not JToken.IsValue then
                exit(false);
            JValue := JToken.AsValue();
        end;
        exit(true);
    end;

    procedure SetResponseData(ResponseTypeIn: Enum "NPR EFT Adyen Response Type"; DataIn: Text; EntryNo: Integer)
    begin
        _ResponseType := ResponseTypeIn;
        _Data := DataIn;
        _EftTransactionEntryNo := EntryNo;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Payment Processing Events", 'OnAfterCalculateSuggestionPaymentAmount', '', false, false)]
    local procedure PaymentProcessingEventsOnAfterCalculateSuggestionPaymentAmount(SalesTicketNo: Code[20]; var SuggestPaymentAmount: Decimal; var CollectReturnInformation: Boolean)
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        ReturnInfoDeviceSetting: Record "NPR Return Info Device Setting";
        Customer: Record Customer;
        MMMemberInfoIntSetup: Record "NPR MM Member Info. Int. Setup";
        ReturnInfoCollectSetup: Record "NPR Return Info Collect Setup";
        CollectEMailPhoneNo: Boolean;
    begin
        SaleLinePOS.SetRange("Sales Ticket No.", SalesTicketNo);
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        SaleLinePOS.SetFilter(Amount, '<0');
        if SaleLinePOS.IsEmpty then
            exit;
        if not MMMemberInfoIntSetup.Get() then
            exit;
        if MMMemberInfoIntSetup."Request Return Info" = MMMemberInfoIntSetup."Request Return Info"::" " then
            exit;
        if not ReturnInfoCollectSetup.Get() then
            exit;
        if not (ReturnInfoCollectSetup."Collect Signature" or ReturnInfoCollectSetup."Collect Phone No." or ReturnInfoCollectSetup."Collect E-Mail") then
            exit;

        SalePOS.SetRange("Sales Ticket No.", SalesTicketNo);
        if not SalePOS.FindFirst() then
            exit;

        if not ReturnInfoDeviceSetting.Get(SalePOS."Register No.") then
            exit;
        if ReturnInfoDeviceSetting."Terminal ID" = '' then
            exit;

        if SalePOS."Customer No." = '' then
            CollectEMailPhoneNo := true;

        if Customer.Get(SalePOS."Customer No.") and ((Customer."Phone No." = '') or (Customer."E-Mail" = '')) then
            CollectEMailPhoneNo := true;

        if (not ReturnInfoCollectSetup."Collect Signature") and (not CollectEMailPhoneNo) then
            exit;

        CollectReturnInformation := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Create Entry", 'OnAfterInsertPOSEntry', '', false, false)]
    local procedure POSCreateEntryOnAfterInsertPOSEntry(var POSEntry: Record "NPR POS Entry")
    var
        ReturnDataCollection: Record "NPR Return Data Collection";
        POSCostumerInput: Record "NPR POS Costumer Input";
        SignatureText: Text;
        OutStr: OutStream;
        InStr: InStream;
    begin
        ReturnDataCollection.SetRange("Sales Ticket No.", POSEntry."Document No.");
        if ReturnDataCollection.IsEmpty() then
            exit;
        ReturnDataCollection.FindFirst();
        POSCostumerInput.Init();
        POSCostumerInput."POS Entry No." := POSEntry."Entry No.";
        POSCostumerInput."Date & Time" := CurrentDateTime;
        POSCostumerInput.Context := POSCostumerInput.Context::RETURN_INFORMATION;

        POSCostumerInput.Signature := ReturnDataCollection."Signature Data";
        ReturnDataCollection.CalcFields("Signature Data");
        ReturnDataCollection."Signature Data".CreateInStream(InStr);
        InStr.ReadText(SignatureText);
        POSCostumerInput.Signature.CreateOutStream(OutStr);
        OutStr.WriteText(SignatureText);

        POSCostumerInput."Phone Number" := ReturnDataCollection."Phone No.";
        POSCostumerInput."E-Mail" := CopyStr(ReturnDataCollection."E-Mail", 1, MaxStrLen(POSCostumerInput."E-Mail"));
        POSCostumerInput.Insert();
        ReturnDataCollection.Delete();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Entry", 'OnAfterDeleteEvent', '', false, false)]
    local procedure POSEntryOnAfterDeleteEvent(var Rec: Record "NPR POS Entry")
    var
        POSCostumerInput: Record "NPR POS Costumer Input";
    begin
        if not POSCostumerInput.Get(Rec."Entry No.") then
            exit;
        POSCostumerInput.Delete();
    end;
}
