codeunit 6184611 "NPR EFT Adyen Response Handler"
{
    Access = Internal;

    // Used for both adyen cloud and adyen local integration as the requests/responses are the same

    procedure ProcessResponse(RequestEntryNo: Integer; Response: Text; Completed: Boolean; Started: Boolean; ErrorText: Text)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.Get(RequestEntryNo);

        if Completed then begin
            case EFTTransactionRequest."Processing Type" of
                EFTTransactionRequest."Processing Type"::PAYMENT:
                    EndPaymentTransaction(EFTTransactionRequest, Response);
                EFTTransactionRequest."Processing Type"::REFUND:
                    EndRefundTransaction(EFTTransactionRequest, Response);
                EFTTransactionRequest."Processing Type"::SETUP:
                    EndSetupTerminal(EFTTransactionRequest, Response);
                EFTTransactionRequest."Processing Type"::VOID:
                    EndVoidTransaction(EFTTransactionRequest, Response);
                EFTTransactionRequest."Processing Type"::LOOK_UP:
                    EndLookupTransaction(EFTTransactionRequest, Response);
                EFTTransactionRequest."Processing Type"::AUXILIARY:
                    case EFTTransactionRequest."Auxiliary Operation ID" of
                        1:
                            EndAbortTransaction(EFTTransactionRequest);
                        2:
                            EndAcquireCard(EFTTransactionRequest, Response);
                        3:
                            EndAbortAcquireCard(EFTTransactionRequest);
                        4:
                            EndAcquireCard(EFTTransactionRequest, Response);
                        5:
                            EndAcquireCard(EFTTransactionRequest, Response);
                        6:
                            EndClearShopperContract(EFTTransactionRequest, Response);

                    end;
            end;
        end else begin
            EFTTransactionRequest."NST Error" := CopyStr(ErrorText, 1, MaxStrLen(EFTTransactionRequest."NST Error"));
            EFTTransactionRequest."External Result Known" := not Started;
            ProcessOriginalTrxAfterAcquireCardFailure(EFTTransactionRequest);
            HandleProtocolResponse(EFTTransactionRequest);
        end;
    end;

    local procedure EndPaymentTransaction(var EftTransactionRequest: Record "NPR EFT Transaction Request"; Response: Text)
    var
        EFTAdyenResponseParser: Codeunit "NPR EFT Adyen Response Parser";
        ParseError: Text;
        ParseSuccess: Boolean;
    begin
        EFTAdyenResponseParser.SetResponseData(Enum::"NPR EFT Adyen Response Type"::Payment, Response, EftTransactionRequest."Entry No.");
        ParseSuccess := EFTAdyenResponseParser.Run();

        if not ParseSuccess then begin
            ParseError := GetLastErrorText;
            EFTAdyenResponseParser.SetResponseData(Enum::"NPR EFT Adyen Response Type"::RejectNotification, Response, EftTransactionRequest."Entry No.");
            ParseSuccess := EFTAdyenResponseParser.Run();
        end;

        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EftTransactionRequest, ParseError);
            EftTransactionRequest.Modify();
        end;

        HandleProtocolResponse(EftTransactionRequest);
    end;

    local procedure EndRefundTransaction(var EftTransactionRequest: Record "NPR EFT Transaction Request"; Response: Text)
    var
        EFTAdyenResponseParser: Codeunit "NPR EFT Adyen Response Parser";
        ParseError: Text;
        ParseSuccess: Boolean;
    begin
        EFTAdyenResponseParser.SetResponseData(Enum::"NPR EFT Adyen Response Type"::Payment, Response, EftTransactionRequest."Entry No.");
        ParseSuccess := EFTAdyenResponseParser.Run();

        if not ParseSuccess then begin
            ParseError := GetLastErrorText;
            EFTAdyenResponseParser.SetResponseData(Enum::"NPR EFT Adyen Response Type"::RejectNotification, Response, EftTransactionRequest."Entry No.");
            ParseSuccess := EFTAdyenResponseParser.Run();
        end;

        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EftTransactionRequest, ParseError);
            EftTransactionRequest.Modify();
        end;

        HandleProtocolResponse(EftTransactionRequest);
    end;

    local procedure EndVoidTransaction(var EftTransactionRequest: Record "NPR EFT Transaction Request"; Response: Text)
    var
        EFTAdyenResponseParser: Codeunit "NPR EFT Adyen Response Parser";
        ParseError: Text;
        ParseSuccess: Boolean;
    begin
        EFTAdyenResponseParser.SetResponseData(Enum::"NPR EFT Adyen Response Type"::Void, Response, EftTransactionRequest."Entry No.");
        ParseSuccess := EFTAdyenResponseParser.Run();

        if not ParseSuccess then begin
            ParseError := GetLastErrorText;
            EFTAdyenResponseParser.SetResponseData(Enum::"NPR EFT Adyen Response Type"::RejectNotification, Response, EftTransactionRequest."Entry No.");
            ParseSuccess := EFTAdyenResponseParser.Run();
        end;

        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EftTransactionRequest, ParseError);
            EftTransactionRequest.Modify();
        end;

        HandleProtocolResponse(EftTransactionRequest);
    end;

    local procedure EndLookupTransaction(var EftTransactionRequest: Record "NPR EFT Transaction Request"; Response: Text)
    var
        EFTAdyenResponseParser: Codeunit "NPR EFT Adyen Response Parser";
        ParseError: Text;
        ParseSuccess: Boolean;
    begin
        EFTAdyenResponseParser.SetResponseData(Enum::"NPR EFT Adyen Response Type"::TransactionStatus, Response, EftTransactionRequest."Entry No.");
        ParseSuccess := EFTAdyenResponseParser.Run();

        if not ParseSuccess then begin
            ParseError := GetLastErrorText;
            EFTAdyenResponseParser.SetResponseData(Enum::"NPR EFT Adyen Response Type"::RejectNotification, Response, EftTransactionRequest."Entry No.");
            ParseSuccess := EFTAdyenResponseParser.Run();
        end;

        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EftTransactionRequest, ParseError);
            EftTransactionRequest.Modify();
        end;

        HandleProtocolResponse(EftTransactionRequest);
    end;


    local procedure EndSetupTerminal(var EftTransactionRequest: Record "NPR EFT Transaction Request"; Response: Text)
    var
        EFTAdyenResponseParser: Codeunit "NPR EFT Adyen Response Parser";
        ParseError: Text;
        ParseSuccess: Boolean;
    begin

        EFTAdyenResponseParser.SetResponseData(Enum::"NPR EFT Adyen Response Type"::Diagnose, Response, EftTransactionRequest."Entry No.");
        ParseSuccess := EFTAdyenResponseParser.Run();

        if not ParseSuccess then begin
            ParseError := GetLastErrorText;
            EFTAdyenResponseParser.SetResponseData(Enum::"NPR EFT Adyen Response Type"::RejectNotification, Response, EftTransactionRequest."Entry No.");
            ParseSuccess := EFTAdyenResponseParser.Run();
        end;

        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EftTransactionRequest, ParseError);
            EftTransactionRequest.Modify();
        end;

        HandleProtocolResponse(EftTransactionRequest);
    end;

    local procedure EndAbortTransaction(var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        EFTTransactionRequest."External Result Known" := true;
        EFTTransactionRequest.Successful := true;

        EFTTransactionRequest.Modify();
        HandleProtocolResponse(EFTTransactionRequest);
    end;

    local procedure EndAbortAcquireCard(var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    begin
        EFTTransactionRequest."External Result Known" := true;
        EFTTransactionRequest.Successful := true;

        EFTTransactionRequest.Modify();
        HandleProtocolResponse(EFTTransactionRequest);
    end;

    local procedure EndAcquireCard(var EftTransactionRequest: Record "NPR EFT Transaction Request"; Response: Text)
    var
        EFTAdyenResponseParser: Codeunit "NPR EFT Adyen Response Parser";
        ParseError: Text;
        ParseSuccess: Boolean;
    begin
        EFTAdyenResponseParser.SetResponseData(Enum::"NPR EFT Adyen Response Type"::CardAcquisition, Response, EftTransactionRequest."Entry No.");
        ParseSuccess := EFTAdyenResponseParser.Run();

        if not ParseSuccess then begin
            ParseError := GetLastErrorText;
            EFTAdyenResponseParser.SetResponseData(Enum::"NPR EFT Adyen Response Type"::RejectNotification, Response, EftTransactionRequest."Entry No.");
            ParseSuccess := EFTAdyenResponseParser.Run();
        end;

        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EftTransactionRequest, ParseError);
            EftTransactionRequest.Modify();
        end;

        HandleProtocolResponse(EftTransactionRequest);

        if (not EftTransactionRequest.Successful) then begin
            ProcessOriginalTrxAfterAcquireCardFailure(EftTransactionRequest);
        end;
    end;

    local procedure EndClearShopperContract(var EftTransactionRequest: Record "NPR EFT Transaction Request"; Response: Text)
    var
        EFTAdyenResponseParser: Codeunit "NPR EFT Adyen Response Parser";
        ParseSuccess: Boolean;
    begin
        EFTAdyenResponseParser.SetResponseData(Enum::"NPR EFT Adyen Response Type"::DisableContract, Response, EftTransactionRequest."Entry No.");
        ParseSuccess := EFTAdyenResponseParser.Run();

        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");

        if not ParseSuccess then begin
            HandleError(EftTransactionRequest, GetLastErrorText);
            EftTransactionRequest.Modify();
        end;

        HandleProtocolResponse(EftTransactionRequest);
    end;

    local procedure HandleError(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; ErrorText: Text)
    begin
        EFTTransactionRequest.Successful := false;
        EFTTransactionRequest."External Result Known" := false; //Could not parse response correctly - needs to go to lookup.
        EFTTransactionRequest."Amount Output" := 0;
        EFTTransactionRequest."Result Amount" := 0;
        EFTTransactionRequest."NST Error" := CopyStr(ErrorText, 1, MaxStrLen(EFTTransactionRequest."NST Error"));
    end;

    procedure ProcessOriginalTrxAfterAcquireCardFailure(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if not (EFTTransactionRequest."Auxiliary Operation ID" in [2, 3]) then
            exit;
        if (EFTTransactionRequest."Initiated from Entry No." = 0) then
            exit;
        if (EFTTransactionRequest."Processing Type" <> EFTTransactionRequest."Processing Type"::AUXILIARY) then
            exit;

        OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Initiated from Entry No.");
        OriginalEFTTransactionRequest."External Result Known" := true; //We know the primary transaction "failed correctly" since we never started it in the first place.
        OriginalEFTTransactionRequest.Recoverable := false; //Not recoverable since we never started it in the first place.
        OriginalEFTTransactionRequest."NST Error" := EFTTransactionRequest."NST Error";
        OriginalEFTTransactionRequest."Result Description" := EFTTransactionRequest."Result Description";
        OriginalEFTTransactionRequest."Result Display Text" := EFTTransactionRequest."Result Display Text";
        OriginalEFTTransactionRequest.Modify();
        HandleProtocolResponse(OriginalEFTTransactionRequest);
    end;

    procedure HandleProtocolResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTInterface: Codeunit "NPR EFT Interface";
    begin
        case EftTransactionRequest."Processing Type" of
            EftTransactionRequest."Processing Type"::PAYMENT,
          EftTransactionRequest."Processing Type"::REFUND,
          EftTransactionRequest."Processing Type"::LOOK_UP:
                HandleTrxResponse(EftTransactionRequest);

            EftTransactionRequest."Processing Type"::VOID:
                HandleVoidResponse(EftTransactionRequest);
        end;

        EFTInterface.EftIntegrationResponse(EftTransactionRequest);
    end;

#if BC17
    procedure GetResultMessage(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var Message: Text): Boolean
    begin
        Message := '';
        exit(false); //Messages crash control addin in BC17
    end;
#else
    procedure GetResultMessage(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var Message: Text): Boolean
    var
        TRX_ERROR: Label '%1 failed\%2\%3\%4';
        VOID_SUCCESS: Label 'Transaction %1 voided successfully';
    begin
        if EFTTransactionRequest.Successful then begin
            case EFTTransactionRequest."Processing Type" of
                EFTTransactionRequest."Processing Type"::VOID:
                    Message := StrSubstNo(VOID_SUCCESS, EftTransactionRequest."Entry No.");
                EFTTransactionRequest."Processing Type"::SETUP:
                    Message := StrSubstNo(EftTransactionRequest."Result Display Text");
            end;
        end else begin
            case EFTTransactionRequest."Processing Type" of
                EFTTransactionRequest."Processing Type"::SETUP,
                EFTTransactionRequest."Processing Type"::VOID,
                EFTTransactionRequest."Processing Type"::REFUND,
                EFTTransactionRequest."Processing Type"::PAYMENT:
                    Message := StrSubstNo(TRX_ERROR, Format(EFTTransactionRequest."Processing Type"), EFTTransactionRequest."Result Description", EFTTransactionRequest."Result Display Text", EFTTransactionRequest."NST Error");
                EFTTransactionRequest."Processing Type"::AUXILIARY:
                    case EFTTransactionRequest."Auxiliary Operation ID" of
                        2, 4, 5, 6:
                            Message := StrSubstNo(TRX_ERROR, Format(EftTransactionRequest."Auxiliary Operation Desc."), EftTransactionRequest."Result Description", EftTransactionRequest."Result Display Text", EftTransactionRequest."NST Error");
                    end;
            end;
        end;

        if Message <> '' then
            exit(true);
    end;
#endif         

    local procedure HandleTrxResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        EFTPaymentMapping: Codeunit "NPR EFT Payment Mapping";
    begin
        if EFTPaymentMapping.FindPaymentType(EftTransactionRequest, POSPaymentMethod) then begin
            EftTransactionRequest."POS Payment Type Code" := POSPaymentMethod.Code;
            EftTransactionRequest."Card Name" := CopyStr(POSPaymentMethod.Description, 1, MaxStrLen(EftTransactionRequest."Card Name"));
        end;
        EftTransactionRequest."POS Description" := CopyStr(GetPOSDescription(EftTransactionRequest), 1, MaxStrLen(EftTransactionRequest."POS Description"));
        EftTransactionRequest.Modify();
    end;

    local procedure HandleVoidResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        EFTPaymentMapping: Codeunit "NPR EFT Payment Mapping";
    begin
        if EftTransactionRequest.Successful then begin
            if EFTPaymentMapping.FindPaymentType(EftTransactionRequest, POSPaymentMethod) then begin
                EftTransactionRequest."POS Payment Type Code" := POSPaymentMethod.Code;
                EftTransactionRequest."Card Name" := CopyStr(POSPaymentMethod.Description, 1, MaxStrLen(EftTransactionRequest."Card Name"));
            end;
            EftTransactionRequest."POS Description" := CopyStr(GetPOSDescription(EftTransactionRequest), 1, MaxStrLen(EftTransactionRequest."POS Description"));
            EftTransactionRequest.Modify();

        end;
    end;

    procedure GetPOSDescription(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Text
    var
        POSDescriptionLbl: Label '%1: %2', Locked = true;
        UNKNOWN: Label 'Unknown Electronic Payment Type';
        CARD: Label 'Card: %1';
    begin
        if EFTTransactionRequest."Card Name" <> '' then begin
            if (StrLen(EFTTransactionRequest."Card Number") > 8) then
                exit(StrSubstNo(POSDescriptionLbl, EFTTransactionRequest."Card Name", CopyStr(EFTTransactionRequest."Card Number", StrLen(EFTTransactionRequest."Card Number") - 7)))
            else
                exit(StrSubstNo(EFTTransactionRequest."Card Name"));
        end;

        if EFTTransactionRequest."Stored Value Account Type" <> '' then
            exit(EFTTransactionRequest."Stored Value Account Type");

        if EFTTransactionRequest."Payment Instrument Type" <> '' then
            exit(EFTTransactionRequest."Payment Instrument Type");

        if EFTTransactionRequest."Card Number" <> '' then
            exit(StrSubstNo(CARD, EFTTransactionRequest."Card Number"));

        exit(UNKNOWN);
    end;
}