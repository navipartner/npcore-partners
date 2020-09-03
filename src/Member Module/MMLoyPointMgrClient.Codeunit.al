codeunit 6151160 "NPR MM Loy. Point Mgr (Client)"
{
    // MM1.38/TSA /20190204 CASE 338215 Initial Version
    // MM1.40/TSA /20190823 CASE 357360 Fixed a problem with short card numbers


    trigger OnRun()
    begin
    end;

    var
        NO_STORE_SETUP: Label 'Store %1, unit %2 - Loyalty store setup not found.';
        INVALID_XML: Label 'The returned XML is invalid:\\%1';
        TEXT_APPROVED: Label 'OK';
        TEXT_DECLINED: Label 'DECLINED';
        CUSTOMER_SIGNATURE: Label '(customer signature)';
        MERCHANT_COPY: Label '(merchant copy)';
        POINTS_EARNED: Label 'Points earned';
        POINTS_BURNED: Label 'Points spent';
        NEW_BALANCE: Label 'New balance';

    procedure PrepareServiceRequest(var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        LoyaltyStoreSetup: Record "NPR MM Loyalty Store Setup";
        LoyaltyEndpointClient: Record "NPR MM NPR Remote Endp. Setup";
        SoapAction: Text;
        ResponseMessage: Text;
        XmlRequest: Text;
        OStream: OutStream;
    begin

        GetStoreSetup(EFTTransactionRequest."Register No.", ResponseMessage, LoyaltyStoreSetup);
        LoyaltyEndpointClient.Get(LoyaltyStoreSetup."Store Endpoint Code");
        LoyaltyEndpointClient.TestField(Type, LoyaltyEndpointClient.Type::LoyaltyServices);

        if (TransformToSoapAction(EFTTransactionRequest, SoapAction, XmlRequest, ResponseMessage)) then begin
            EFTTransactionRequest.Successful := true;
            EFTTransactionRequest."Result Code" := 119;
            EFTTransactionRequest."Result Description" := 'Pending (Message Prepared)';
        end else begin
            EFTTransactionRequest.Successful := false;
            EFTTransactionRequest."Result Code" := -199;
            EFTTransactionRequest."Result Description" := 'Unsupported Process Type.';
        end;

        EFTTransactionRequest.Modify();
        EFTTransactionRequest.Get(EFTTransactionRequest."Entry No.");
    end;

    procedure MakeServiceRequest(var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        LoyaltyStoreSetup: Record "NPR MM Loyalty Store Setup";
        LoyaltyEndpointClient: Record "NPR MM NPR Remote Endp. Setup";
        EFTInterface: Codeunit "NPR EFT Interface";
        LoyaltyPointsWSClient: Codeunit "NPR MM Loy. Point WS (Client)";
        SoapAction: Text;
        ResponseMessage: Text;
        XmlRequest: Text;
        XmlRequestDoc: DotNet "NPRNetXmlDocument";
        XmlResponseDoc: DotNet "NPRNetXmlDocument";
        Success: Boolean;
    begin

        GetStoreSetup(EFTTransactionRequest."Register No.", ResponseMessage, LoyaltyStoreSetup);
        LoyaltyEndpointClient.Get(LoyaltyStoreSetup."Store Endpoint Code");
        LoyaltyEndpointClient.TestField(Type, LoyaltyEndpointClient.Type::LoyaltyServices);

        if (TransformToSoapAction(EFTTransactionRequest, SoapAction, XmlRequest, ResponseMessage)) then begin
            XmlRequestDoc := XmlRequestDoc.XmlDocument;
            XmlRequestDoc.LoadXml(XmlRequest);
            Success := LoyaltyPointsWSClient.WebServiceApi(LoyaltyEndpointClient, SoapAction, ResponseMessage, XmlRequestDoc, XmlResponseDoc);
            HandleWebServiceResult(EFTTransactionRequest, Success, ResponseMessage, XmlRequestDoc, XmlResponseDoc);

        end else begin
            EFTTransactionRequest.Successful := false;
            EFTTransactionRequest."Result Code" := -199;
            EFTTransactionRequest."Result Description" := 'Unsupported Process Type.';
            EFTTransactionRequest.Modify();
        end;

        EFTTransactionRequest.Get(EFTTransactionRequest."Entry No.");
    end;

    local procedure TransformToSoapAction(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; var SoapAction: Text; var XmlText: Text; var ResponseText: Text) TransformOk: Boolean
    var
        IStream: InStream;
        OStream: OutStream;
    begin

        TransformOk := false;

        with EFTTransactionRequest do
            case "Processing Type" of
                "Processing Type"::PAYMENT:
                    TransformOk := TransformToReservePoints(EFTTransactionRequest, SoapAction, XmlText, ResponseText);
                "Processing Type"::REFUND:
                    TransformOk := TransformToReservePoints(EFTTransactionRequest, SoapAction, XmlText, ResponseText);
                "Processing Type"::AUXILIARY:
                    case "Auxiliary Operation ID" of
                        1:
                            begin
                                if ((EFTTransactionRequest."Receipt 2".HasValue()) and ("Result Code" = 119)) then begin
                                    EFTTransactionRequest.CalcFields("Receipt 2");
                                    EFTTransactionRequest."Receipt 2".CreateInStream(IStream);
                                    IStream.Read(XmlText);
                                    SoapAction := 'RegisterReceipt';
                                    TransformOk := true;
                                end else begin
                                    TransformOk := TransformToRegisterReceipt(EFTTransactionRequest, SoapAction, XmlText, ResponseText);
                                    if (TransformOk) then begin
                                        EFTTransactionRequest."Receipt 2".CreateOutStream(OStream);
                                        OStream.Write(XmlText);
                                    end;
                                end;
                            end;
                    end;
                else
                    ResponseText := 'Processing type not supported.';
            end;

        exit(TransformOk);
    end;

    local procedure HandleWebServiceResult(EFTTransactionRequest: Record "NPR EFT Transaction Request"; ServiceSuccess: Boolean; ResponseMessage: Text; var XmlRequestDoc: DotNet "NPRNetXmlDocument"; var XmlResponseDoc: DotNet "NPRNetXmlDocument")
    var
        OStream: OutStream;
    begin

        if (not ServiceSuccess) then begin
            EFTTransactionRequest.Successful := false;
            EFTTransactionRequest."Result Code" := -198;
            EFTTransactionRequest."Result Description" := 'Webservice fault.';

            EFTTransactionRequest."Receipt 1".CreateOutStream(OStream);
            OStream.Write(XmlResponseDoc.InnerXml());
            EFTTransactionRequest.Modify();
            EFTTransactionRequest."Receipt 2".CreateOutStream(OStream);
            OStream.Write(XmlRequestDoc.InnerXml());

            EFTTransactionRequest.Modify();
            exit;
        end;

        with EFTTransactionRequest do
            case "Processing Type" of
                "Processing Type"::PAYMENT:
                    HandleReservePointsResult(EFTTransactionRequest, XmlResponseDoc);
                "Processing Type"::REFUND:
                    HandleReservePointsResult(EFTTransactionRequest, XmlResponseDoc);
                "Processing Type"::AUXILIARY:
                    case "Auxiliary Operation ID" of
                        1:
                            HandleRegisterSalesResult(EFTTransactionRequest, XmlResponseDoc);
                    end;
                else
                    ResponseMessage := 'Processing type not supported.';
            end;
    end;

    procedure ValidateServiceRequest(EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        ResponseMessage: Text;
        LoyaltyStoreSetup: Record "NPR MM Loyalty Store Setup";
        PaymentMethod: Record "NPR POS Payment Method";
    begin

        if (not GetStoreSetup(EFTTransactionRequest."Register No.", ResponseMessage, LoyaltyStoreSetup)) then begin
            EFTTransactionRequest.Successful := false;
            EFTTransactionRequest."Result Code" := -9150;
            EFTTransactionRequest."Result Description" := CopyStr(ResponseMessage, 1, MaxStrLen(EFTTransactionRequest."Result Description"));
            EFTTransactionRequest.Modify();
            exit(false);
        end;

        if (not LoyaltyStoreSetup."Accept Client Transactions") then begin
            EFTTransactionRequest.Successful := false;
            EFTTransactionRequest."Result Code" := -9152;
            EFTTransactionRequest."Result Description" := CopyStr('Not enabled.', 1, MaxStrLen(EFTTransactionRequest."Result Description"));
            EFTTransactionRequest.Modify();
            exit(false);
        end;

        LoyaltyStoreSetup.TestField("POS Payment Method Code");
        PaymentMethod.Get(LoyaltyStoreSetup."POS Payment Method Code");
        PaymentMethod.TestField("Currency Code");

        exit(true);
    end;

    local procedure "--RequestHandlers"()
    begin
    end;

    local procedure GetAuthorization(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; LoyaltyStoreSetup: Record "NPR MM Loyalty Store Setup"; var TmpTransactionAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary)
    begin

        with TmpTransactionAuthorization do begin
            "Entry No." := 1;
            "POS Store Code" := LoyaltyStoreSetup."Store Code";
            "POS Unit Code" := LoyaltyStoreSetup."Unit Code";
            "Authorization Code" := LoyaltyStoreSetup."Authorization Code";
            "Card Number" := EFTTransactionRequest."Card Number";
            "Reference Number" := EFTTransactionRequest."Sales Ticket No.";
            "Foreign Transaction Id" := EFTTransactionRequest.Token;
            "Transaction Date" := EFTTransactionRequest."Transaction Date";
            "Transaction Time" := EFTTransactionRequest."Transaction Time";
            "Company Name" := DATABASE.CompanyName;
            Insert();
        end;
    end;

    local procedure TransformToRegisterReceipt(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var SoapAction: Text; var XmlText: Text; var ResponseText: Text): Boolean
    var
        TmpTransactionAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        TmpRegisterPaymentLines: Record "NPR MM Reg. Sales Buffer" temporary;
        TmpRegisterSalesLines: Record "NPR MM Reg. Sales Buffer" temporary;
        LoyaltyStoreSetup: Record "NPR MM Loyalty Store Setup";
        SaleLinePOS: Record "NPR Sale Line POS";
        GeneralLedgerSetup: Record "General Ledger Setup";
        EFTTransactionRequest2: Record "NPR EFT Transaction Request";
        LoyaltyPointsPSPClient: Codeunit "NPR MM Loy. Point PSP (Client)";
    begin


        if (not GetStoreSetup(EFTTransactionRequest."Register No.", ResponseText, LoyaltyStoreSetup)) then
            exit(false);

        GetAuthorization(EFTTransactionRequest, LoyaltyStoreSetup, TmpTransactionAuthorization);
        GeneralLedgerSetup.Get();

        // Sales items are points rewarding
        with TmpRegisterSalesLines do begin
            SaleLinePOS.SetFilter("Sales Ticket No.", '=%1', EFTTransactionRequest."Sales Ticket No.");
            SaleLinePOS.SetFilter("Sale Type", '=%1', SaleLinePOS."Sale Type"::Sale);
            SaleLinePOS.SetFilter(Type, '=%1', SaleLinePOS.Type::Item);
            if (SaleLinePOS.FindFirst()) then begin
                repeat
                    "Entry No." := Count() + 1;
                    case (SaleLinePOS."Amount Including VAT" >= 0) of
                        true:
                            Type := Type::SALES;
                        false:
                            Type := Type::RETURN;
                    end;
                    "Item No." := SaleLinePOS."No.";
                    "Variant Code" := SaleLinePOS."Variant Code";
                    Description := SaleLinePOS.Description;
                    Quantity := SaleLinePOS.Quantity;
                    "Total Amount" := SaleLinePOS."Amount Including VAT";

                    if (SaleLinePOS."Currency Code" = '') then
                        SaleLinePOS."Currency Code" := GeneralLedgerSetup."LCY Code";
                    "Currency Code" := SaleLinePOS."Currency Code";

                    "Total Points" := EarnAmountToPoints(LoyaltyStoreSetup, "Currency Code", "Total Amount");

                    Insert();
                until (SaleLinePOS.Next() = 0);
            end
        end;

        EFTTransactionRequest2.SetFilter("Sales Ticket No.", '=%1', EFTTransactionRequest."Sales Ticket No.");
        EFTTransactionRequest2.SetFilter("Integration Type", '=%1', LoyaltyPointsPSPClient.IntegrationName());
        EFTTransactionRequest2.SetFilter("Processing Type", '=%1|%2', EFTTransactionRequest2."Processing Type"::PAYMENT, EFTTransactionRequest2."Processing Type"::REFUND);
        if (EFTTransactionRequest2.FindSet()) then begin
            repeat
                with TmpRegisterPaymentLines do begin
                    Init();
                    "Entry No." := Count() + 1;
                    case (EFTTransactionRequest2."Processing Type") of
                        EFTTransactionRequest2."Processing Type"::PAYMENT:
                            Type := Type::PAYMENT;
                        EFTTransactionRequest2."Processing Type"::REFUND:
                            Type := Type::REFUND;
                    end;
                    Description := EFTTransactionRequest2."POS Description";
                    "Authorization Code" := EFTTransactionRequest2."Authorisation Number";
                    "Currency Code" := EFTTransactionRequest2."Currency Code";
                    "Total Points" := EFTTransactionRequest2."Amount Output";
                    "Total Amount" := BurnPointsToAmount(LoyaltyStoreSetup, "Currency Code", EFTTransactionRequest2."Amount Output");
                    Insert();
                end;
            until (EFTTransactionRequest2.Next() = 0);
        end;

        SoapAction := 'RegisterReceipt';
        XmlText := CreateRegisterSaleSoapXml(TmpTransactionAuthorization, TmpRegisterSalesLines, TmpRegisterPaymentLines);
        exit(true);
    end;

    local procedure TransformToReservePoints(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var SoapAction: Text; var XmlText: Text; var ResponseText: Text): Boolean
    var
        TmpTransactionAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        TmpRegisterPaymentLines: Record "NPR MM Reg. Sales Buffer" temporary;
        LoyaltyStoreSetup: Record "NPR MM Loyalty Store Setup";
        SaleLinePOS: Record "NPR Sale Line POS";
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin

        if (not GetStoreSetup(EFTTransactionRequest."Register No.", ResponseText, LoyaltyStoreSetup)) then
            exit(false);

        GetAuthorization(EFTTransactionRequest, LoyaltyStoreSetup, TmpTransactionAuthorization);

        with TmpRegisterPaymentLines do begin
            "Entry No." := 1;
            case EFTTransactionRequest."Processing Type" of
                EFTTransactionRequest."Processing Type"::PAYMENT:
                    Type := Type::PAYMENT;
                EFTTransactionRequest."Processing Type"::REFUND:
                    Type := Type::REFUND;
                else
                    Type := Type::NA;
            end;
            "Currency Code" := EFTTransactionRequest."Currency Code";
            "Total Amount" := BurnPointsToAmount(LoyaltyStoreSetup, "Currency Code", EFTTransactionRequest."Amount Input");
            "Total Points" := EFTTransactionRequest."Amount Input";
            Description := CopyStr(EFTTransactionRequest."POS Description", 1, MaxStrLen(Description));
            Insert();
        end;

        SoapAction := 'reservePoints';
        XmlText := CreateReservePointsSoapXml(TmpTransactionAuthorization, TmpRegisterPaymentLines);
        exit(true);
    end;

    local procedure "--ResulHandlers"()
    begin
    end;

    local procedure HandleReservePointsResult(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var XmlResponseDoc: DotNet "NPRNetXmlDocument")
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlElement: DotNet NPRNetXmlElement;
        XmlPoints: DotNet NPRNetXmlElement;
        XmlResponseMessage: DotNet NPRNetXmlElement;
        OStream: OutStream;
        ResponseCode: Code[20];
        ResponseMessage: Text;
        MessageCode: Text;
        AuthorizationCode: Text;
        ReferenceNumber: Text;
        NewBalance: Text;
        ElementPath: Text;
        ReceiptText: Text;
    begin

        NpXmlDomMgt.RemoveNameSpaces(XmlResponseDoc);
        XmlElement := XmlResponseDoc.DocumentElement;
        if (IsNull(XmlElement)) then begin
            Error(StrSubstNo(INVALID_XML, NpXmlDomMgt.PrettyPrintXml(XmlResponseDoc.InnerXml())));
            exit;
        end;

        // Status
        ElementPath := '//Body/ReservePoints_Result/reservePoints/Response/';
        ResponseCode := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'Status/ResponseCode', 10, true);
        ResponseMessage := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'Status/ResponseMessage', 1000, true);

        NpXmlDomMgt.FindNode(XmlElement, '//Body/ReservePoints_Result/reservePoints/Response/Status/ResponseMessage', XmlResponseMessage);
        MessageCode := NpXmlDomMgt.GetXmlAttributeText(XmlResponseMessage, 'MessageCode', false);

        // Message payload
        NpXmlDomMgt.FindNode(XmlElement, '//Body/ReservePoints_Result/reservePoints/Response/Points', XmlPoints);
        ReferenceNumber := NpXmlDomMgt.GetXmlAttributeText(XmlPoints, 'ReferenceNumber', false);
        AuthorizationCode := NpXmlDomMgt.GetXmlAttributeText(XmlPoints, 'AuthorizationNumber', false);
        NewBalance := NpXmlDomMgt.GetXmlAttributeText(XmlPoints, 'NewPointBalance', false);

        EFTTransactionRequest.Successful := (ResponseCode = 'OK');
        FinalizeTransactionRequest(EFTTransactionRequest, MessageCode, ResponseMessage, AuthorizationCode, ReferenceNumber);
        EFTTransactionRequest.Modify();
        Commit;

        ReceiptText := CreateReservePointsSlip(EFTTransactionRequest, 0);
        EFTTransactionRequest."Receipt 1".CreateOutStream(OStream);
        OStream.Write(ReceiptText);

        if (EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::REFUND) then
            if (EFTTransactionRequest.Successful) then
                ReceiptText := CreateReservePointsSlip(EFTTransactionRequest, 1);

        EFTTransactionRequest."Receipt 2".CreateOutStream(OStream);
        OStream.Write(ReceiptText);

        EFTTransactionRequest.Modify();
    end;

    local procedure HandleRegisterSalesResult(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var XmlResponseDoc: DotNet "NPRNetXmlDocument")
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlElement: DotNet NPRNetXmlElement;
        XmlPoints: DotNet NPRNetXmlElement;
        XmlResponseMessage: DotNet NPRNetXmlElement;
        ResponseCode: Code[20];
        ResponseMessage: Text;
        MessageCode: Text;
        AuthorizationCode: Text;
        ReferenceNumber: Text;
        NumberAsText: Text;
        ElementPath: Text;
        NewBalance: Integer;
        PointsEarned: Integer;
        PointsSpent: Integer;
        ReceiptText: Text;
        OStream: OutStream;
    begin

        NpXmlDomMgt.RemoveNameSpaces(XmlResponseDoc);
        XmlElement := XmlResponseDoc.DocumentElement;
        if (IsNull(XmlElement)) then begin
            Error(StrSubstNo(INVALID_XML, NpXmlDomMgt.PrettyPrintXml(XmlResponseDoc.InnerXml())));
            exit;
        end;

        // Status
        ElementPath := '//Body/RegisterSale_Result/registerSale/Response/';
        ResponseCode := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'Status/ResponseCode', 10, true);
        ResponseMessage := NpXmlDomMgt.GetXmlText(XmlElement, ElementPath + 'Status/ResponseMessage', 1000, true);

        NpXmlDomMgt.FindNode(XmlElement, '//Body/RegisterSale_Result/registerSale/Response/Status/ResponseMessage', XmlResponseMessage);
        MessageCode := NpXmlDomMgt.GetXmlAttributeText(XmlResponseMessage, 'MessageCode', false);

        // Message payload
        NpXmlDomMgt.FindNode(XmlElement, '//Body/RegisterSale_Result/registerSale/Response/Points', XmlPoints);
        ReferenceNumber := NpXmlDomMgt.GetXmlAttributeText(XmlPoints, 'ReferenceNumber', false);
        AuthorizationCode := NpXmlDomMgt.GetXmlAttributeText(XmlPoints, 'AuthorizationNumber', false);

        EFTTransactionRequest.Successful := (ResponseCode = 'OK');
        FinalizeTransactionRequest(EFTTransactionRequest, MessageCode, ResponseMessage, AuthorizationCode, ReferenceNumber);
        EFTTransactionRequest.Modify();
        Commit;

        if (not EvaluateToInteger(PointsEarned, NpXmlDomMgt.GetXmlAttributeText(XmlPoints, 'PointsEarned', false))) then
            PointsEarned := 0;

        if (not EvaluateToInteger(PointsSpent, NpXmlDomMgt.GetXmlAttributeText(XmlPoints, 'PointsSpent', false))) then
            PointsSpent := 0;

        if (not EvaluateToInteger(NewBalance, NpXmlDomMgt.GetXmlAttributeText(XmlPoints, 'NewPointBalance', false))) then
            NewBalance := 0;

        ReceiptText := CreateRegisterPointsSlip(EFTTransactionRequest, 0, PointsEarned, PointsSpent, NewBalance);
        EFTTransactionRequest."Receipt 1".CreateOutStream(OStream);
        OStream.Write(ReceiptText);

        EFTTransactionRequest.Modify();
        Commit;
    end;

    local procedure FinalizeTransactionRequest(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; MessageCode: Text; ResponseMessage: Text; AuthorizationCode: Text; ReferenceNumber: Text)
    var
        OStream: OutStream;
        LoyaltyStoreSetup: Record "NPR MM Loyalty Store Setup";
        POSPaymentMethod: Record "NPR POS Payment Method";
        PaymentTypePOS: Record "NPR Payment Type POS";
    begin

        if (not EFTTransactionRequest.Successful) then begin
            if (not Evaluate(EFTTransactionRequest."Result Code", MessageCode)) then
                EFTTransactionRequest."Result Code" := -99;
            EFTTransactionRequest."Result Description" := TEXT_DECLINED;
            EFTTransactionRequest."Result Display Text" := TEXT_DECLINED;

            EFTTransactionRequest."Receipt 2".CreateOutStream(OStream);
            OStream.Write(ResponseMessage);
        end;

        if (EFTTransactionRequest.Successful) then begin

            GetStoreSetup(EFTTransactionRequest."Register No.", ResponseMessage, LoyaltyStoreSetup);
            if (not PaymentTypePOS.Get(LoyaltyStoreSetup."POS Payment Method Code", EFTTransactionRequest."Register No.")) then
                PaymentTypePOS.Get(LoyaltyStoreSetup."POS Payment Method Code");

            if (PaymentTypePOS."Fixed Rate" = 0) then
                PaymentTypePOS."Fixed Rate" := 100;

            EFTTransactionRequest."Result Code" := 10;
            EFTTransactionRequest."Result Description" := TEXT_APPROVED;
            EFTTransactionRequest."Result Display Text" := TEXT_APPROVED;

            EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Input" * PaymentTypePOS."Fixed Rate" / 100;
            EFTTransactionRequest."Amount Output" := EFTTransactionRequest."Amount Input";
            EFTTransactionRequest."Authorisation Number" := AuthorizationCode;
            EFTTransactionRequest."Reference Number Output" := ReferenceNumber;
        end;

        EFTTransactionRequest.Finished := CurrentDateTime();
        EFTTransactionRequest."Card Number" := StrSubstNo('%1%2',
                                               CopyStr('XXXXxxxxXXXXxxxxXXXXxxxx', 1, StrLen(EFTTransactionRequest."Card Number") - 2),
                                               CopyStr(EFTTransactionRequest."Card Number", StrLen(EFTTransactionRequest."Card Number") - 1));
    end;

    local procedure CreateReservePointsSlip(EFTTransactionRequest: Record "NPR EFT Transaction Request"; ReceiptType: Option CUSTOMER,MERCHANT) ReceiptText: Text
    var
        CreditCardTransaction: Record "NPR EFT Receipt";
        POSUnit: Record "NPR POS Unit";
        TicketWidth: Integer;
        Separator: Text;
        LastNChars: Integer;
    begin

        TicketWidth := 28;
        Separator := PadStr('', TicketWidth, '-');

        POSUnit.Get(EFTTransactionRequest."Register No.");
        CreditCardTransaction.SetFilter("Sales Ticket No.", '=%1', EFTTransactionRequest."Sales Ticket No.");
        if (CreditCardTransaction.FindLast()) then; // Prime entry number field

        CreditCardTransaction."Register No." := EFTTransactionRequest."Register No.";
        CreditCardTransaction."Sales Ticket No." := EFTTransactionRequest."Sales Ticket No.";
        CreditCardTransaction.Date := EFTTransactionRequest."Transaction Date";
        CreditCardTransaction."Transaction Time" := EFTTransactionRequest."Transaction Time";
        CreditCardTransaction."EFT Trans. Request Entry No." := EFTTransactionRequest."Entry No.";
        if (EFTTransactionRequest."Initiated from Entry No." <> 0) then
            CreditCardTransaction."EFT Trans. Request Entry No." := EFTTransactionRequest."Initiated from Entry No.";
        CreditCardTransaction."Receipt No." := ReceiptType;

        ReceiptText += WriteSlipLine(CreditCardTransaction, '');
        ReceiptText += WriteSlipLine(CreditCardTransaction, CenterText(TicketWidth, EFTTransactionRequest."Card Name"));
        ReceiptText += WriteSlipLine(CreditCardTransaction, '');
        ReceiptText += WriteSlipLine(CreditCardTransaction, Separator);

        ReceiptText += WriteSlipLine(CreditCardTransaction, LeftRightText(TicketWidth,
            Format(EFTTransactionRequest."Processing Type") + ' :',
            Format(EFTTransactionRequest."Amount Output")));

        ReceiptText += WriteSlipLine(CreditCardTransaction, '');

        //-MM1.40 [357360]
        // ReceiptText += WriteSlipLine (CreditCardTransaction, LeftRightText (TicketWidth,
        //    EFTTransactionRequest.FIELDCAPTION ("Card Number") +' :',
        //    COPYSTR (EFTTransactionRequest."Card Number", STRLEN(EFTTransactionRequest."Card Number")-7)));

        case StrLen(EFTTransactionRequest."Card Number") of
            1 .. 4:
                LastNChars := 1;
            5 .. 7:
                LastNChars := 3;
            8 .. 9:
                LastNChars := 5;
            else
                LastNChars := StrLen(EFTTransactionRequest."Card Number") - 7;
        end;

        if (StrLen(EFTTransactionRequest."Card Number") > 0) then
            ReceiptText += WriteSlipLine(CreditCardTransaction, LeftRightText(TicketWidth,
                EFTTransactionRequest.FieldCaption("Card Number") + ' :',
                CopyStr(EFTTransactionRequest."Card Number", LastNChars)));
        //+MM1.40 [357360]

        ReceiptText += WriteSlipLine(CreditCardTransaction, '');

        if (EFTTransactionRequest.Successful) then begin
            ReceiptText += WriteSlipLine(CreditCardTransaction, StrSubstNo('AID: ' + EFTTransactionRequest."Authorisation Number"));
            ReceiptText += WriteSlipLine(CreditCardTransaction, StrSubstNo('REF: ' + EFTTransactionRequest."Reference Number Output"));
            ReceiptText += WriteSlipLine(CreditCardTransaction, '');
            ReceiptText += WriteSlipLine(CreditCardTransaction, LeftRightText(TicketWidth,
              '****',
              TEXT_APPROVED));
        end;

        if (not EFTTransactionRequest.Successful) then begin
            ReceiptText += WriteSlipLine(CreditCardTransaction, LeftRightText(TicketWidth,
              '****',
              StrSubstNo('%1 (%2)', TEXT_DECLINED, EFTTransactionRequest."Result Code")));
        end;

        ReceiptText += WriteSlipLine(CreditCardTransaction, '');

        if (ReceiptType = ReceiptType::MERCHANT) then begin
            ReceiptText += WriteSlipLine(CreditCardTransaction, '');
            ReceiptText += WriteSlipLine(CreditCardTransaction, '');
            ReceiptText += WriteSlipLine(CreditCardTransaction, '');
            ReceiptText += WriteSlipLine(CreditCardTransaction, CenterText(TicketWidth, PadStr('', TicketWidth - 8, '_')));
            ReceiptText += WriteSlipLine(CreditCardTransaction, CenterText(TicketWidth, CUSTOMER_SIGNATURE));
            ReceiptText += WriteSlipLine(CreditCardTransaction, '');
        end;

        ReceiptText += WriteSlipLine(CreditCardTransaction, CenterText(TicketWidth,
            StrSubstNo('%1 %2',
              EFTTransactionRequest."Transaction Date",
              EFTTransactionRequest."Transaction Time")));

        ReceiptText += WriteSlipLine(CreditCardTransaction, CenterText(TicketWidth,
            StrSubstNo('%1 / %2 / %3',
              EFTTransactionRequest."Sales Ticket No.",
              POSUnit."POS Store Code",
              POSUnit."No.")));

        ReceiptText += WriteSlipLine(CreditCardTransaction, '');
        if (ReceiptType = ReceiptType::MERCHANT) then begin
            ReceiptText += WriteSlipLine(CreditCardTransaction, CenterText(TicketWidth, MERCHANT_COPY));
        end;

        ReceiptText += WriteSlipLine(CreditCardTransaction, '');
    end;

    local procedure CreateRegisterPointsSlip(EFTTransactionRequest: Record "NPR EFT Transaction Request"; ReceiptType: Option CUSTOMER,MERCHANT; PointsEarned: Integer; PointsBurned: Integer; NewBalance: Integer) ReceiptText: Text
    var
        CreditCardTransaction: Record "NPR EFT Receipt";
        POSUnit: Record "NPR POS Unit";
        TicketWidth: Integer;
        Separator: Text;
        LastNChars: Integer;
    begin

        TicketWidth := 28;
        Separator := PadStr('', TicketWidth, '-');

        POSUnit.Get(EFTTransactionRequest."Register No.");
        CreditCardTransaction.SetFilter("Sales Ticket No.", '=%1', EFTTransactionRequest."Sales Ticket No.");
        if (CreditCardTransaction.FindLast()) then; // Prime entry number field

        CreditCardTransaction."Register No." := EFTTransactionRequest."Register No.";
        CreditCardTransaction."Sales Ticket No." := EFTTransactionRequest."Sales Ticket No.";
        CreditCardTransaction.Date := EFTTransactionRequest."Transaction Date";
        CreditCardTransaction."Transaction Time" := EFTTransactionRequest."Transaction Time";
        CreditCardTransaction."EFT Trans. Request Entry No." := EFTTransactionRequest."Entry No.";
        if (EFTTransactionRequest."Initiated from Entry No." <> 0) then
            CreditCardTransaction."EFT Trans. Request Entry No." := EFTTransactionRequest."Initiated from Entry No.";
        CreditCardTransaction."Receipt No." := ReceiptType;

        ReceiptText += WriteSlipLine(CreditCardTransaction, '');
        ReceiptText += WriteSlipLine(CreditCardTransaction, CenterText(TicketWidth, EFTTransactionRequest."Card Name"));
        ReceiptText += WriteSlipLine(CreditCardTransaction, '');
        ReceiptText += WriteSlipLine(CreditCardTransaction, Separator);

        ReceiptText += WriteSlipLine(CreditCardTransaction, LeftRightText(TicketWidth, Format(EFTTransactionRequest."Auxiliary Operation Desc."), ''));
        ReceiptText += WriteSlipLine(CreditCardTransaction, LeftRightText(TicketWidth, POINTS_EARNED + ' :', Format(PointsEarned, 0, 9)));
        ReceiptText += WriteSlipLine(CreditCardTransaction, LeftRightText(TicketWidth, POINTS_BURNED + ' :', Format(PointsBurned, 0, 9)));
        ReceiptText += WriteSlipLine(CreditCardTransaction, LeftRightText(TicketWidth, NEW_BALANCE + ' :', Format(NewBalance, 0, 9)));
        ReceiptText += WriteSlipLine(CreditCardTransaction, '');

        if (not EFTTransactionRequest.Successful) then begin
            ReceiptText += WriteSlipLine(CreditCardTransaction, LeftRightText(TicketWidth,
              '****',
              StrSubstNo('(%1)', EFTTransactionRequest."Result Code")));
        end;

        //-MM1.40 [357360]
        // ReceiptText += WriteSlipLine (CreditCardTransaction, LeftRightText (TicketWidth,
        //    EFTTransactionRequest.FIELDCAPTION ("Card Number") +' :',
        //    COPYSTR (EFTTransactionRequest."Card Number", STRLEN(EFTTransactionRequest."Card Number")-7)));

        case StrLen(EFTTransactionRequest."Card Number") of
            1 .. 4:
                LastNChars := 1;
            5 .. 7:
                LastNChars := 3;
            8 .. 9:
                LastNChars := 5;
            else
                LastNChars := StrLen(EFTTransactionRequest."Card Number") - 7;
        end;

        if (StrLen(EFTTransactionRequest."Card Number") > 0) then
            ReceiptText += WriteSlipLine(CreditCardTransaction, LeftRightText(TicketWidth,
                EFTTransactionRequest.FieldCaption("Card Number") + ' :',
                CopyStr(EFTTransactionRequest."Card Number", LastNChars)));
        //+MM1.40 [357360]

        ReceiptText += WriteSlipLine(CreditCardTransaction, '');

        if (EFTTransactionRequest.Successful) then begin
            ReceiptText += WriteSlipLine(CreditCardTransaction, StrSubstNo('AID: ' + EFTTransactionRequest."Authorisation Number"));
            ReceiptText += WriteSlipLine(CreditCardTransaction, StrSubstNo('REF: ' + EFTTransactionRequest."Reference Number Output"));
            ReceiptText += WriteSlipLine(CreditCardTransaction, '');
        end;

        if (not EFTTransactionRequest.Successful) then begin

        end;

        ReceiptText += WriteSlipLine(CreditCardTransaction, '');

        ReceiptText += WriteSlipLine(CreditCardTransaction, CenterText(TicketWidth,
            StrSubstNo('%1 %2',
              EFTTransactionRequest."Transaction Date",
              EFTTransactionRequest."Transaction Time")));

        ReceiptText += WriteSlipLine(CreditCardTransaction, CenterText(TicketWidth,
            StrSubstNo('%1 / %2 / %3',
              EFTTransactionRequest."Sales Ticket No.",
              POSUnit."POS Store Code",
              POSUnit."No.")));

        ReceiptText += WriteSlipLine(CreditCardTransaction, '');
    end;

    local procedure WriteSlipLine(var CreditCardTransaction: Record "NPR EFT Receipt"; LineText: Text): Text
    var
        EntryNo: Integer;
        CRLF: Text[2];
    begin

        with CreditCardTransaction do begin
            EntryNo := "Entry No." + 1;

            Validate("Entry No.", EntryNo);
            Validate("Line No.", 0);
            Validate(Type, 0);
            Validate(Text, CopyStr(LineText, 1, MaxStrLen(Text)));
            Insert(true);
        end;

        CRLF[1] := 10;
        CRLF[2] := 13;
        exit(StrSubstNo('%1%2', LineText, CRLF));
    end;

    local procedure CenterText(Width: Integer; InText: Text) OutText: Text
    begin

        if (StrLen(InText) = 0) then
            exit(' ');

        InText := CopyStr(InText, 1, Width);

        OutText := StrSubstNo('%1%2',
          PadStr('', Round(Width / 2 - StrLen(InText) / 2, 1), ' '),
          CopyStr(InText, 1, Width));
    end;

    local procedure LeftRightText(Width: Integer; LeftText: Text; RightText: Text) OutText: Text
    begin

        if ((StrLen(LeftText) = 0) and (StrLen(RightText) = 0)) then
            exit(' ');

        if ((StrLen(LeftText) + StrLen(RightText)) > Width) then begin
            LeftText := CopyStr(LeftText, 1, Round(Width / 2, 1));
            RightText := CopyStr(RightText, 1, Round(Width / 2, 1));
        end;

        OutText := StrSubstNo('%1%2%3',
          LeftText,
          PadStr('', Round(Width - StrLen(LeftText) - StrLen(RightText), 1), ' '),
          RightText);
    end;

    local procedure "--Helpers"()
    begin
    end;

    local procedure EarnAmountToPoints(LoyaltyStoreSetup: Record "NPR MM Loyalty Store Setup"; CurrencyCode: Code[10]; Amount: Decimal) Points: Integer
    var
        LoyaltySetup: Record "NPR MM Loyalty Setup";
    begin

        LoyaltySetup.Get(LoyaltyStoreSetup."Loyalty Setup Code");

        Points := Round(Amount * LoyaltySetup."Amount Factor", 1);
    end;

    local procedure BurnPointsToAmount(LoyaltyStoreSetup: Record "NPR MM Loyalty Store Setup"; CurrencyCode: Code[10]; Points: Decimal) Amount: Decimal
    var
        PaymentMethod: Record "NPR POS Payment Method";
        PaymentTypePOS: Record "NPR Payment Type POS";
    begin

        PaymentTypePOS.Get(LoyaltyStoreSetup."POS Payment Method Code");

        Amount := Points * (PaymentTypePOS."Fixed Rate" / 100);
    end;

    procedure AssignLoyaltyInformation(var EFTTransactionRequest: Record "NPR EFT Transaction Request") CardInfo: Boolean
    var
        POSSalesInfo: Record "NPR MM POS Sales Info";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        LoyaltyStoreSetup: Record "NPR MM Loyalty Store Setup";
        POSPaymentMethod: Record "NPR POS Payment Method";
        ResponseMessage: Text;
    begin

        if not (GetStoreSetup(EFTTransactionRequest."Register No.", ResponseMessage, LoyaltyStoreSetup)) then
            exit(false);

        if (not LoyaltyStoreSetup."Accept Client Transactions") then
            exit(false);

        if (LoyaltyStoreSetup."POS Payment Method Code" = '') then
            exit(false);

        if (not POSPaymentMethod.Get(LoyaltyStoreSetup."POS Payment Method Code")) then
            exit(false);

        POSSalesInfo.SetFilter("Association Type", '=%1', POSSalesInfo."Association Type"::HEADER);
        POSSalesInfo.SetFilter("Receipt No.", '=%1', EFTTransactionRequest."Sales Ticket No.");

        CardInfo := POSSalesInfo.FindFirst();
        if (CardInfo) then begin
            EFTTransactionRequest."Card Number" := POSSalesInfo."Scanned Card Data";
            EFTTransactionRequest."Track Presence Input" := EFTTransactionRequest."Track Presence Input"::"Manually Entered";

            if (not Membership.Get(POSSalesInfo."Membership Entry No.")) then
                exit(false);

            if (not MembershipSetup.Get(Membership."Membership Code")) then
                exit(false);

            //  IF (NOT LoyaltySetup.GET (MembershipSetup."Loyalty Code")) THEN
            //    EXIT (FALSE);

            EFTTransactionRequest."Card Name" := CopyStr(LoyaltySetup.Description, 1, MaxStrLen(EFTTransactionRequest."Card Name"));
        end;

        EFTTransactionRequest."Currency Code" := POSPaymentMethod."Currency Code";

        exit(CardInfo);
    end;

    procedure GetStoreSetup(PosUnitNo: Code[10]; var ResponseText: Text; var LoyaltyStoreSetup: Record "NPR MM Loyalty Store Setup"): Boolean
    var
        POSUnit: Record "NPR POS Unit";
    begin

        POSUnit.Get(PosUnitNo);
        if (not LoyaltyStoreSetup.Get('', POSUnit."POS Store Code", PosUnitNo)) then
            if (not LoyaltyStoreSetup.Get('', POSUnit."POS Store Code", '')) then
                if (not LoyaltyStoreSetup.Get()) then begin
                    ResponseText := StrSubstNo(NO_STORE_SETUP, POSUnit."POS Store Code", PosUnitNo);
                    exit(false);
                end;

        exit(true);
    end;

    local procedure EvaluateToInteger(var AsInteger: Integer; NumberAsText: Text): Boolean
    begin

        if (NumberAsText = '') then
            NumberAsText := '0';

        exit(Evaluate(AsInteger, NumberAsText, 9));
    end;

    local procedure CreateAuthorizationSection(var TmpTransactionAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary) XmlText: Text
    begin

        XmlText :=
        '<Authorization>' +
          StrSubstNo('<PosCompanyName>%1</PosCompanyName>', TmpTransactionAuthorization."Company Name") +
          StrSubstNo('<PosStoreCode>%1</PosStoreCode>', TmpTransactionAuthorization."POS Store Code") +
          StrSubstNo('<PosUnitCode>%1</PosUnitCode>', TmpTransactionAuthorization."POS Unit Code") +
          StrSubstNo('<Token>%1</Token>', TmpTransactionAuthorization."Authorization Code") +
          StrSubstNo('<ClientCardNumber>%1</ClientCardNumber>', TmpTransactionAuthorization."Card Number") +
          StrSubstNo('<ReceiptNumber>%1</ReceiptNumber>', TmpTransactionAuthorization."Reference Number") +
          StrSubstNo('<TransactionId>%1</TransactionId>', TmpTransactionAuthorization."Foreign Transaction Id") +
          StrSubstNo('<Date>%1</Date>', Format(TmpTransactionAuthorization."Transaction Date", 0, 9)) +
          StrSubstNo('<Time>%1</Time>', Format(TmpTransactionAuthorization."Transaction Time", 0, 9)) +
        '</Authorization>';
    end;

    procedure CreateRegisterSalesEftTransaction(IntegrationName: Code[20]; SalePOS: Record "NPR Sale POS"; var EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    begin

        with EFTTransactionRequest do begin
            "Entry No." := 0;

            Token := CreateGuid();
            "User ID" := UserId();
            "Processing Type" := "Processing Type"::AUXILIARY;
            "Auxiliary Operation ID" := 1;
            "Auxiliary Operation Desc." := 'Register Receipt';

            "Integration Type" := IntegrationName;
            Started := CurrentDateTime();
            "User ID" := "User ID";
            "Sales Ticket No." := SalePOS."Sales Ticket No.";
            "Sales Line No." := 0;
            "Register No." := SalePOS."Register No.";
            "POS Payment Type Code" := '';
            "Result Code" := 0;

            "Transaction Date" := Today;
            "Transaction Time" := Time;
            Started := CurrentDateTime();
            if (not AssignLoyaltyInformation(EFTTransactionRequest)) then
                exit(false);

            "Reference Number Input" := Format("Entry No.", 0, 9);
            Insert(true);

        end;

        exit(true);
    end;

    procedure CreateRegisterSaleTestXml(var TmpTransactionAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; var TmpRegisterSaleLines: Record "NPR MM Reg. Sales Buffer" temporary; var TmpRegisterPaymentLines: Record "NPR MM Reg. Sales Buffer" temporary) XmlText: Text
    var
        XmlSalesLines: Text;
        XmlPaymentLines: Text;
    begin

        XmlText :=
        '<?xml version="1.0" encoding="UTF-8" standalone="no"?>' +
        '<RegisterSale xmlns="urn:microsoft-dynamics-nav/xmlports/x6151162">' +
          CreateRegisterSaleXml(TmpTransactionAuthorization, TmpRegisterSaleLines, TmpRegisterPaymentLines) +
        '</RegisterSale>';
    end;

    procedure CreateRegisterSaleSoapXml(var TmpTransactionAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; var TmpRegisterSaleLines: Record "NPR MM Reg. Sales Buffer" temporary; var TmpRegisterPaymentLines: Record "NPR MM Reg. Sales Buffer" temporary) XmlText: Text
    var
        XmlSalesLines: Text;
        XmlPaymentLines: Text;
    begin

        XmlText :=
        '<?xml version="1.0" encoding="UTF-8" standalone="no"?>' +
        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:loy="urn:microsoft-dynamics-schemas/codeunit/loyalty_services">' +
          '<soapenv:Header/>' +
          '<soapenv:Body>' +
            '<loy:RegisterSale>' +
              '<loy:registerSale>' +
        CreateRegisterSaleXml(TmpTransactionAuthorization, TmpRegisterSaleLines, TmpRegisterPaymentLines) +
              '</loy:registerSale>' +
            '</loy:RegisterSale>' +
          '</soapenv:Body>' +
        '</soapenv:Envelope>';
    end;

    local procedure CreateRegisterSaleXml(var TmpTransactionAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; var TmpRegisterSaleLines: Record "NPR MM Reg. Sales Buffer" temporary; var TmpRegisterPaymentLines: Record "NPR MM Reg. Sales Buffer" temporary) XmlText: Text
    var
        XmlSalesLines: Text;
        XmlPaymentLines: Text;
    begin

        TmpTransactionAuthorization.FindFirst();

        if (TmpRegisterSaleLines.FindSet()) then
            repeat
                XmlSalesLines += StrSubstNo('<Line Type="%1" ItemNumber="%2" VariantCode="%3" Quantity="%4" Description="%5" CurrencyCode="%6" Amount="%7" Points="%8"/>',
                  TmpRegisterSaleLines.Type,
                  TmpRegisterSaleLines."Item No.",
                  TmpRegisterSaleLines."Variant Code",
                  Format(TmpRegisterSaleLines.Quantity, 0, 9),
                  TmpRegisterSaleLines.Description,
                  TmpRegisterSaleLines."Currency Code",
                  Format(TmpRegisterSaleLines."Total Amount", 0, 9),
                  Format(TmpRegisterSaleLines."Total Points", 0, 9));
            until (TmpRegisterSaleLines.Next() = 0);

        if (TmpRegisterPaymentLines.FindSet()) then
            repeat
                XmlPaymentLines += StrSubstNo('<Line Type="%1" Description="%2" CurrencyCode="%3" Amount="%4" Points="%5" AuthorizationCode="%6"/>',
                  TmpRegisterPaymentLines.Type,
                  TmpRegisterPaymentLines.Description,
                  TmpRegisterPaymentLines."Currency Code",
                  Format(TmpRegisterPaymentLines."Total Amount", 0, 9),
                  Format(TmpRegisterPaymentLines."Total Points", 0, 9),
                  TmpRegisterPaymentLines."Authorization Code");
            until (TmpRegisterPaymentLines.Next() = 0);

        XmlText :=
        '<Request>' +
            CreateAuthorizationSection(TmpTransactionAuthorization) +
            '<Sales>' +
              XmlSalesLines +
            '</Sales>' +
            '<Payments>' +
              XmlPaymentLines +
            '</Payments>' +
        '</Request>';
    end;

    procedure CreateReservePointsTestXml(var TmpTransactionAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; var TmpRegisterPaymentLines: Record "NPR MM Reg. Sales Buffer" temporary) XmlText: Text
    var
        XmlReservationLines: Text;
    begin

        XmlText :=
        '<?xml version="1.0" encoding="UTF-8" standalone="no"?>' +
        '<ReservePoints  xmlns="urn:microsoft-dynamics-nav/xmlports/x6151163">' +
          CreateReservePointsXml(TmpTransactionAuthorization, TmpRegisterPaymentLines) +
        '</ReservePoints>';
    end;

    procedure CreateReservePointsSoapXml(var TmpTransactionAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; var TmpRegisterPaymentLines: Record "NPR MM Reg. Sales Buffer" temporary) XmlText: Text
    var
        XmlReservationLines: Text;
    begin

        XmlText :=
        '<?xml version="1.0" encoding="UTF-8" standalone="no"?>' +
        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:loy="urn:microsoft-dynamics-schemas/codeunit/loyalty_services">' +
          '<soapenv:Header/>' +
          '<soapenv:Body>' +
            '<loy:ReservePoints>' +
              '<loy:reservePoints>' +
        CreateReservePointsXml(TmpTransactionAuthorization, TmpRegisterPaymentLines) +
              '</loy:reservePoints>' +
            '</loy:ReservePoints>' +
          '</soapenv:Body>' +
        '</soapenv:Envelope>';
    end;

    local procedure CreateReservePointsXml(var TmpTransactionAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; var TmpRegisterPaymentLines: Record "NPR MM Reg. Sales Buffer" temporary) XmlText: Text
    var
        XmlReservationLines: Text;
    begin

        TmpTransactionAuthorization.FindFirst();

        if (TmpRegisterPaymentLines.FindSet()) then
            repeat
                XmlReservationLines += StrSubstNo('<Line Type="%1" Description="%2" CurrencyCode="%3" Amount="%4" Points="%5"/>',
                  Format(TmpRegisterPaymentLines.Type, 0, 9),
                  TmpRegisterPaymentLines.Description,
                  TmpRegisterPaymentLines."Currency Code",
                  Format(TmpRegisterPaymentLines."Total Amount", 0, 9),
                  Format(TmpRegisterPaymentLines."Total Points", 0, 9));
            until (TmpRegisterPaymentLines.Next() = 0);

        XmlText :=
        '<Request>' +
          CreateAuthorizationSection(TmpTransactionAuthorization) +
          '<Reservation>' +
            XmlReservationLines +
          '</Reservation>' +
        '</Request>';
    end;

    procedure CreateGetLoyaltyConfigurationSoapXml(var TmpTransactionAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary) XmlText: Text
    begin

        XmlText :=
        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:loy="urn:microsoft-dynamics-schemas/codeunit/loyalty_services" xmlns:x61="urn:microsoft-dynamics-nav/xmlports/x6151160">' +
           '<soapenv:Header/>' +
           '<soapenv:Body>' +
              '<loy:GetLoyaltyConfiguration>' +
                 '<loy:getLoyaltyConfiguration>' +
                 CreateGetLoyaltyConfigurationXml(TmpTransactionAuthorization) +
                 '</loy:getLoyaltyConfiguration>' +
              '</loy:GetLoyaltyConfiguration>' +
           '</soapenv:Body>' +
        '</soapenv:Envelope>';
    end;

    local procedure CreateGetLoyaltyConfigurationXml(var TmpTransactionAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary) XmlText: Text
    begin

        XmlText :=
        '<x61:Request>' +
          CreateAuthorizationSection(TmpTransactionAuthorization) +
        '</x61:Request>';
    end;
}

