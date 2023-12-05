codeunit 6150940 "NPR EFT Planet PAX Response"
{
    Access = Internal;

    var
        Util: Codeunit "NPR EFT Planet PAX Util.";


    [TryFunction]
    procedure HandleEftPaymentResponse(HttpXmlResponse: Text; var EftReq: Record "NPR EFT Transaction Request")
    var
        Xml: XmlDocument;
        ResultType: Text;
    begin
        ParseXmlResponse(HttpXmlResponse, Xml);
        ResponseCorrectFormat(Xml, ResultType);
        SetCommonXmlResponseToEFTRecord(Xml, ResultType, EftReq);
    end;

    [TryFunction]
    procedure HandleEftRefundResponse(HttpXmlResponse: Text; var EftReq: Record "NPR EFT Transaction Request")
    var
        Xml: XmlDocument;
        ResultType: Text;
    begin
        ParseXmlResponse(HttpXmlResponse, Xml);
        ResponseCorrectFormat(Xml, ResultType);
        SetCommonXmlResponseToEFTRecord(Xml, ResultType, EftReq);
    end;

    [TryFunction]
    procedure HandleEftLookupResponse(HttpXmlResponse: Text; var EftReq: Record "NPR EFT Transaction Request"; var OldEftReq: Record "NPR EFT Transaction Request")
    var
        Xml: XmlDocument;
        StillProcessLbl: Label 'The request is still processing.';
        ErrMsg: Text;
        ResultType: Text;
    begin
        ParseXmlResponse(HttpXmlResponse, Xml);
        ResponseCorrectFormat(Xml, ResultType);
        OldEftReq.Recovered := True;
        OldEftReq."External Result Known" := True;
        OldEftReq."Recovered by Entry No." := EftReq."Entry No.";
        case ResultType of
            '':
                begin
                    EftReq."Client Error" := CopyStr(StillProcessLbl, 1, 250);
                end;
            'A',
            'R':
                begin
                    SetCommonXmlResponseToEFTRecord(Xml, ResultType, EftReq);
                    OldEftReq.Successful := (ResultType = 'A');
                end;
            'E':
                begin
                    if ((Util.GetXmlNodeTxtValueOrDefault(Xml, '/Response/ResultReason', '') = 'XE') and
                        (OldEftReq."Result Description" = 'Aborted')) then begin
                        EftReq."Result Description" := 'Request was aborted';
                    end else begin
                        ErrMsg := Util.GetLabelText(Util.GetXmlNodeTxtValueOrDefault(Xml, '/Response/ResultReason', '', 250));
                        EftReq."Client Error" := CopyStr(ErrMsg, 1, 250);
                    end;
                end;
        end;
    end;

    [TryFunction]
    procedure HandleEftVoidResponse(HttpXmlResponse: Text; var EftReq: Record "NPR EFT Transaction Request"; var OldEftReq: Record "NPR EFT Transaction Request")
    var
        Xml: XmlDocument;
        ResultType: Text;
        ErrMsg: Text;
    begin
        ParseXmlResponse(HttpXmlResponse, Xml);
        ResponseCorrectFormat(Xml, ResultType);
        case ResultType of
            'A':
                begin
                    SetCommonXmlResponseToEFTRecord(Xml, ResultType, EftReq);
                    OldEftReq.Reversed := True;
                    OldEftReq."Reversed by Entry No." := EftReq."Entry No.";
                end;
            'R',
            'E':
                begin
                    EftReq."External Result Known" := True;
                    ErrMsg := Util.GetLabelText(Util.GetXmlNodeTxtValueOrDefault(Xml, '/Response/ResultReason', '', 250));
                    Message(Util.GetXmlNodeTxtValueOrDefault(Xml, '/Response/ResultReason', '') + ': ' + Util.GetXmlNodeTxtValueOrDefault(xml, '/Response/Message', ''));
                    EftReq."Client Error" := CopyStr(ErrMsg, 1, 250);
                end;
        end;
    end;

    [TryFunction]
    procedure HandleAbortResponse(HttpXmlResponse: Text; var ResultStatus: Enum "NPR EFT Planet PAX Status")
    var
        Xml: XmlDocument;
        ResultType: Text;
    begin
        ParseXmlResponse(HttpXmlResponse, Xml);
        ResponseCorrectFormat(Xml, ResultType);
        case ResultType of
            'A':
                begin
                    ResultStatus := "NPR EFT Planet PAX Status"::Success;
                    exit;
                end;
            'R',
            'E':
                begin
                    ResultStatus := "NPR EFT Planet PAX Status"::Failed;
                    exit;
                end;
        end;
        ResultStatus := "NPR EFT Planet PAX Status"::Error;
    end;

    local procedure ResponseCorrectFormat(Xml: XmlDocument; var Result: Text)
    var
        Element: XmlElement;
        ResultValue: Text;
        InvalidLbl: Label 'The Result value field is invalid.';
    begin
        Util.SelectSingleElement(Xml, '/Response/Result', Element);
        ResultValue := Element.InnerText().ToUpper();
        if (not (StrLen(ResultValue) in [0 .. 1])) then Error(InvalidLbl);
        case ResultValue of
            'A': //Accepted
                Result := 'A';
            'R': //Rejected
                Result := 'R';
            'W': //Warning
                Result := 'W';
            'E': //Error
                Result := 'E';
            '': // Still processing (Lookup only)
                Result := '';
            else
                Error(InvalidLbl);
        end;
    end;
    /// <summary>
    /// Checks if the content of the HTTP Request is xml, and if it contains the error definition of 3cXml
    /// xml will be the parsed document, and ErrorOccoured, will determine if there was an error in the 3cXml.
    /// </summary>
    local procedure ParseXmlResponse(HttpXmlResponse: Text; var xml: XmlDocument)
    begin
        XmlDocument.ReadFrom(HttpXmlResponse, xml);
        if (Util.GetXmlNodeTxtValueOrDefault(xml, '/Response/@Type', '') = 'Error') then
            Error(Get3cXmlErrorCodeAndMsg(xml));
    end;
    /// <summary>
    /// /// In case the application receives a request which cannot be parsed an error message will be sent back to the
    ///requester. This can also be done in case there is an internal application error not foreseen. The error code
    ///and message field give information about the type of error.
    /// </summary>
    local procedure Get3cXmlErrorCodeAndMsg(Xml: XmlDocument): Text
    var
        ErrCode: Text;
        ErrMsg: Text;
    begin
        ErrCode := Util.GetXmlNodeTxtValueOrDefault(Xml, '/Response/ErrorCode', 'No Error Code provided');
        ErrMsg := Util.GetXmlNodeTxtValueOrDefault(Xml, '/Response/Message', 'No Message provided');
        exit(ErrCode + ': ' + ErrMsg);
    end;

    local procedure SetCommonXmlResponseToEFTRecord(Xml: XmlDocument; ResultType: Text; var EftReq: Record "NPR EFT Transaction Request")
    var
        EFTPaymentMapping: Codeunit "NPR EFT Payment Mapping";
        POSPaymentMethod: Record "NPR POS Payment Method";
        MerchantReceipt: Text;
        CustomerReceipt: Text;
        Out: OutStream;
    begin
        EftReq."Card Application ID" := CopyStr(Util.GetXmlNodeTxtValueOrDefault(Xml, '/Response/EmvApplicationId', ''), 1, 30);
        EftReq."Card Name" := CopyStr(Util.GetXmlNodeTxtValueOrDefault(Xml, '/Response/CardSchemeName', ''), 1, 24);
        EftReq."Card Number" := CopyStr(Util.GetXmlNodeTxtValueOrDefault(Xml, '/Response/CardNumber', ''), 1, 30);
        EftReq."External Transaction ID" := CopyStr(Util.GetXmlNodeTxtValueOrDefault(Xml, '/Response/TransRefNum', ''), 1, 50);
        EftReq."Result Description" := CopyStr(Util.GetXmlNodeTxtValueOrDefault(Xml, '/Response/Message', ''), 1, 50);
        MerchantReceipt := Util.GetXmlNodeTxtValueOrDefault(Xml, '/Response/PrintData1', '');
        CustomerReceipt := Util.GetXmlNodeTxtValueOrDefault(Xml, '/Response/PrintData2', '');
        //Check if signature is required. IF so use this to display Message to Merchant.
        if (Util.GetXmlNodeTxtValueOrDefault(Xml, '/Response/SignatureRequired', 'N') = 'Y') then begin
            EftReq."Signature Type" := EftReq."Signature Type"::"On Receipt";
        end else begin
            EftReq."Signature Type" := EftReq."Signature Type"::" ";
        end;
        if (Util.GetXmlNodeTxtValueOrDefault(Xml, '/Response/DCCFlag', 'N') = 'Y') then begin
            EftReq."DCC Used" := True;
            EftReq."DCC Currency Code" := CopyStr(Util.GetXmlNodeTxtValueOrDefault(Xml, '/Response/CurrencyUsed', ''), 1, 10);
            EftReq."DCC Amount" := Util.GetXmlNodeTxtValueOrDefault(Xml, '/Response/AmountUsed', 0.0);
            EftReq."Amount Output" := Util.GetXmlNodeTxtValueOrDefault(Xml, '/Response/LocalAmount', 0.0);
            EftReq."Currency Code" := CopyStr(Util.GetXmlNodeTxtValueOrDefault(Xml, '/Response/LocalCurrency', ''), 1, 10);
        end else begin
            EftReq."Amount Output" := Util.GetXmlNodeTxtValueOrDefault(Xml, '/Response/AmountUsed', 0.0);
            EftReq."Currency Code" := CopyStr(Util.GetXmlNodeTxtValueOrDefault(Xml, '/Response/CurrencyUsed', ''), 1, 10);
        end;
        if (CustomerReceipt <> '') then begin
            EftReq."Receipt 1".CreateOutStream(Out);
            Out.WriteText(CustomerReceipt);
            Clear(Out);
        end;
        if ((MerchantReceipt <> '') and (EftReq."Signature Type" = EftReq."Signature Type"::"On Receipt")) then begin
            EftReq."Receipt 2".CreateOutStream(Out);
            Out.WriteText(MerchantReceipt);
        end;

        case ResultType of
            'A': //Accepted
                begin
                    EftReq."Result Amount" := EftReq."Amount Output";
                    if ((EftReq."Processing Type" = EftReq."Processing Type"::REFUND) or
                        ((EftReq."Processing Type" = EftReq."Processing Type"::VOID) and (EftReq."Amount Input" < 0))) then begin
                        EftReq."Result Amount" := EftReq."Result Amount" * -1;
                    end;
                    EftReq."Result Description" := 'Accepted';
                    EftReq.Successful := True;
                    EftReq."External Result Known" := True;
                    EftReq."POS Description" := GetPOSDescription(EftReq, true);
                end;
            'E', //Error
            'R', //Rejected
            'W': //Warning, considered as rejected
                begin
                    if ('E' = ResultType) then
                        EftReq."Result Description" := 'Error';
                    if ('R' = ResultType) then
                        EftReq."Result Description" := 'Rejected';
                    if ('W' = ResultType) then
                        EftReq."Result Description" := 'Warning';
                    if (Util.GetXmlNodeTxtValueOrDefault(Xml, '/Response/ResultReason', '') = 'TC') then
                        Message('Aborted on Terminal');
                    EftReq."Result Amount" := 0.0;
                    EftReq."Client Error" := CopyStr(Util.GetLabelText(Util.GetXmlNodeTxtValueOrDefault(Xml, '/Response/ResultReason', '')), 1, 250);
                    EftReq."POS Description" := GetPOSDescription(EftReq, False);
                    EftReq."External Result Known" := True;
                end;
        end;
        if EFTPaymentMapping.FindPaymentType(EftReq, POSPaymentMethod) then begin
            EftReq."POS Payment Type Code" := POSPaymentMethod.Code;
            EftReq."Card Name" := CopyStr(POSPaymentMethod.Description, 1, MaxStrLen(EftReq."Card Name"));
        end;
        //DebugForceFlow(xml, ResultType, EftReq);
    end;

    //TODO: REMEMBER TO REMOVE/COMMENT OUT WHEN RELEASEING
    /*local procedure DebugForceFlow(xml: XmlDocument; ResultType: Text; var EftReq: Record "NPR EFT Transaction Request")
    var
        merchantReceipt: Text;
        out: OutStream;
    begin
        //Simulate signature response.
        if (EftReq."Amount Input" = -15.05) then begin
            EftReq."Signature Type" := EftReq."Signature Type"::"On Receipt";
            merchantReceipt := Util.GetXmlNodeTxtValueOrDefault(xml, '/Response/PrintData1', '');
            if ((merchantReceipt <> '')) then begin
                EftReq."Receipt 2".CreateOutStream(out);
                out.WriteText(merchantReceipt);
            end;
        end
    end;*/

    local procedure GetPOSDescription(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; Succeeded: Boolean): Text[100]
    var
        PosLineLbl: Label 'PlanetPax %1 %2', Locked = true;
        PosOpPay: Label 'Payment';
        PosOpRef: Label 'Refund';
        PosOpVoid: Label 'Cancel';
        CardUnknownLbl: Label 'Unknown Card';
        PosOpLbl: Text;
        CardInfo: Text;
        EftR: Record "NPR EFT Transaction Request";
    begin
        if (EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::LOOK_UP) then
            EftR.Get(EFTTransactionRequest."Processed Entry No.")
        else
            EftR.Get(EFTTransactionRequest."Entry No.");

        case EftR."Processing Type" of
            EftR."Processing Type"::PAYMENT:
                PosOpLbl := PosOpPay;
            EftR."Processing Type"::REFUND:
                PosOpLbl := PosOpRef;
            EftR."Processing Type"::VOID:
                PosOpLbl := PosOpVoid;
            else
                exit('');
        end;

        if EFTTransactionRequest."Card Name" <> '' then
            CardInfo := CopyStr(EFTTransactionRequest."Card Name", 1, 15)
        else
            CardInfo := CardUnknownLbl;

        if (StrLen(EFTTransactionRequest."Card Number") > 8) then
            CardInfo := CardInfo + ': ' + CopyStr(EFTTransactionRequest."Card Number", StrLen(EFTTransactionRequest."Card Number") - 7);

        if (Succeeded) then begin
            exit(CopyStr(StrSubstNo(PosLineLbl, PosOpLbl, CardInfo), 1, 100));
        end else begin
            exit(CopyStr((StrSubstNo(PosLineLbl, PosOpLbl, CardInfo) + ' ' + EFTTransactionRequest."Client Error"), 1, 100));
        end;
    end;

    // HANDLE RECEIPT STUFF:

    procedure ParseTransactionReceipts(var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        ReceiptNo: Integer;
        EntryNo: Integer;
        InStream: InStream;
    begin
        ReceiptNo := GetLastReceiptNo(EFTTransactionRequest);
        EntryNo := GetLastReceiptLineEntryNo(EFTTransactionRequest);

        //customerReceipt
        if (EFTTransactionRequest."Receipt 1".HasValue()) then begin
            EFTTransactionRequest."Receipt 1".CreateInStream(InStream, TextEncoding::UTF8);
            ParseReceipt(EFTTransactionRequest, ReceiptNo, EntryNo, InStream);
            Clear(InStream);
        end;

        //merchantReceipt
        if (EFTTransactionRequest."Receipt 2".HasValue()) then begin
            EFTTransactionRequest."Receipt 2".CreateInStream(InStream, TextEncoding::UTF8);
            ParseReceipt(EFTTransactionRequest, ReceiptNo + 1, EntryNo, InStream);
            Clear(InStream);
        end;
    end;

    local procedure ParseReceipt(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; LastReceiptNo: Integer; var LastReceiptEntryNo: Integer; var InStream: InStream)
    var
        DotNetStreamReader: Codeunit DotNet_StreamReader;
        DotNetEncoding: Codeunit DotNet_Encoding;
        ReceiptLine: Text;
    begin
        DotNetEncoding.UTF8();
        DotNetStreamReader.StreamReader(InStream, DotNetEncoding);
        while (not DotNetStreamReader.EndOfStream()) do begin
            LastReceiptEntryNo += 1;
            ReceiptLine := DotNetStreamReader.ReadLine();
            InsertReceiptLine(ReceiptLine, LastReceiptNo, LastReceiptEntryNo, EFTTransactionRequest);
        end;

    end;

    local procedure InsertReceiptLine(Line: Text; ReceiptNo: Integer; EntryNo: Integer; EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        CreditCardTransaction: Record "NPR EFT Receipt";
    begin
        CreditCardTransaction.Init();
        CreditCardTransaction.Date := Today();
        CreditCardTransaction."Transaction Time" := Time;
        CreditCardTransaction."Register No." := EFTTransactionRequest."Register No.";
        CreditCardTransaction."Sales Ticket No." := EFTTransactionRequest."Sales Ticket No.";
        CreditCardTransaction."EFT Trans. Request Entry No." := EFTTransactionRequest."Entry No.";
        CreditCardTransaction."Receipt No." := ReceiptNo;
        CreditCardTransaction.Text := CopyStr(Line, 1, MaxStrLen(CreditCardTransaction.Text));
        CreditCardTransaction."Entry No." := EntryNo;
        CreditCardTransaction.Insert();
    end;

    local procedure GetLastReceiptNo(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Integer
    var
        CreditCardTransaction: Record "NPR EFT Receipt";
    begin
        CreditCardTransaction.SetRange("Register No.", EFTTransactionRequest."Register No.");
        CreditCardTransaction.SetRange("Sales Ticket No.", EFTTransactionRequest."Sales Ticket No.");
        if (CreditCardTransaction.FindLast()) then;
        exit(CreditCardTransaction."Receipt No.");
    end;

    local procedure GetLastReceiptLineEntryNo(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Integer
    var
        CreditCardTransaction: Record "NPR EFT Receipt";
    begin
        CreditCardTransaction.SetRange("Register No.", EFTTransactionRequest."Register No.");
        CreditCardTransaction.SetRange("Sales Ticket No.", EFTTransactionRequest."Sales Ticket No.");
        if (CreditCardTransaction.FindLast()) then;
        exit(CreditCardTransaction."Entry No.");
    end;



}