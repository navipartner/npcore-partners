codeunit 6151160 "NPR MM Loy. Point Mgr (Client)"
{

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
        ForeignMembership: Codeunit "NPR MM NPR Membership";
        SoapAction: Text;
        ResponseMessage: Text;
        XmlRequest: Text;
        XmlRequestDoc: XmlDocument;
        XmlResponseDoc: XmlDocument;
        Success: Boolean;
    begin

        GetStoreSetup(EFTTransactionRequest."Register No.", ResponseMessage, LoyaltyStoreSetup);
        LoyaltyEndpointClient.Get(LoyaltyStoreSetup."Store Endpoint Code");
        LoyaltyEndpointClient.TestField(Type, LoyaltyEndpointClient.Type::LoyaltyServices);

        if (TransformToSoapAction(EFTTransactionRequest, SoapAction, XmlRequest, ResponseMessage)) then begin
            XmlDocument.ReadFrom(XmlRequest, XmlRequestDoc);
            Success := ForeignMembership.WebServiceApi(LoyaltyEndpointClient, SoapAction, ResponseMessage, XmlRequestDoc, XmlResponseDoc);
            HandleWebServiceResult(EFTTransactionRequest, Success, ResponseMessage, XmlResponseDoc);

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

        case EFTTransactionRequest."Processing Type" of
            EFTTransactionRequest."Processing Type"::PAYMENT:
                TransformOk := TransformToReservePoints(EFTTransactionRequest, SoapAction, XmlText, ResponseText);
            EFTTransactionRequest."Processing Type"::REFUND:
                TransformOk := TransformToReservePoints(EFTTransactionRequest, SoapAction, XmlText, ResponseText);
            EFTTransactionRequest."Processing Type"::AUXILIARY:
                case EFTTransactionRequest."Auxiliary Operation ID" of
                    1:
                        begin
                            if ((EFTTransactionRequest."Receipt 2".HasValue()) and (EFTTransactionRequest."Result Code" = 119)) then begin
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

    local procedure HandleWebServiceResult(EFTTransactionRequest: Record "NPR EFT Transaction Request"; ServiceSuccess: Boolean; ResponseMessage: Text; var XmlResponseDoc: XmlDocument)
    var
        OStream: OutStream;
    begin

        if (not ServiceSuccess) then begin
            EFTTransactionRequest.Successful := false;
            EFTTransactionRequest."Result Code" := -198;
            EFTTransactionRequest."Result Description" := 'WebService fault.';

            EFTTransactionRequest."Receipt 1".CreateOutStream(OStream);
            XmlResponseDoc.WriteTo(OStream);
            EFTTransactionRequest.Modify();
            EFTTransactionRequest."Receipt 2".CreateOutStream(OStream);
            XmlResponseDoc.WriteTo(OStream);

            EFTTransactionRequest.Modify();
            exit;
        end;

        case EFTTransactionRequest."Processing Type" of
            EFTTransactionRequest."Processing Type"::PAYMENT:
                HandleReservePointsResult(EFTTransactionRequest, XmlResponseDoc);
            EFTTransactionRequest."Processing Type"::REFUND:
                HandleReservePointsResult(EFTTransactionRequest, XmlResponseDoc);
            EFTTransactionRequest."Processing Type"::AUXILIARY:
                case EFTTransactionRequest."Auxiliary Operation ID" of
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

    local procedure GetAuthorization(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; LoyaltyStoreSetup: Record "NPR MM Loyalty Store Setup"; var TmpTransactionAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary)
    begin

        TmpTransactionAuthorization."Entry No." := 1;
        TmpTransactionAuthorization."POS Store Code" := LoyaltyStoreSetup."Store Code";
        TmpTransactionAuthorization."POS Unit Code" := LoyaltyStoreSetup."Unit Code";
        TmpTransactionAuthorization."Authorization Code" := LoyaltyStoreSetup."Authorization Code";
        TmpTransactionAuthorization."Card Number" := EFTTransactionRequest."Card Number";
        TmpTransactionAuthorization."Reference Number" := EFTTransactionRequest."Sales Ticket No.";
        TmpTransactionAuthorization."Foreign Transaction Id" := EFTTransactionRequest.Token;
        TmpTransactionAuthorization."Transaction Date" := EFTTransactionRequest."Transaction Date";
        TmpTransactionAuthorization."Transaction Time" := EFTTransactionRequest."Transaction Time";
        TmpTransactionAuthorization."Company Name" := DATABASE.CompanyName;
        TmpTransactionAuthorization.Insert();
    end;

    local procedure TransformToRegisterReceipt(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var SoapAction: Text; var XmlText: Text; var ResponseText: Text): Boolean
    var
        TmpTransactionAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        TmpRegisterPaymentLines: Record "NPR MM Reg. Sales Buffer" temporary;
        TmpRegisterSalesLines: Record "NPR MM Reg. Sales Buffer" temporary;
        LoyaltyStoreSetup: Record "NPR MM Loyalty Store Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        EFTTransactionRequest2: Record "NPR EFT Transaction Request";
        LoyaltyPointsPSPClient: Codeunit "NPR MM Loy. Point PSP (Client)";
    begin

        if (not GetStoreSetup(EFTTransactionRequest."Register No.", ResponseText, LoyaltyStoreSetup)) then
            exit(false);

        GetAuthorization(EFTTransactionRequest, LoyaltyStoreSetup, TmpTransactionAuthorization);
        GeneralLedgerSetup.Get();

        // Sales items are points rewarding
        SaleLinePOS.SetFilter("Sales Ticket No.", '=%1', EFTTransactionRequest."Sales Ticket No.");
        SaleLinePOS.SetFilter("Sale Type", '=%1', SaleLinePOS."Sale Type"::Sale);
        SaleLinePOS.SetFilter(Type, '=%1', SaleLinePOS.Type::Item);
        if (SaleLinePOS.FindSet()) then
            repeat
                TmpRegisterSalesLines."Entry No." := TmpRegisterSalesLines.Count() + 1;
                case (SaleLinePOS."Amount Including VAT" >= 0) of
                    true:
                        TmpRegisterSalesLines.Type := TmpRegisterSalesLines.Type::SALES;
                    false:
                        TmpRegisterSalesLines.Type := TmpRegisterSalesLines.Type::RETURN;
                end;
                TmpRegisterSalesLines."Item No." := SaleLinePOS."No.";
                TmpRegisterSalesLines."Variant Code" := SaleLinePOS."Variant Code";
                TmpRegisterSalesLines.Description := SaleLinePOS.Description;
                TmpRegisterSalesLines.Quantity := SaleLinePOS.Quantity;
                TmpRegisterSalesLines."Total Amount" := SaleLinePOS."Amount Including VAT";

                if (SaleLinePOS."Currency Code" = '') then
                    SaleLinePOS."Currency Code" := GeneralLedgerSetup."LCY Code";
                TmpRegisterSalesLines."Currency Code" := SaleLinePOS."Currency Code";

                TmpRegisterSalesLines."Total Points" := EarnAmountToPoints(LoyaltyStoreSetup, TmpRegisterSalesLines."Total Amount");

                TmpRegisterSalesLines.Insert();
            until (SaleLinePOS.Next() = 0);

        EFTTransactionRequest2.SetFilter("Sales Ticket No.", '=%1', EFTTransactionRequest."Sales Ticket No.");
        EFTTransactionRequest2.SetFilter("Integration Type", '=%1', LoyaltyPointsPSPClient.IntegrationName());
        EFTTransactionRequest2.SetFilter("Processing Type", '=%1|%2', EFTTransactionRequest2."Processing Type"::PAYMENT, EFTTransactionRequest2."Processing Type"::REFUND);
        if (EFTTransactionRequest2.FindSet()) then begin
            repeat
                TmpRegisterPaymentLines.Init();
                TmpRegisterPaymentLines."Entry No." := TmpRegisterPaymentLines.Count() + 1;
                case (EFTTransactionRequest2."Processing Type") of
                    EFTTransactionRequest2."Processing Type"::PAYMENT:
                        TmpRegisterPaymentLines.Type := TmpRegisterPaymentLines.Type::PAYMENT;
                    EFTTransactionRequest2."Processing Type"::REFUND:
                        TmpRegisterPaymentLines.Type := TmpRegisterPaymentLines.Type::REFUND;
                end;
                TmpRegisterPaymentLines.Description := EFTTransactionRequest2."POS Description";
                TmpRegisterPaymentLines."Authorization Code" := EFTTransactionRequest2."Authorisation Number";
                TmpRegisterPaymentLines."Currency Code" := EFTTransactionRequest2."Currency Code";
                TmpRegisterPaymentLines."Total Points" := EFTTransactionRequest2."Amount Output";
                TmpRegisterPaymentLines."Total Amount" := BurnPointsToAmount(LoyaltyStoreSetup, EFTTransactionRequest2."Amount Output");
                TmpRegisterPaymentLines.Insert();
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
    begin

        if (not GetStoreSetup(EFTTransactionRequest."Register No.", ResponseText, LoyaltyStoreSetup)) then
            exit(false);

        GetAuthorization(EFTTransactionRequest, LoyaltyStoreSetup, TmpTransactionAuthorization);

        TmpRegisterPaymentLines."Entry No." := 1;
        case EFTTransactionRequest."Processing Type" of
            EFTTransactionRequest."Processing Type"::PAYMENT:
                TmpRegisterPaymentLines.Type := TmpRegisterPaymentLines.Type::PAYMENT;
            EFTTransactionRequest."Processing Type"::REFUND:
                TmpRegisterPaymentLines.Type := TmpRegisterPaymentLines.Type::REFUND;
            else
                TmpRegisterPaymentLines.Type := TmpRegisterPaymentLines.Type::NA;
        end;
        TmpRegisterPaymentLines."Currency Code" := EFTTransactionRequest."Currency Code";
        TmpRegisterPaymentLines."Total Amount" := BurnPointsToAmount(LoyaltyStoreSetup, EFTTransactionRequest."Amount Input");
        TmpRegisterPaymentLines."Total Points" := EFTTransactionRequest."Amount Input";
        TmpRegisterPaymentLines.Description := CopyStr(EFTTransactionRequest."POS Description", 1, MaxStrLen(TmpRegisterPaymentLines.Description));
        TmpRegisterPaymentLines.Insert();

        SoapAction := 'reservePoints';
        XmlText := CreateReservePointsSoapXml(TmpTransactionAuthorization, TmpRegisterPaymentLines);
        exit(true);
    end;

    local procedure HandleReservePointsResult(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var XmlResponseDoc: XmlDocument)
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Element: XmlElement;
        PointsNode: XmlNode;
        ResponseMessageNode: XmlNode;
        OStream: OutStream;
        ResponseCode: Code[20];
        ResponseMessage: Text;
        MessageCode: Text;
        AuthorizationCode: Text;
        ReferenceNumber: Text;
        NewBalance: Text;
        ElementPath: Text;
        ReceiptText: Text;
        XmlAsText: Text;
        XmlDomMgt: Codeunit "XML DOM Management";
    begin


        XmlResponseDoc.WriteTo(XmlAsText);
        XmlDomMgt.RemoveNameSpaces(XmlAsText);
        XmlDocument.ReadFrom(XmlAsText, XmlResponseDoc);

        if (not XmlResponseDoc.GetRoot(Element)) then
            Error(INVALID_XML, NpXmlDomMgt.PrettyPrintXml(XmlAsText));

        // Status
        ElementPath := '//Body/ReservePoints_Result/reservePoints/Response/';
        ResponseCode := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'Status/ResponseCode', 10, true);
        ResponseMessage := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'Status/ResponseMessage', 1000, true);

        NpXmlDomMgt.FindNode(Element.AsXmlNode(), '//Body/ReservePoints_Result/reservePoints/Response/Status/ResponseMessage', ResponseMessageNode);
        MessageCode := NpXmlDomMgt.GetXmlAttributeText(ResponseMessageNode, 'MessageCode', false);

        // Message payload
        NpXmlDomMgt.FindNode(Element.AsXmlNode(), '//Body/ReservePoints_Result/reservePoints/Response/Points', PointsNode);
        ReferenceNumber := NpXmlDomMgt.GetXmlAttributeText(PointsNode, 'ReferenceNumber', false);
        AuthorizationCode := NpXmlDomMgt.GetXmlAttributeText(PointsNode, 'AuthorizationNumber', false);
        NewBalance := NpXmlDomMgt.GetXmlAttributeText(PointsNode, 'NewPointBalance', false);

        EFTTransactionRequest.Successful := (ResponseCode = 'OK');
        FinalizeTransactionRequest(EFTTransactionRequest, MessageCode, ResponseMessage, AuthorizationCode, ReferenceNumber);
        EFTTransactionRequest.Modify();
        Commit();

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

    local procedure HandleRegisterSalesResult(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var XmlResponseDoc: XmlDocument)
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlDomMgt: Codeunit "XML DOM Management";
        Element: XmlElement;
        PointsNode: XmlNode;
        ResponseMessageNode: XmlNode;
        ResponseCode: Code[20];
        ResponseMessage: Text;
        MessageCode: Text;
        AuthorizationCode: Text;
        ReferenceNumber: Text;
        ElementPath: Text;
        NewBalance: Integer;
        PointsEarned: Integer;
        PointsSpent: Integer;
        ReceiptText: Text;
        OStream: OutStream;
        XmlAsText: Text;
    begin

        XmlResponseDoc.WriteTo(XmlAsText);
        XmlDomMgt.RemoveNameSpaces(XmlAsText);
        XmlDocument.ReadFrom(XmlAsText, XmlResponseDoc);

        if (not XmlResponseDoc.GetRoot(Element)) then
            Error(INVALID_XML, NpXmlDomMgt.PrettyPrintXml(XmlAsText));

        // Status
        ElementPath := '//Body/RegisterSale_Result/registerSale/Response/';
        ResponseCode := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'Status/ResponseCode', 10, true);
        ResponseMessage := NpXmlDomMgt.GetXmlText(Element, ElementPath + 'Status/ResponseMessage', 1000, true);

        NpXmlDomMgt.FindNode(Element.AsXmlNode(), '//Body/RegisterSale_Result/registerSale/Response/Status/ResponseMessage', ResponseMessageNode);
        MessageCode := NpXmlDomMgt.GetXmlAttributeText(ResponseMessageNode, 'MessageCode', false);

        // Message payload
        NpXmlDomMgt.FindNode(Element.AsXmlNode(), '//Body/RegisterSale_Result/registerSale/Response/Points', PointsNode);
        ReferenceNumber := NpXmlDomMgt.GetXmlAttributeText(PointsNode, 'ReferenceNumber', false);
        AuthorizationCode := NpXmlDomMgt.GetXmlAttributeText(PointsNode, 'AuthorizationNumber', false);

        EFTTransactionRequest.Successful := (ResponseCode = 'OK');
        FinalizeTransactionRequest(EFTTransactionRequest, MessageCode, ResponseMessage, AuthorizationCode, ReferenceNumber);
        EFTTransactionRequest.Modify();
        Commit();

        if (not EvaluateToInteger(PointsEarned, NpXmlDomMgt.GetXmlAttributeText(PointsNode, 'PointsEarned', false))) then
            PointsEarned := 0;

        if (not EvaluateToInteger(PointsSpent, NpXmlDomMgt.GetXmlAttributeText(PointsNode, 'PointsSpent', false))) then
            PointsSpent := 0;

        if (not EvaluateToInteger(NewBalance, NpXmlDomMgt.GetXmlAttributeText(PointsNode, 'NewPointBalance', false))) then
            NewBalance := 0;

        ReceiptText := CreateRegisterPointsSlip(EFTTransactionRequest, 0, PointsEarned, PointsSpent, NewBalance);
        EFTTransactionRequest."Receipt 1".CreateOutStream(OStream);
        OStream.Write(ReceiptText);

        EFTTransactionRequest.Modify();
        Commit();
    end;

    local procedure FinalizeTransactionRequest(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; MessageCode: Text; ResponseMessage: Text; AuthorizationCode: Text; ReferenceNumber: Text)
    var
        OStream: OutStream;
        LoyaltyStoreSetup: Record "NPR MM Loyalty Store Setup";
        POSPaymentMethod: Record "NPR POS Payment Method";
        CardNumberLbl: Label '%1%2', Locked = true;
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
            POSPaymentMethod.Get(LoyaltyStoreSetup."POS Payment Method Code");

            if (POSPaymentMethod."Fixed Rate" = 0) then
                POSPaymentMethod."Fixed Rate" := 100;

            EFTTransactionRequest."Result Code" := 10;
            EFTTransactionRequest."Result Description" := TEXT_APPROVED;
            EFTTransactionRequest."Result Display Text" := TEXT_APPROVED;

            EFTTransactionRequest."Result Amount" := EFTTransactionRequest."Amount Input" * POSPaymentMethod."Fixed Rate" / 100;
            EFTTransactionRequest."Amount Output" := EFTTransactionRequest."Amount Input";
            EFTTransactionRequest."Authorisation Number" := AuthorizationCode;
            EFTTransactionRequest."Reference Number Output" := ReferenceNumber;
        end;

        EFTTransactionRequest.Finished := CurrentDateTime();
        EFTTransactionRequest."Card Number" := StrSubstNo(CardNumberLbl,
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
        AIDLbl: Label 'AID: ', Locked = true;
        REFLbl: Label 'REF: ', Locked = true;
        PlaceHolder1Lbl: Label '%1 (%2)', Locked = true;
        PlaceHolder2Lbl: Label '%1 %2', Locked = true;
        PlaceHolder3Lbl: Label '%1 / %2 / %3', Locked = true;
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

        ReceiptText += WriteSlipLine(CreditCardTransaction, '');

        if (EFTTransactionRequest.Successful) then begin
            ReceiptText += WriteSlipLine(CreditCardTransaction, StrSubstNo(AIDLbl + EFTTransactionRequest."Authorisation Number"));
            ReceiptText += WriteSlipLine(CreditCardTransaction, StrSubstNo(REFLbl + EFTTransactionRequest."Reference Number Output"));
            ReceiptText += WriteSlipLine(CreditCardTransaction, '');
            ReceiptText += WriteSlipLine(CreditCardTransaction, LeftRightText(TicketWidth,
              '****',
              TEXT_APPROVED));
        end;

        if (not EFTTransactionRequest.Successful) then begin
            ReceiptText += WriteSlipLine(CreditCardTransaction, LeftRightText(TicketWidth,
              '****',
              StrSubstNo(PlaceHolder1Lbl, TEXT_DECLINED, EFTTransactionRequest."Result Code")));
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
            StrSubstNo(PlaceHolder2Lbl,
              EFTTransactionRequest."Transaction Date",
              EFTTransactionRequest."Transaction Time")));

        ReceiptText += WriteSlipLine(CreditCardTransaction, CenterText(TicketWidth,
            StrSubstNo(PlaceHolder3Lbl,
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
        AIDLbl: Label 'AID: ', Locked = true;
        REFLbl: Label 'REF: ', Locked = true;
        PlaceHolderLbl: Label '(%1)', Locked = true;
        PlaceHolder2Lbl: Label '%1 %2', Locked = true;
        PlaceHolder3Lbl: Label '%1 / %2 / %3', Locked = true;
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
              StrSubstNo(PlaceHolderLbl, EFTTransactionRequest."Result Code")));
        end;

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

        ReceiptText += WriteSlipLine(CreditCardTransaction, '');

        if (EFTTransactionRequest.Successful) then begin
            ReceiptText += WriteSlipLine(CreditCardTransaction, StrSubstNo(AIDLbl + EFTTransactionRequest."Authorisation Number"));
            ReceiptText += WriteSlipLine(CreditCardTransaction, StrSubstNo(REFLbl + EFTTransactionRequest."Reference Number Output"));
            ReceiptText += WriteSlipLine(CreditCardTransaction, '');
        end;

        if (not EFTTransactionRequest.Successful) then begin

        end;

        ReceiptText += WriteSlipLine(CreditCardTransaction, '');

        ReceiptText += WriteSlipLine(CreditCardTransaction, CenterText(TicketWidth,
            StrSubstNo(PlaceHolder2Lbl,
              EFTTransactionRequest."Transaction Date",
              EFTTransactionRequest."Transaction Time")));

        ReceiptText += WriteSlipLine(CreditCardTransaction, CenterText(TicketWidth,
            StrSubstNo(PlaceHolder3Lbl,
              EFTTransactionRequest."Sales Ticket No.",
              POSUnit."POS Store Code",
              POSUnit."No.")));

        ReceiptText += WriteSlipLine(CreditCardTransaction, '');
    end;

    local procedure WriteSlipLine(var CreditCardTransaction: Record "NPR EFT Receipt"; LineText: Text): Text
    var
        EntryNo: Integer;
        CRLF: Text[2];
        PlaceHolderLbl: Label '%1%2', Locked = true;
    begin

        EntryNo := CreditCardTransaction."Entry No." + 1;

        CreditCardTransaction.Validate("Entry No.", EntryNo);
        CreditCardTransaction.Validate("Line No.", 0);
        CreditCardTransaction.Validate(Type, 0);
        CreditCardTransaction.Validate(Text, CopyStr(LineText, 1, MaxStrLen(CreditCardTransaction.Text)));
        CreditCardTransaction.Insert(true);

        CRLF[1] := 10;
        CRLF[2] := 13;
        exit(StrSubstNo(PlaceHolderLbl, LineText, CRLF));
    end;

    local procedure CenterText(Width: Integer; InText: Text) OutText: Text
    var
        PlaceHolderLbl: Label '%1%2', Locked = true;
    begin
        if (StrLen(InText) = 0) then
            exit(' ');

        InText := CopyStr(InText, 1, Width);

        OutText := StrSubstNo(PlaceHolderLbl,
          PadStr('', Round(Width / 2 - StrLen(InText) / 2, 1), ' '),
          CopyStr(InText, 1, Width));
    end;

    local procedure LeftRightText(Width: Integer; LeftText: Text; RightText: Text) OutText: Text
    var
        PlaceHolderLbl: Label '%1%2%3', Locked = true;
    begin
        if ((StrLen(LeftText) = 0) and (StrLen(RightText) = 0)) then
            exit(' ');

        if ((StrLen(LeftText) + StrLen(RightText)) > Width) then begin
            LeftText := CopyStr(LeftText, 1, Round(Width / 2, 1));
            RightText := CopyStr(RightText, 1, Round(Width / 2, 1));
        end;

        OutText := StrSubstNo(PlaceHolderLbl,
          LeftText,
          PadStr('', Round(Width - StrLen(LeftText) - StrLen(RightText), 1), ' '),
          RightText);
    end;

    local procedure EarnAmountToPoints(LoyaltyStoreSetup: Record "NPR MM Loyalty Store Setup"; Amount: Decimal) Points: Integer
    var
        LoyaltySetup: Record "NPR MM Loyalty Setup";
    begin

        LoyaltySetup.Get(LoyaltyStoreSetup."Loyalty Setup Code");

        Points := Round(Amount * LoyaltySetup."Amount Factor", 1);
    end;

    local procedure BurnPointsToAmount(LoyaltyStoreSetup: Record "NPR MM Loyalty Store Setup"; Points: Decimal) Amount: Decimal
    var
        PaymentMethod: Record "NPR POS Payment Method";
    begin

        PaymentMethod.Get(LoyaltyStoreSetup."POS Payment Method Code");

        Amount := Points * (PaymentMethod."Fixed Rate" / 100);
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

            //  IF (NOT LoyaltySetup.Get() (MembershipSetup."Loyalty Code")) THEN
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
    var
        Xml1Lbl: Label '<PosCompanyName>%1</PosCompanyName>', Locked = true;
        Xml2Lbl: Label '<PosStoreCode>%1</PosStoreCode>', Locked = true;
        Xml3Lbl: Label '<PosUnitCode>%1</PosUnitCode>', Locked = true;
        Xml4Lbl: Label '<Token>%1</Token>', Locked = true;
        Xml5Lbl: Label '<ClientCardNumber>%1</ClientCardNumber>', Locked = true;
        Xml6Lbl: Label '<ReceiptNumber>%1</ReceiptNumber>', Locked = true;
        Xml7Lbl: Label '<TransactionId>%1</TransactionId>', Locked = true;
        Xml8Lbl: Label '<Date>%1</Date>', Locked = true;
        Xml9Lbl: Label '<Time>%1</Time>', Locked = true;
    begin
        XmlText :=
        '<Authorization>' +
          StrSubstNo(Xml1Lbl, TmpTransactionAuthorization."Company Name") +
          StrSubstNo(Xml2Lbl, TmpTransactionAuthorization."POS Store Code") +
          StrSubstNo(Xml3Lbl, TmpTransactionAuthorization."POS Unit Code") +
          StrSubstNo(Xml4Lbl, TmpTransactionAuthorization."Authorization Code") +
          StrSubstNo(Xml5Lbl, TmpTransactionAuthorization."Card Number") +
          StrSubstNo(Xml6Lbl, TmpTransactionAuthorization."Reference Number") +
          StrSubstNo(Xml7Lbl, TmpTransactionAuthorization."Foreign Transaction Id") +
          StrSubstNo(Xml8Lbl, Format(TmpTransactionAuthorization."Transaction Date", 0, 9)) +
          StrSubstNo(Xml9Lbl, Format(TmpTransactionAuthorization."Transaction Time", 0, 9)) +
        '</Authorization>';
    end;

    procedure CreateRegisterSalesEftTransaction(IntegrationName: Code[20]; SalePOS: Record "NPR POS Sale"; var EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    begin

        EFTTransactionRequest."Entry No." := 0;

        EFTTransactionRequest.Token := CreateGuid();
        EFTTransactionRequest."User ID" := UserId();
        EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::AUXILIARY;
        EFTTransactionRequest."Auxiliary Operation ID" := 1;
        EFTTransactionRequest."Auxiliary Operation Desc." := 'Register Receipt';

        EFTTransactionRequest."Integration Type" := IntegrationName;
        EFTTransactionRequest.Started := CurrentDateTime();
        EFTTransactionRequest."User ID" := EFTTransactionRequest."User ID";
        EFTTransactionRequest."Sales Ticket No." := SalePOS."Sales Ticket No.";
        EFTTransactionRequest."Sales Line No." := 0;
        EFTTransactionRequest."Register No." := SalePOS."Register No.";
        EFTTransactionRequest."POS Payment Type Code" := '';
        EFTTransactionRequest."Result Code" := 0;

        EFTTransactionRequest."Transaction Date" := Today();
        EFTTransactionRequest."Transaction Time" := Time;
        EFTTransactionRequest.Started := CurrentDateTime();
        if (not AssignLoyaltyInformation(EFTTransactionRequest)) then
            exit(false);

        EFTTransactionRequest."Reference Number Input" := Format(EFTTransactionRequest."Entry No.", 0, 9);
        EFTTransactionRequest.Insert(true);

        exit(true);
    end;

    procedure CreateRegisterSaleTestXml(var TmpTransactionAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; var TmpRegisterSaleLines: Record "NPR MM Reg. Sales Buffer" temporary; var TmpRegisterPaymentLines: Record "NPR MM Reg. Sales Buffer" temporary) XmlText: Text
    begin

        XmlText :=
        '<?xml version="1.0" encoding="UTF-8" standalone="no"?>' +
        '<RegisterSale xmlns="urn:microsoft-dynamics-nav/xmlports/x6151162">' +
          CreateRegisterSaleXml(TmpTransactionAuthorization, TmpRegisterSaleLines, TmpRegisterPaymentLines) +
        '</RegisterSale>';
    end;

    procedure CreateRegisterSaleSoapXml(var TmpTransactionAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; var TmpRegisterSaleLines: Record "NPR MM Reg. Sales Buffer" temporary; var TmpRegisterPaymentLines: Record "NPR MM Reg. Sales Buffer" temporary) XmlText: Text
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
        XmlSalesLinesLbl: Label '<Line Type="%1" ItemNumber="%2" VariantCode="%3" Quantity="%4" Description="%5" CurrencyCode="%6" Amount="%7" Points="%8"/>', Locked = true;
        XmlPaymentLinesLbl: Label '<Line Type="%1" Description="%2" CurrencyCode="%3" Amount="%4" Points="%5" AuthorizationCode="%6"/>', Locked = true;
    begin

        TmpTransactionAuthorization.FindFirst();

        if (TmpRegisterSaleLines.FindSet()) then
            repeat
                XmlSalesLines += StrSubstNo(XmlSalesLinesLbl,
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
                XmlPaymentLines += StrSubstNo(XmlPaymentLinesLbl,
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
    begin

        XmlText :=
        '<?xml version="1.0" encoding="UTF-8" standalone="no"?>' +
        '<ReservePoints  xmlns="urn:microsoft-dynamics-nav/xmlports/x6151163">' +
          CreateReservePointsXml(TmpTransactionAuthorization, TmpRegisterPaymentLines) +
        '</ReservePoints>';
    end;

    procedure CreateReservePointsSoapXml(var TmpTransactionAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; var TmpRegisterPaymentLines: Record "NPR MM Reg. Sales Buffer" temporary) XmlText: Text
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
        XmlReservationLinesLbl: Label '<Line Type="%1" Description="%2" CurrencyCode="%3" Amount="%4" Points="%5"/>', Locked = true;
    begin

        TmpTransactionAuthorization.FindFirst();

        if (TmpRegisterPaymentLines.FindSet()) then
            repeat
                XmlReservationLines += StrSubstNo(XmlReservationLinesLbl,
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

