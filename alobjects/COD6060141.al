codeunit 6060141 "MM Loyalty WebService"
{
    // MM1.19/NPKNAV/20170525  CASE 274690 Transport MM1.20 - 25 May 2017
    // MM1.37/TSA /20190204 CASE 338215 Points for payment, RegisterSale(), ReservePoints()
    // MM1.38/TSA /20190523 CASE 338215 Added Service GetLoyaltyConfiguration
    // MM1.40/TSA /20190813 CASE 343352 Added GetCouponEligibility(), TransformPointsToCoupon()
    // MM1.40/TSA /20190828 CASE 365879 Added ReceiptList and Receipt as PDF
    // MM1.42/TSA /20191024 CASE 374403 Changed signature on IssueOneCoupon(), IssueOneCouponAndPrint(), and IssueCoupon()
    // MM1.43/TSA /20200113 CASE 370398 Added the ListCoupons() service
    // MM1.43/TSA /20200123 CASE 387009 Fixed an initialization issue with CreateCoupon()
    // MM1.43/MHA /20200217 CASE 390998 Added default report in GetMembershipReceiptPdf()
    // MM1.45/TSA /20200612 CASE 404908 Added language selection from user personalization


    trigger OnRun()
    begin
    end;

    var
        SETUP_MISSING: Label 'Setup is missing for %1.';

    [Scope('Personalization')]
    procedure GetLoyaltyPoints(var GetLoyaltyPoints: XMLport "MM Get Loyalty Points")
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "MM Member Info Capture";
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

    [Scope('Personalization')]
    procedure GetLoyaltyPointEntries(var GetLoyaltyStatement: XMLport "MM Get Loyalty Statement")
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "MM Member Info Capture";
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

    [Scope('Personalization')]
    procedure GetMembershipReceiptList(var GetLoyaltyReceiptList: XMLport "MM Get Loyalty Receipt List")
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "MM Member Info Capture";
    begin

        //-MM1.40 [365879]
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
        //+MM1.40 [365879]
    end;

    [Scope('Personalization')]
    procedure GetMembershipReceiptPdf(ExternalMembershipNumber: Code[20]; ReceiptEntryNo: Integer) PdfDoc: Text
    var
        ReportSelections: Record "Report Selection Retail";
        POSEntry: Record "POS Entry";
        Membership: Record "MM Membership";
        UserPersonalization: Record "User Personalization";
        Filename: Text;
        LanguageId: Integer;
    begin

        //-MM1.40 [365879]
        ReportSelections.SetFilter("Report Type", '=%1', ReportSelections."Report Type"::"Large Sales Receipt (POS Entry)");
        ReportSelections.SetFilter("Report ID", '<>%1', 0);
        //-MM1.43 [390998]
        //ReportSelections.FINDFIRST;
        if not ReportSelections.FindFirst then
            ReportSelections."Report ID" := REPORT::"Sales Ticket A4 - POS Rdlc";
        //+MM1.43 [390998]

        Membership.SetFilter("External Membership No.", '=%1', ExternalMembershipNumber);
        Membership.FindFirst();
        Membership.TestField("Customer No.");

        POSEntry.Get(ReceiptEntryNo);
        POSEntry.TestField("Customer No.", Membership."Customer No.");
        POSEntry.SetRecFilter;

        Filename := TemporaryPath + 'Receipt-' + Format(ReceiptEntryNo, 0, 9) + '.pdf';

        //-MM1.45 [404908]
        UserPersonalization.SetFilter ("User ID", '%1', UserId);
        if (UserPersonalization.FindFirst ()) then
          LanguageId := GlobalLanguage (UserPersonalization."Language ID");
        //+MM1.45 [404908]

        REPORT.SaveAsPdf(ReportSelections."Report ID", Filename, POSEntry);

        //-MM1.45 [404908]
        if (LanguageId <> 0) then
          GlobalLanguage (LanguageId);
        //+MM1.45 [404908]

        PdfDoc := GetBase64(Filename);
        if Erase(Filename) then;

        exit(PdfDoc);
    end;

    local procedure "*** LoyaltyServerFunctions ***"()
    begin
    end;

    [Scope('Personalization')]
    procedure RegisterSale(var RegisterSale: XMLport "MM Register Sale")
    var
        TmpAuthorization: Record "MM Loyalty Ledger Entry (Srvr)" temporary;
        TmpSalesLines: Record "MM Register Sales Buffer" temporary;
        TmpPaymentLines: Record "MM Register Sales Buffer" temporary;
        TmpPointsResponse: Record "MM Loyalty Ledger Entry (Srvr)" temporary;
        ImportEntry: Record "Nc Import Entry";
        OutStr: OutStream;
        LoyaltyWebServiceMgr: Codeunit "MM Loyalty WebService Mgr";
        LoyaltyPointsMgrServer: Codeunit "MM Loyalty Points Mgr (Server)";
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

    [Scope('Personalization')]
    procedure ReservePoints(var ReservePoints: XMLport "MM Reserve Points")
    var
        TmpAuthorization: Record "MM Loyalty Ledger Entry (Srvr)" temporary;
        TmpPaymentLines: Record "MM Register Sales Buffer" temporary;
        TmpPointsResponse: Record "MM Loyalty Ledger Entry (Srvr)" temporary;
        ImportEntry: Record "Nc Import Entry";
        OutStr: OutStream;
        LoyaltyWebServiceMgr: Codeunit "MM Loyalty WebService Mgr";
        LoyaltyPointsMgrServer: Codeunit "MM Loyalty Points Mgr (Server)";
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

    [Scope('Personalization')]
    procedure GetLoyaltyConfiguration(var GetLoyaltyConfiguration: XMLport "MM Get Loyalty Configuration")
    var
        TmpAuthorization: Record "MM Loyalty Ledger Entry (Srvr)" temporary;
        TmpLoyaltySetup: Record "MM Loyalty Setup" temporary;
        ImportEntry: Record "Nc Import Entry";
        OutStr: OutStream;
        LoyaltyWebServiceMgr: Codeunit "MM Loyalty WebService Mgr";
        LoyaltyPointsMgrServer: Codeunit "MM Loyalty Points Mgr (Server)";
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

    [Scope('Personalization')]
    procedure GetCouponEligibility(var LoyaltyCouponEligibility: XMLport "MM Loyalty Coupon Eligibility")
    var
        TmpLoyaltyPointsSetup: Record "MM Loyalty Points Setup" temporary;
        TmpMemberInfoCapture: Record "MM Member Info Capture" temporary;
        MembershipEntryNo: Integer;
        ImportEntry: Record "Nc Import Entry";
        MembershipManagement: Codeunit "MM Membership Management";
        OutStr: OutStream;
        LoyaltyPointManagement: Codeunit "MM Loyalty Point Management";
        ResponseMessage: Text;
        ResponseMessageId: Text;
    begin

        //-MM1.40 [343352]
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
        //+MM1.40 [343352]
    end;

    [Scope('Personalization')]
    procedure CreateCoupon(var LoyaltyCreateCoupon: XMLport "MM Loyalty Create Coupon")
    var
        TmpMemberInfoCapture: Record "MM Member Info Capture" temporary;
        TmpLoyaltyPointsSetup: Record "MM Loyalty Points Setup" temporary;
        TmpLoyaltyPointsSetupEligible: Record "MM Loyalty Points Setup" temporary;
        ImportEntry: Record "Nc Import Entry";
        Coupon: Record "NpDc Coupon";
        TmpCoupon: Record "NpDc Coupon" temporary;
        MembershipManagement: Codeunit "MM Membership Management";
        LoyaltyPointManagement: Codeunit "MM Loyalty Point Management";
        OutStr: OutStream;
        ResponseMessage: Text;
        ResponseMessageId: Text;
        MembershipEntryNo: Integer;
    begin

        //-MM1.40 [343352]
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

                    //-MM1.43 [387009]
                    // IF (LoyaltyPointsSetup.GET (TmpLoyaltyPointsSetup.Code, TmpLoyaltyPointsSetup."Line No.")) THEN BEGIN
                    TmpLoyaltyPointsSetupEligible.DeleteAll();
                    LoyaltyPointManagement.GetCouponToRedeemWS(MembershipEntryNo, TmpLoyaltyPointsSetupEligible, TmpMemberInfoCapture."Amount Incl VAT", ResponseMessage);
                    if (TmpLoyaltyPointsSetupEligible.Get(TmpLoyaltyPointsSetup.Code, TmpLoyaltyPointsSetup."Line No.")) then begin
                        //+MM1.43 [387009]

                        TmpLoyaltyPointsSetup.TransferFields(TmpLoyaltyPointsSetupEligible, true);
                        //-MM1.42 [374403]
                        //IF (Coupon.GET (LoyaltyPointManagement.IssueOneCoupon (MembershipEntryNo, TmpLoyaltyPointsSetup, TmpMemberInfoCapture."Amount Incl VAT"))) THEN BEGIN
                        with TmpMemberInfoCapture do
                            if (Coupon.Get(LoyaltyPointManagement.IssueOneCoupon(MembershipEntryNo, TmpLoyaltyPointsSetup, "Document No.", "Document Date", "Amount Incl VAT"))) then begin
                                //+MM1.42 [374403]
                                TmpCoupon.TransferFields(Coupon, true);
                                TmpCoupon.Insert();
                            end;
                    end;
                until (TmpLoyaltyPointsSetup.Next() = 0);
            end;

            if (not TmpCoupon.IsEmpty()) then begin
                LoyaltyCreateCoupon.AddResponse(MembershipEntryNo, TmpCoupon, ResponseMessage);
                Commit;
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

    [Scope('Personalization')]
    procedure ListCoupons(var LoyaltyListCoupon: XMLport "MM Loyalty List Coupon")
    var
        TmpMemberInfoCapture: Record "MM Member Info Capture" temporary;
        ImportEntry: Record "Nc Import Entry";
        Coupon: Record "NpDc Coupon";
        TmpCoupon: Record "NpDc Coupon" temporary;
        Membership: Record "MM Membership";
        MembershipManagement: Codeunit "MM Membership Management";
        OutStr: OutStream;
        ResponseMessage: Text;
        ResponseMessageId: Text;
        MembershipEntryNo: Integer;
    begin

        //-MM1.43 [370398]
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
                Commit;
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
        //+MM1.43 [370398]
    end;

    local procedure "--Locals"()
    begin
    end;

    local procedure InsertImportEntry(WebserviceFunction: Text; var ImportEntry: Record "Nc Import Entry")
    var
        NaviConnectSetupMgt: Codeunit "Nc Setup Mgt.";
    begin
        ImportEntry.Init;
        ImportEntry."Entry No." := 0;
        ImportEntry."Import Type" := GetImportTypeCode(CODEUNIT::"MM Loyalty WebService", WebserviceFunction);
        if (ImportEntry."Import Type" = '') then begin
            IntegrationSetup();
            ImportEntry."Import Type" := GetImportTypeCode(CODEUNIT::"MM Loyalty WebService", WebserviceFunction);
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
        ImportType: Record "Nc Import Type";
    begin
        ImportType.SetFilter("Webservice Codeunit ID", '=%1', CODEUNIT::"MM Loyalty WebService");
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

        Commit;
    end;

    local procedure CreateImportType("Code": Code[20]; Description: Text[30]; FunctionName: Text[30])
    var
        ImportType: Record "Nc Import Type";
    begin

        ImportType.Code := Code;
        ImportType.Description := Description;
        ImportType."Webservice Function" := FunctionName;

        ImportType."Webservice Enabled" := true;
        ImportType."Import Codeunit ID" := CODEUNIT::"MM Loyalty WebService Mgr";
        ImportType."Webservice Codeunit ID" := CODEUNIT::"MM Loyalty WebService";

        ImportType.Insert();
    end;

    local procedure GetImportTypeCode(WebServiceCodeunitID: Integer; WebserviceFunction: Text): Code[10]
    var
        ImportType: Record "Nc Import Type";
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
        BinaryReader: DotNet npNetBinaryReader;
        MemoryStream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
        FieldRef: FieldRef;
        InStr: InStream;
        f: File;
    begin

        //-MM1.40 [365879]
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
        //+MM1.40 [365879]
    end;
}

