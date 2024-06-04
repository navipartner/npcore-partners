codeunit 85106 "NPR Library MemberLoyalty"
{
    procedure CreateScenario_AsYouGoLoyalty() LoyaltyCode: Code[20]
    var
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        ItemLoyalty: Record "NPR MM Loy. Item Point Setup";
        MembershipSalesItem: Record "NPR MM Members. Sales Setup";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipLibrary: Codeunit "NPR Library - Member Module";
        SalesItemNo: Code[20];
    begin

        SalesItemNo := MembershipLibrary.CreateScenario_SmokeTest();
        MembershipSalesItem.Get(MembershipSalesItem.Type::ITEM, SalesItemNo);
        MembershipSetup.Get(MembershipSalesItem."Membership Code");
        LoyaltySetup.Get(MembershipSetup."Loyalty Code");
        CreateLoyaltySetup_AsYouGo(LoyaltySetup);

        ItemLoyalty.SetFilter(Code, '=%1', LoyaltySetup.Code);
        ItemLoyalty.DeleteAll();

        exit(LoyaltySetup.Code);
    end;

    internal procedure CreateScenario_Loyalty100(var TmpTransactionAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; var TmpRegisterSaleLines: Record "NPR MM Reg. Sales Buffer" temporary; var TmpRegisterPaymentLines: Record "NPR MM Reg. Sales Buffer" temporary) SalesItemNo: Code[20]
    var
        LoyaltySetup: Record "NPR MM Loyalty Setup";
        MembershipSalesItem: Record "NPR MM Members. Sales Setup";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipLibrary: Codeunit "NPR Library - Member Module";

        StoreCode: Code[20];
        UnitCode: Code[10];
    begin

        Clear(TmpTransactionAuthorization);
        Clear(TmpRegisterSaleLines);
        Clear(TmpRegisterPaymentLines);

        SalesItemNo := MembershipLibrary.CreateScenario_SmokeTest();

        StoreCode := MembershipLibrary.GenerateSafeCode10();
        UnitCode := MembershipLibrary.GenerateSafeCode10();

        MembershipSalesItem.Get(MembershipSalesItem.Type::ITEM, SalesItemNo);
        MembershipSetup.Get(MembershipSalesItem."Membership Code");
        LoyaltySetup.Get(MembershipSetup."Loyalty Code");
        CreateLoyaltySetup_AsYouGo(LoyaltySetup);
        CreateStoreSetup(StoreCode, UnitCode);
        GetAuthorization(StoreCode, UnitCode, TmpTransactionAuthorization);

        TmpTransactionAuthorization."Reference Number" := MembershipLibrary.GenerateSafeCode20();
        TmpTransactionAuthorization.Modify();

        exit(SalesItemNo);
    end;

    local procedure CreateLoyaltySetup_AsYouGo(var LoyaltySetup: Record "NPR MM Loyalty Setup")
    begin
        LoyaltySetup."Auto Upgrade Point Source" := LoyaltySetup."Auto Upgrade Point Source"::NA;
        LoyaltySetup."Point Rate" := 0.17;
        LoyaltySetup."Amount Base" := LoyaltySetup."Amount Base"::INCL_VAT;
        LoyaltySetup."Amount Factor" := 2.17;
        LoyaltySetup."Point Base" := LoyaltySetup."Point Base"::AMOUNT;
        LoyaltySetup."Collection Period" := LoyaltySetup."Collection Period"::AS_YOU_GO;
        Evaluate(LoyaltySetup."Expire Uncollected After", '<+12M>');
        LoyaltySetup."Expire Uncollected Points" := true;
        LoyaltySetup.Modify();
    end;

    local procedure CreateStoreSetup(StoreCode: Code[20]; UnitCode: Code[20])
    var
        StoreSetup: Record "NPR MM Loyalty Store Setup";
    begin
        StoreSetup."Client Company Name" := '';
        StoreSetup."Store Code" := StoreCode;
        StoreSetup."Unit Code" := UnitCode;
        StoreSetup."Authorization Code" := CreateGuid();
        StoreSetup."Accept Client Transactions" := true;
        StoreSetup."Loyalty Setup Code" := 'TEST';
        // TODO StoreSetup."Interim Account No." := '';
        StoreSetup."Burn Points Currency Code" := '';
        StoreSetup.Insert();
    end;

    local procedure GetAuthorization(StoreCode: Code[10]; UnitCode: Code[10]; var TmpAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary): Boolean
    var
        StoreSetup: Record "NPR MM Loyalty Store Setup";
    begin
        StoreSetup.Get('', StoreCode, UnitCode);

        TmpAuthorization."Entry No." := 1;
        TmpAuthorization."Authorization Code" := StoreSetup."Authorization Code";
        TmpAuthorization."POS Store Code" := StoreCode;
        TmpAuthorization."POS Unit Code" := UnitCode;
        TmpAuthorization."Foreign Transaction Id" := CreateGuid();
        TmpAuthorization."Transaction Date" := Today();
        TmpAuthorization."Transaction Time" := Time();
        TmpAuthorization.Insert();
    end;

    internal procedure GenerateQtyAmtPointsBurn(LoyaltyCode: Code[20]; VAR Quantity: Decimal; VAR Amount: Decimal; VAR Points: Integer)
    begin
        Quantity := (Random(10) + 10) / 10;      // => 1.1 .. 2.0
        Amount := (Random(57) + 100) * Quantity;  // => 101 .. 157 * Quantity
        Points := CalculatePointsBurn(LoyaltyCode, Quantity, Amount);
    end;

    internal procedure CalculatePointsBurn(LoyaltyCode: Code[20]; Quantity: Decimal; Amount: Decimal) Points: Integer
    var
        LoyaltySetup: Record "NPR MM Loyalty Setup";
    begin
        LoyaltySetup.Get(LoyaltyCode);
        Points := Round(Quantity * Amount * LoyaltySetup."Amount Factor" * LoyaltySetup."Point Rate", 1);
    end;

    internal procedure CreateSaleLine(ItemNo: Code[20]; VariantCode: Code[10]; Qty: Decimal; TotalAmount: Decimal; TotalPoints: Integer; var TmpRegisterSaleLines: Record "NPR MM Reg. Sales Buffer" temporary)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();

        TmpRegisterSaleLines.Init();
        TmpRegisterSaleLines."Entry No." := TmpRegisterSaleLines.Count() + 1;
        TmpRegisterSaleLines.Type := TmpRegisterSaleLines.Type::SALES;
        TmpRegisterSaleLines."Item No." := ItemNo;
        TmpRegisterSaleLines."Variant Code" := VariantCode;
        TmpRegisterSaleLines.Description := 'Some Item Description';
        TmpRegisterSaleLines.Quantity := Qty;
        TmpRegisterSaleLines."Total Amount" := TotalAmount;
        TmpRegisterSaleLines."Total Points" := TotalPoints;
        TmpRegisterSaleLines."Currency Code" := GeneralLedgerSetup."LCY Code";
        TmpRegisterSaleLines.Insert();
    end;

    internal procedure CreatePaymentLine(Amount: Decimal; Points: Integer; AuthorizationCode: Text[40]; var TmpRegisterPaymentLines: Record "NPR MM Reg. Sales Buffer" temporary)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();

        TmpRegisterPaymentLines.Init();
        TmpRegisterPaymentLines."Entry No." := TmpRegisterPaymentLines.Count() + 1;
        TmpRegisterPaymentLines.Type := TmpRegisterPaymentLines.Type::PAYMENT;
        TmpRegisterPaymentLines.Description := 'The Payment Description';
        TmpRegisterPaymentLines."Total Amount" := Amount;
        TmpRegisterPaymentLines."Total Points" := Points;
        TmpRegisterPaymentLines."Authorization Code" := AuthorizationCode;
        TmpRegisterPaymentLines."Currency Code" := GeneralLedgerSetup."LCY Code";
        TmpRegisterPaymentLines.Insert();
    end;


    internal procedure Simulate_RegisterSale_SOAPAction(XmlRequest: Text; var ResponseCode: Code[20]; var ResponseMessage: Text; var TempPointsResponse: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; var DocumentId: Text) XmlResponse: Text
    var
        XmlRegisterSale: XMLport "NPR MM Register Sale";
        TempBLOBbuffer: Record "NPR BLOB buffer" temporary;
        iStream: InStream;
        oStream: OutStream;
        LoyaltyWebService: Codeunit "NPR MM Loyalty WebService";
    begin
        // Load request stream to XML port
        TempBLOBbuffer.Insert();
        TempBLOBbuffer."Buffer 1".CreateOutStream(oStream);
        oStream.WriteText(XmlRequest);
        TempBLOBbuffer.Modify();

        TempBLOBbuffer."Buffer 1".CreateInStream(iStream);
        XmlRegisterSale.SetSource(iStream);
        XmlRegisterSale.Import();

        // Process request
        LoyaltyWebService.RegisterSale(XmlRegisterSale);
        XmlRegisterSale.GetResponse(ResponseCode, ResponseMessage, DocumentId, TempPointsResponse);
    end;

    internal procedure Simulate_ReservePoints_SOAPAction(XmlRequest: Text; var ResponseCode: Code[20]; var ResponseMessage: Text; var TempPointsResponse: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; var DocumentId: Text) XmlResponse: Text
    var
        XmlReservePoints: XMLport "NPR MM Reserve Points";
        TempBLOBbuffer: Record "NPR BLOB buffer" temporary;
        iStream: InStream;
        oStream: OutStream;
        LoyaltyWebService: Codeunit "NPR MM Loyalty WebService";
    begin
        // Load request stream to XML port
        TempBLOBbuffer.Insert();
        TempBLOBbuffer."Buffer 1".CreateOutStream(oStream);
        oStream.WriteText(XmlRequest);
        TempBLOBbuffer.Modify();

        TempBLOBbuffer."Buffer 1".CreateInStream(iStream);
        XmlReservePoints.SetSource(iStream);
        XmlReservePoints.Import();

        // Process request
        LoyaltyWebService.ReservePoints(XmlReservePoints);
        XmlReservePoints.GetResponse(ResponseCode, ResponseMessage, DocumentId, TempPointsResponse);
    end;

    internal procedure Simulate_CancelReservePoints_SOAPAction(XmlRequest: Text; var ResponseCode: Code[20]; var ResponseMessage: Text; var TempPointsResponse: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary; var DocumentId: Text) XmlResponse: Text
    var
        XmlCancelReservePoints: XMLport "NPR MM CancelReservePoints";
        TempBLOBbuffer: Record "NPR BLOB buffer" temporary;
        iStream: InStream;
        oStream: OutStream;
        LoyaltyWebService: Codeunit "NPR MM Loyalty WebService";
    begin
        // Load request stream to XML port
        TempBLOBbuffer.Insert();
        TempBLOBbuffer."Buffer 1".CreateOutStream(oStream);
        oStream.WriteText(XmlRequest);
        TempBLOBbuffer.Modify();

        TempBLOBbuffer."Buffer 1".CreateInStream(iStream);
        XmlCancelReservePoints.SetSource(iStream);
        XmlCancelReservePoints.Import();

        // Process request
        LoyaltyWebService.CancelReservePoints(XmlCancelReservePoints);
        XmlCancelReservePoints.GetResponse(ResponseCode, ResponseMessage, DocumentId, TempPointsResponse);
    end;

    internal procedure CreateAuthorizationCode(): Text[40]
    begin
        exit(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')));
    end;

}