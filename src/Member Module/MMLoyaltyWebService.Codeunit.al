codeunit 6060141 "NPR MM Loyalty WebService"
{

    trigger OnRun()
    begin
    end;

    var
        SETUP_MISSING: Label 'Setup is missing for %1.';

    procedure GetLoyaltyPoints(var GetLoyaltyPoints: XMLport "NPR MM Get Loyalty Points")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin
        GetLoyaltyPoints.Import();

        InsertImportEntry('GetLoyaltyPoints', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo('GetLoyaltyPoints-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        GetLoyaltyPoints.SetDestination(OutStr);
        GetLoyaltyPoints.Export;
        ImportEntry.Modify(true);
        Commit();

        MemberInfoCapture.SetCurrentKey("Import Entry Document ID");
        MemberInfoCapture.SetFilter("Import Entry Document ID", '=%1', ImportEntry."Document ID");

        if (NaviConnectSyncMgt.ProcessImportEntry(ImportEntry)) then begin
            GetLoyaltyPoints.ClearResponse();

            MemberInfoCapture.FindFirst();
            GetLoyaltyPoints.AddResponse(MemberInfoCapture."Membership Entry No.");

        end else begin
            GetLoyaltyPoints.AddErrorResponse(ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        GetLoyaltyPoints.SetDestination(OutStr);
        GetLoyaltyPoints.Export;
        ImportEntry.Modify(true);

        MemberInfoCapture.DeleteAll();
    end;

    procedure GetLoyaltyPointEntries(var GetLoyaltyStatement: XMLport "NPR MM Get Loy. Statement")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin
        GetLoyaltyStatement.Import();

        InsertImportEntry('GetLoyaltyPointEntries', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo('GetLoyaltyPointEntries-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        GetLoyaltyStatement.SetDestination(OutStr);
        GetLoyaltyStatement.Export;
        ImportEntry.Modify(true);
        Commit();

        MemberInfoCapture.SetCurrentKey("Import Entry Document ID");
        MemberInfoCapture.SetFilter("Import Entry Document ID", '=%1', ImportEntry."Document ID");

        if (NaviConnectSyncMgt.ProcessImportEntry(ImportEntry)) then begin
            GetLoyaltyStatement.ClearResponse();

            MemberInfoCapture.FindFirst();
            GetLoyaltyStatement.AddResponse(MemberInfoCapture."Membership Entry No.");

        end else begin
            GetLoyaltyStatement.AddErrorResponse(ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        GetLoyaltyStatement.SetDestination(OutStr);
        GetLoyaltyStatement.Export;
        ImportEntry.Modify(true);

        MemberInfoCapture.DeleteAll();
    end;

    procedure GetMembershipReceiptList(var GetLoyaltyReceiptList: XMLport "NPR MM Get Loyalty Rcpt. List")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin

        GetLoyaltyReceiptList.Import();

        InsertImportEntry('GetLoyaltyReceiptList', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo('GetLoyaltyReceiptList-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        GetLoyaltyReceiptList.SetDestination(OutStr);
        GetLoyaltyReceiptList.Export;
        ImportEntry.Modify(true);
        Commit();

        MemberInfoCapture.SetCurrentKey("Import Entry Document ID");
        MemberInfoCapture.SetFilter("Import Entry Document ID", '=%1', ImportEntry."Document ID");

        if (NaviConnectSyncMgt.ProcessImportEntry(ImportEntry)) then begin
            GetLoyaltyReceiptList.ClearResponse();

            MemberInfoCapture.FindFirst();
            GetLoyaltyReceiptList.AddResponse(MemberInfoCapture."Membership Entry No.", '');

        end else begin
            GetLoyaltyReceiptList.AddErrorResponse(ImportEntry."Error Message");

        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        GetLoyaltyReceiptList.SetDestination(OutStr);
        GetLoyaltyReceiptList.Export;
        ImportEntry.Modify(true);

        MemberInfoCapture.DeleteAll();

    end;

    procedure GetMembershipReceiptPdf(ExternalMembershipNumber: Code[20]; ReceiptEntryNo: Integer) PdfDoc: Text
    var
        ReportSelections: Record "NPR Report Selection Retail";
        POSEntry: Record "NPR POS Entry";
        Membership: Record "NPR MM Membership";
        UserPersonalization: Record "User Personalization";
        Filename: Text;
        LanguageId: Integer;
    begin

        ReportSelections.SetFilter("Report Type", '=%1', ReportSelections."Report Type"::"Large Sales Receipt (POS Entry)");
        ReportSelections.SetFilter("Report ID", '<>%1', 0);

        //ReportSelections.FindFirst;
        if not ReportSelections.FindFirst then
            ReportSelections."Report ID" := REPORT::"NPR Sales Ticket A4 - POS Rdlc";

        Membership.SetFilter("External Membership No.", '=%1', ExternalMembershipNumber);
        Membership.FindFirst();
        Membership.TestField("Customer No.");

        POSEntry.Get(ReceiptEntryNo);
        POSEntry.TestField("Customer No.", Membership."Customer No.");
        POSEntry.SetRecFilter;

        Filename := TemporaryPath + 'Receipt-' + Format(ReceiptEntryNo, 0, 9) + '.pdf';

        UserPersonalization.SetFilter("User ID", '%1', UserId);
        if (UserPersonalization.FindFirst()) then
            LanguageId := GlobalLanguage(UserPersonalization."Language ID");

        REPORT.SaveAsPdf(ReportSelections."Report ID", Filename, POSEntry);

        if (LanguageId <> 0) then
            GlobalLanguage(LanguageId);

        PdfDoc := GetBase64(Filename);
        if Erase(Filename) then;

        exit(PdfDoc);
    end;

    local procedure "*** LoyaltyServerFunctions ***"()
    begin
    end;

    procedure RegisterSale(var RegisterSale: XMLport "NPR MM Register Sale")
    var
        TmpAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        TmpSalesLines: Record "NPR MM Reg. Sales Buffer" temporary;
        TmpPaymentLines: Record "NPR MM Reg. Sales Buffer" temporary;
        TmpPointsResponse: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        ImportEntry: Record "NPR Nc Import Entry";
        OutStr: OutStream;
        LoyaltyWebServiceMgr: Codeunit "NPR MM Loyalty WebService Mgr";
        LoyaltyPointsMgrServer: Codeunit "NPR MM Loy. Point Mgr (Server)";
        ResponseMessage: Text;
        ResponseMessageId: Text;
    begin

        RegisterSale.Import();

        InsertImportEntry('RegisterSale', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo('RegisterSale-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));
        ImportEntry.Modify(true);
        Commit();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        RegisterSale.SetDestination(OutStr);
        RegisterSale.Export;
        ImportEntry.Modify(true);
        Commit();

        // Process
        RegisterSale.SetDocumentId := ImportEntry."Document ID";
        RegisterSale.GetRequest(TmpAuthorization, TmpSalesLines, TmpPaymentLines);
        if (LoyaltyPointsMgrServer.RegisterSales(TmpAuthorization, TmpSalesLines, TmpPaymentLines, TmpPointsResponse, ResponseMessage, ResponseMessageId)) then begin
            RegisterSale.SetResponse(TmpPointsResponse);

            ImportEntry.Imported := true;
            ImportEntry."Runtime Error" := false;
        end else begin
            RegisterSale.SetErrorResponse(ResponseMessage, ResponseMessageId);

            ImportEntry.Imported := true;
            ImportEntry."Runtime Error" := true;
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        RegisterSale.SetDestination(OutStr);
        RegisterSale.Export;

        ImportEntry.Imported := true;
        ImportEntry."Runtime Error" := false;

        ImportEntry.Modify(true);
    end;

    procedure ReservePoints(var ReservePoints: XMLport "NPR MM Reserve Points")
    var
        TmpAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        TmpPaymentLines: Record "NPR MM Reg. Sales Buffer" temporary;
        TmpPointsResponse: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        ImportEntry: Record "NPR Nc Import Entry";
        OutStr: OutStream;
        LoyaltyWebServiceMgr: Codeunit "NPR MM Loyalty WebService Mgr";
        LoyaltyPointsMgrServer: Codeunit "NPR MM Loy. Point Mgr (Server)";
        ResponseMessage: Text;
        ResponseMessageId: Text;
    begin

        ReservePoints.Import();

        InsertImportEntry('ReservePoints', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo('ReservePoints-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));
        ImportEntry.Modify(true);
        Commit();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        ReservePoints.SetDestination(OutStr);
        ReservePoints.Export;
        ImportEntry.Modify(true);
        Commit();

        // Process
        ReservePoints.SetDocumentId := ImportEntry."Document ID";
        ReservePoints.GetRequest(TmpAuthorization, TmpPaymentLines);
        if (LoyaltyPointsMgrServer.ReservePoints(TmpAuthorization, TmpPaymentLines, TmpPointsResponse, ResponseMessage, ResponseMessageId)) then begin
            ReservePoints.SetResponse(TmpPointsResponse);

            ImportEntry.Imported := true;
            ImportEntry."Runtime Error" := false;
        end else begin
            ReservePoints.SetErrorResponse(ResponseMessage, ResponseMessageId);

            ImportEntry.Imported := true;
            ImportEntry."Runtime Error" := true;
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        ReservePoints.SetDestination(OutStr);
        ReservePoints.Export;

        ImportEntry.Imported := true;
        ImportEntry."Runtime Error" := false;

        ImportEntry.Modify(true);
    end;

    local procedure ReleaseReservation()
    begin
    end;

    procedure GetLoyaltyConfiguration(var GetLoyaltyConfiguration: XMLport "NPR MM Get Loyalty Config.")
    var
        TmpAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        TmpLoyaltySetup: Record "NPR MM Loyalty Setup" temporary;
        ImportEntry: Record "NPR Nc Import Entry";
        OutStr: OutStream;
        LoyaltyWebServiceMgr: Codeunit "NPR MM Loyalty WebService Mgr";
        LoyaltyPointsMgrServer: Codeunit "NPR MM Loy. Point Mgr (Server)";
        ResponseMessage: Text;
        ResponseMessageId: Text;
    begin

        GetLoyaltyConfiguration.Import();

        InsertImportEntry('GetLoyaltyConfiguration', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo('GetLoyaltyConfiguration-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));
        ImportEntry.Modify(true);
        Commit();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        GetLoyaltyConfiguration.SetDestination(OutStr);
        GetLoyaltyConfiguration.Export;
        ImportEntry.Modify(true);
        Commit();

        // Process
        GetLoyaltyConfiguration.SetDocumentId := ImportEntry."Document ID";
        GetLoyaltyConfiguration.GetRequest(TmpAuthorization);

        if (LoyaltyPointsMgrServer.GetLoyaltySetup(TmpAuthorization, TmpLoyaltySetup, ResponseMessage, ResponseMessageId)) then begin
            GetLoyaltyConfiguration.SetResponse(TmpLoyaltySetup);

            ImportEntry.Imported := true;
            ImportEntry."Runtime Error" := false;
        end else begin
            GetLoyaltyConfiguration.SetErrorResponse(ResponseMessage, ResponseMessageId);

            ImportEntry.Imported := true;
            ImportEntry."Runtime Error" := true;
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        GetLoyaltyConfiguration.SetDestination(OutStr);
        GetLoyaltyConfiguration.Export;

        ImportEntry.Imported := true;
        ImportEntry."Runtime Error" := false;

        ImportEntry.Modify(true);
    end;

    local procedure "*** Points to Coupons ***"()
    begin
    end;

    procedure GetCouponEligibility(var LoyaltyCouponEligibility: XMLport "NPR MM Loyalty Coupon Elig.")
    var
        TmpLoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup" temporary;
        TmpMemberInfoCapture: Record "NPR MM Member Info Capture" temporary;
        MembershipEntryNo: Integer;
        ImportEntry: Record "NPR Nc Import Entry";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        OutStr: OutStream;
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
        ResponseMessage: Text;
        ResponseMessageId: Text;
    begin

        LoyaltyCouponEligibility.Import();

        InsertImportEntry('LoyaltyCouponEligibility', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo('LoyaltyCouponEligibility-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := true;
        ImportEntry.Modify(true);
        Commit();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        LoyaltyCouponEligibility.SetDestination(OutStr);
        LoyaltyCouponEligibility.Export;
        ImportEntry.Modify(true);
        Commit();

        // Process
        LoyaltyCouponEligibility.GetRequest(TmpMemberInfoCapture);
        if (TmpMemberInfoCapture."External Card No." <> '') then
            MembershipEntryNo := MembershipManagement.GetMembershipFromExtCardNo(TmpMemberInfoCapture."External Card No.", Today, ResponseMessage);

        if (TmpMemberInfoCapture."External Membership No." <> '') then
            MembershipEntryNo := MembershipManagement.GetMembershipFromExtMembershipNo(TmpMemberInfoCapture."External Membership No.");

        if (TmpMemberInfoCapture."Document No." <> '') then
            MembershipEntryNo := MembershipManagement.GetMembershipFromCustomerNo(TmpMemberInfoCapture."Document No.");

        if (MembershipEntryNo > 0) then begin
            LoyaltyPointManagement.GetCouponToRedeemWS(MembershipEntryNo, TmpLoyaltyPointsSetup, TmpMemberInfoCapture."Amount Incl VAT", ResponseMessage);
            LoyaltyCouponEligibility.AddResponse(MembershipEntryNo, TmpLoyaltyPointsSetup, ResponseMessage);

        end else begin
            LoyaltyCouponEligibility.AddErrorResponse('Invalid Search Value.');
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        LoyaltyCouponEligibility.SetDestination(OutStr);
        LoyaltyCouponEligibility.Export;

        ImportEntry.Imported := true;
        ImportEntry."Runtime Error" := false;

        ImportEntry.Modify(true);

    end;

    procedure CreateCoupon(var LoyaltyCreateCoupon: XMLport "NPR MM Loyalty Create Coup.")
    var
        TmpMemberInfoCapture: Record "NPR MM Member Info Capture" temporary;
        TmpLoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup" temporary;
        TmpLoyaltyPointsSetupEligible: Record "NPR MM Loyalty Point Setup" temporary;
        ImportEntry: Record "NPR Nc Import Entry";
        Coupon: Record "NPR NpDc Coupon";
        TmpCoupon: Record "NPR NpDc Coupon" temporary;
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
        OutStr: OutStream;
        ResponseMessage: Text;
        ResponseMessageId: Text;
        MembershipEntryNo: Integer;
    begin

        LoyaltyCreateCoupon.Import();

        InsertImportEntry('LoyaltyCreateCoupon', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo('LoyaltyCreateCoupon-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := true;
        ImportEntry.Modify(true);
        Commit();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        LoyaltyCreateCoupon.SetDestination(OutStr);
        LoyaltyCreateCoupon.Export;
        ImportEntry.Modify(true);
        Commit();

        // Process
        LoyaltyCreateCoupon.GetRequest(TmpMemberInfoCapture, TmpLoyaltyPointsSetup);
        if (TmpMemberInfoCapture."External Membership No." <> '') then
            MembershipEntryNo := MembershipManagement.GetMembershipFromExtMembershipNo(TmpMemberInfoCapture."External Membership No.");

        if (MembershipEntryNo > 0) then begin
            TmpLoyaltyPointsSetup.Reset();
            if (TmpLoyaltyPointsSetup.FindSet()) then begin
                repeat

                    // IF (LoyaltyPointsSetup.GET (TmpLoyaltyPointsSetup.Code, TmpLoyaltyPointsSetup."Line No.")) THEN BEGIN
                    TmpLoyaltyPointsSetupEligible.DeleteAll();
                    LoyaltyPointManagement.GetCouponToRedeemWS(MembershipEntryNo, TmpLoyaltyPointsSetupEligible, TmpMemberInfoCapture."Amount Incl VAT", ResponseMessage);
                    if (TmpLoyaltyPointsSetupEligible.Get(TmpLoyaltyPointsSetup.Code, TmpLoyaltyPointsSetup."Line No.")) then begin

                        TmpLoyaltyPointsSetup.TransferFields(TmpLoyaltyPointsSetupEligible, true);

                        //IF (Coupon.GET (LoyaltyPointManagement.IssueOneCoupon (MembershipEntryNo, TmpLoyaltyPointsSetup, TmpMemberInfoCapture."Amount Incl VAT"))) THEN BEGIN
                        with TmpMemberInfoCapture do
                            if (Coupon.Get(LoyaltyPointManagement.IssueOneCoupon(MembershipEntryNo, TmpLoyaltyPointsSetup, "Document No.", "Document Date", "Amount Incl VAT"))) then begin

                                TmpCoupon.TransferFields(Coupon, true);
                                TmpCoupon.Insert();
                            end;
                    end;
                until (TmpLoyaltyPointsSetup.Next() = 0);
            end;

            if (not TmpCoupon.IsEmpty()) then begin
                LoyaltyCreateCoupon.AddResponse(MembershipEntryNo, TmpCoupon, ResponseMessage);
                Commit();
            end else begin
                LoyaltyCreateCoupon.AddErrorResponse('No coupons created.');
            end;

        end else begin
            LoyaltyCreateCoupon.AddErrorResponse('Invalid Search Value.');
        end;

        // Log result
        ImportEntry."Document Source".CreateOutStream(OutStr);
        LoyaltyCreateCoupon.SetDestination(OutStr);
        LoyaltyCreateCoupon.Export;

        ImportEntry.Imported := true;
        ImportEntry."Runtime Error" := false;

        ImportEntry.Modify(true);
    end;

    procedure ListCoupons(var LoyaltyListCoupon: XMLport "NPR MM Loyalty List Coupon")
    var
        TmpMemberInfoCapture: Record "NPR MM Member Info Capture" temporary;
        ImportEntry: Record "NPR Nc Import Entry";
        Coupon: Record "NPR NpDc Coupon";
        TmpCoupon: Record "NPR NpDc Coupon" temporary;
        Membership: Record "NPR MM Membership";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        OutStr: OutStream;
        ResponseMessage: Text;
        ResponseMessageId: Text;
        MembershipEntryNo: Integer;
    begin

        LoyaltyListCoupon.Import();

        InsertImportEntry('LoyaltyListCoupon', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo('LoyaltyListCoupon-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := true;
        ImportEntry.Modify(true);
        Commit();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        LoyaltyListCoupon.SetDestination(OutStr);
        LoyaltyListCoupon.Export;
        ImportEntry.Modify(true);
        Commit();

        // Process
        LoyaltyListCoupon.GetRequest(TmpMemberInfoCapture);
        if (TmpMemberInfoCapture."External Membership No." <> '') then
            MembershipEntryNo := MembershipManagement.GetMembershipFromExtMembershipNo(TmpMemberInfoCapture."External Membership No.");

        if (MembershipEntryNo > 0) then begin

            if (Membership.Get(MembershipEntryNo)) then begin
                if (Membership."Customer No." <> '') then begin
                    Coupon.SetFilter("Customer No.", '=%1', Membership."Customer No.");
                    Coupon.SetFilter("Starting Date", '=%1|<=%2', 0DT, CurrentDateTime());
                    Coupon.SetFilter("Ending Date", '=%1|>=%2', 0DT, CurrentDateTime());
                    Coupon.SetAutoCalcFields("In-use Quantity", "Remaining Quantity");
                    if (Coupon.FindSet()) then begin
                        repeat
                            TmpCoupon.TransferFields(Coupon, true);
                            if (Coupon."In-use Quantity" < Coupon."Remaining Quantity") then
                                TmpCoupon.Insert();
                        until (Coupon.Next() = 0);
                    end;
                end;
            end;

            if (not TmpCoupon.IsEmpty()) then begin
                LoyaltyListCoupon.AddResponse(MembershipEntryNo, TmpCoupon, ResponseMessage);
                Commit();
            end else begin
                LoyaltyListCoupon.AddErrorResponse('No coupons available.');
            end;

        end else begin
            LoyaltyListCoupon.AddErrorResponse('Invalid Search Value.');
        end;

        // Log result
        ImportEntry."Document Source".CreateOutStream(OutStr);
        LoyaltyListCoupon.SetDestination(OutStr);
        LoyaltyListCoupon.Export;

        ImportEntry.Imported := true;
        ImportEntry."Runtime Error" := false;

        ImportEntry.Modify(true);

    end;

    local procedure "--Locals"()
    begin
    end;

    local procedure InsertImportEntry(WebserviceFunction: Text; var ImportEntry: Record "NPR Nc Import Entry")
    var
        NaviConnectSetupMgt: Codeunit "NPR Nc Setup Mgt.";
    begin
        ImportEntry.Init;
        ImportEntry."Entry No." := 0;
        ImportEntry."Import Type" := GetImportTypeCode(CODEUNIT::"NPR MM Loyalty WebService", WebserviceFunction);
        if (ImportEntry."Import Type" = '') then begin
            IntegrationSetup();
            ImportEntry."Import Type" := GetImportTypeCode(CODEUNIT::"NPR MM Loyalty WebService", WebserviceFunction);
            if (ImportEntry."Import Type" = '') then
                Error(SETUP_MISSING, WebserviceFunction);
        end;

        ImportEntry.Date := CurrentDateTime;
        ImportEntry."Document Name" := StrSubstNo('%1-%2.xml', ImportEntry."Import Type", Format(ImportEntry.Date, 0, 9));
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := false;
        ImportEntry.Insert(true);
    end;

    local procedure IntegrationSetup()
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        ImportType.SetFilter("Webservice Codeunit ID", '=%1', CODEUNIT::"NPR MM Loyalty WebService");
        if (not ImportType.IsEmpty()) then
            ImportType.DeleteAll();

        CreateImportType('LOYALTY-01', 'LoyaltyManagement', 'GetLoyaltyPoints');
        CreateImportType('LOYALTY-02', 'LoyaltyManagement', 'GetLoyaltyPointEntries');
        CreateImportType('LOYALTY-03', 'LoyaltyManagement', 'LoyaltyCouponEligibility');
        CreateImportType('LOYALTY-04', 'LoyaltyManagement', 'LoyaltyCreateCoupon');

        CreateImportType('LOYALTY-05', 'LoyaltyManagement', 'GetLoyaltyReceiptList');
        CreateImportType('LOYALTY-06', 'LoyaltyManagement', 'LoyaltyListCoupon');

        CreateImportType('POINTS-01', 'PointManagement', 'RegisterSale');
        CreateImportType('POINTS-02', 'PointManagement', 'ReservePoints');
        CreateImportType('POINTS-03', 'PointManagement', 'GetLoyaltyConfiguration');

        Commit();
    end;

    local procedure CreateImportType("Code": Code[20]; Description: Text[30]; FunctionName: Text[30])
    var
        ImportType: Record "NPR Nc Import Type";
    begin

        ImportType.Code := Code;
        ImportType.Description := Description;
        ImportType."Webservice Function" := FunctionName;

        ImportType."Webservice Enabled" := true;
        ImportType."Import Codeunit ID" := CODEUNIT::"NPR MM Loyalty WebService Mgr";
        ImportType."Webservice Codeunit ID" := CODEUNIT::"NPR MM Loyalty WebService";

        ImportType.Insert();
    end;

    local procedure GetImportTypeCode(WebServiceCodeunitID: Integer; WebserviceFunction: Text): Code[10]
    var
        ImportType: Record "NPR Nc Import Type";
    begin

        Clear(ImportType);
        ImportType.SetRange("Webservice Codeunit ID", WebServiceCodeunitID);
        ImportType.SetFilter("Webservice Function", '%1', CopyStr(WebserviceFunction, 1, MaxStrLen(ImportType."Webservice Function")));

        if ImportType.FindFirst then
            exit(ImportType.Code);

        exit('');
    end;

    local procedure GetBase64(Filename: Text) Value: Text
    var
        TempBlob: Codeunit "Temp Blob";
        BinaryReader: DotNet NPRNetBinaryReader;
        MemoryStream: DotNet NPRNetMemoryStream;
        Convert: DotNet NPRNetConvert;
        FieldRef: FieldRef;
        InStr: InStream;
        f: File;
    begin

        Value := '';

        f.Open(Filename);
        f.CreateInStream(InStr);
        MemoryStream := InStr;
        BinaryReader := BinaryReader.BinaryReader(InStr);

        Value := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));

        MemoryStream.Dispose;
        Clear(MemoryStream);
        f.Close;
        exit(Value);

    end;
}

