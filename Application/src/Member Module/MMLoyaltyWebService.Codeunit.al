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
        FileNameLbl: Label 'GetLoyaltyPoints-%1.xml', Locked = true;
    begin
        GetLoyaltyPoints.Import();

        InsertImportEntry('GetLoyaltyPoints', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        GetLoyaltyPoints.SetDestination(OutStr);
        GetLoyaltyPoints.Export();
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
        GetLoyaltyPoints.Export();
        ImportEntry.Modify(true);

        MemberInfoCapture.DeleteAll();
    end;

    procedure GetLoyaltyPointEntries(var GetLoyaltyStatement: XMLport "NPR MM Get Loy. Statement")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        FileNameLbl: Label 'GetLoyaltyPointEntries-%1.xml', Locked = true;
    begin
        GetLoyaltyStatement.Import();

        InsertImportEntry('GetLoyaltyPointEntries', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        GetLoyaltyStatement.SetDestination(OutStr);
        GetLoyaltyStatement.Export();
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
        GetLoyaltyStatement.Export();
        ImportEntry.Modify(true);

        MemberInfoCapture.DeleteAll();
    end;

    procedure GetMembershipReceiptList(var GetLoyaltyReceiptList: XMLport "NPR MM Get Loyalty Rcpt. List")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        FileNameLbl: Label 'GetLoyaltyReceiptList-%1.xml', Locked = true;
    begin

        GetLoyaltyReceiptList.Import();

        InsertImportEntry('GetLoyaltyReceiptList', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        GetLoyaltyReceiptList.SetDestination(OutStr);
        GetLoyaltyReceiptList.Export();
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
        GetLoyaltyReceiptList.Export();
        ImportEntry.Modify(true);

        MemberInfoCapture.DeleteAll();

    end;

    procedure GetMembershipReceiptPdf(ExternalMembershipNumber: Code[20]; ReceiptEntryNo: Integer) PdfDoc: Text
    var
        ReportSelections: Record "NPR Report Selection Retail";
        POSEntry: Record "NPR POS Entry";
        Membership: Record "NPR MM Membership";
        UserPersonalization: Record "User Personalization";
        LanguageId: Integer;
        RecRef: RecordRef;
        TempBlob: Codeunit "Temp Blob";
        oStream: OutStream;
        Instr: InStream;
        Base64Convert: Codeunit "Base64 Convert";
    begin

        ReportSelections.SetFilter("Report Type", '=%1', ReportSelections."Report Type"::"Large Sales Receipt (POS Entry)");
        ReportSelections.SetFilter("Report ID", '<>%1', 0);

        if (not ReportSelections.FindFirst()) then
            ReportSelections."Report ID" := REPORT::"NPR Sales Ticket A4 - POS Rdlc";

        Membership.SetFilter("External Membership No.", '=%1', ExternalMembershipNumber);
        Membership.FindFirst();
        Membership.TestField("Customer No.");

        POSEntry.Get(ReceiptEntryNo);
        POSEntry.TestField("Customer No.", Membership."Customer No.");
        POSEntry.SetRecFilter();
        RecRef.GetTable(POSEntry);

        UserPersonalization.SetFilter("User ID", '%1', UserId);
        if (UserPersonalization.FindFirst()) then
            LanguageId := GlobalLanguage(UserPersonalization."Language ID");

        TempBlob.CreateOutStream(oStream);
        Report.SaveAs(ReportSelections."Report ID", '', ReportFormat::Pdf, oStream, RecRef);
        TempBlob.CreateInStream(Instr);
        if (LanguageId <> 0) then
            GlobalLanguage(LanguageId);

        PdfDoc := Base64Convert.ToBase64(Instr);

        exit(PdfDoc);
    end;

    procedure RegisterSale(var RegisterSale: XMLport "NPR MM Register Sale")
    var
        TempAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        TempSalesLines: Record "NPR MM Reg. Sales Buffer" temporary;
        TempPaymentLines: Record "NPR MM Reg. Sales Buffer" temporary;
        TempPointsResponse: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        ImportEntry: Record "NPR Nc Import Entry";
        OutStr: OutStream;
        LoyaltyPointsMgrServer: Codeunit "NPR MM Loy. Point Mgr (Server)";
        ResponseMessage: Text;
        ResponseMessageId: Text;
        FileNameLbl: Label 'RegisterSale-%1.xml', Locked = true;
    begin

        RegisterSale.Import();

        InsertImportEntry('RegisterSale', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();
        ImportEntry.Modify(true);
        Commit();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        RegisterSale.SetDestination(OutStr);
        RegisterSale.Export();
        ImportEntry.Modify(true);
        Commit();

        // Process
        RegisterSale.SetDocumentId := ImportEntry."Document ID";
        RegisterSale.GetRequest(TempAuthorization, TempSalesLines, TempPaymentLines);
        if (LoyaltyPointsMgrServer.RegisterSales(TempAuthorization, TempSalesLines, TempPaymentLines, TempPointsResponse, ResponseMessage, ResponseMessageId)) then begin
            RegisterSale.SetResponse(TempPointsResponse);

            ImportEntry.Imported := true;
            ImportEntry."Runtime Error" := false;
        end else begin
            RegisterSale.SetErrorResponse(ResponseMessage, ResponseMessageId);

            ImportEntry.Imported := true;
            ImportEntry."Runtime Error" := true;
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        RegisterSale.SetDestination(OutStr);
        RegisterSale.Export();

        ImportEntry.Imported := true;
        ImportEntry."Runtime Error" := false;

        ImportEntry.Modify(true);
    end;

    procedure ReservePoints(var ReservePoints: XMLport "NPR MM Reserve Points")
    var
        TempAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        TempPaymentLines: Record "NPR MM Reg. Sales Buffer" temporary;
        TempPointsResponse: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        ImportEntry: Record "NPR Nc Import Entry";
        OutStr: OutStream;
        LoyaltyPointsMgrServer: Codeunit "NPR MM Loy. Point Mgr (Server)";
        ResponseMessage: Text;
        ResponseMessageId: Text;
        FileNameLbl: Label 'ReservePoints-%1.xml', Locked = true;
    begin

        ReservePoints.Import();

        InsertImportEntry('ReservePoints', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();
        ImportEntry.Modify(true);
        Commit();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        ReservePoints.SetDestination(OutStr);
        ReservePoints.Export();
        ImportEntry.Modify(true);
        Commit();

        // Process
        ReservePoints.SetDocumentId := ImportEntry."Document ID";
        ReservePoints.GetRequest(TempAuthorization, TempPaymentLines);
        if (LoyaltyPointsMgrServer.ReservePoints(TempAuthorization, TempPaymentLines, TempPointsResponse, ResponseMessage, ResponseMessageId)) then begin
            ReservePoints.SetResponse(TempPointsResponse);

            ImportEntry.Imported := true;
            ImportEntry."Runtime Error" := false;
        end else begin
            ReservePoints.SetErrorResponse(ResponseMessage, ResponseMessageId);

            ImportEntry.Imported := true;
            ImportEntry."Runtime Error" := true;
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        ReservePoints.SetDestination(OutStr);
        ReservePoints.Export();

        ImportEntry.Imported := true;
        ImportEntry."Runtime Error" := false;

        ImportEntry.Modify(true);
    end;

    procedure GetLoyaltyConfiguration(var GetLoyaltyConfiguration: XMLport "NPR MM Get Loyalty Config.")
    var
        TempAuthorization: Record "NPR MM Loy. LedgerEntry (Srvr)" temporary;
        TempLoyaltySetup: Record "NPR MM Loyalty Setup" temporary;
        ImportEntry: Record "NPR Nc Import Entry";
        OutStr: OutStream;
        LoyaltyPointsMgrServer: Codeunit "NPR MM Loy. Point Mgr (Server)";
        ResponseMessage: Text;
        ResponseMessageId: Text;
        FileNameLbl: Label 'GetLoyaltyConfiguration-%1.xml', Locked = true;
    begin

        GetLoyaltyConfiguration.Import();

        InsertImportEntry('GetLoyaltyConfiguration', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();
        ImportEntry.Modify(true);
        Commit();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        GetLoyaltyConfiguration.SetDestination(OutStr);
        GetLoyaltyConfiguration.Export();
        ImportEntry.Modify(true);
        Commit();

        // Process
        GetLoyaltyConfiguration.SetDocumentId := ImportEntry."Document ID";
        GetLoyaltyConfiguration.GetRequest(TempAuthorization);

        if (LoyaltyPointsMgrServer.GetLoyaltySetup(TempAuthorization, TempLoyaltySetup, ResponseMessage, ResponseMessageId)) then begin
            GetLoyaltyConfiguration.SetResponse(TempLoyaltySetup);

            ImportEntry.Imported := true;
            ImportEntry."Runtime Error" := false;
        end else begin
            GetLoyaltyConfiguration.SetErrorResponse(ResponseMessage, ResponseMessageId);

            ImportEntry.Imported := true;
            ImportEntry."Runtime Error" := true;
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        GetLoyaltyConfiguration.SetDestination(OutStr);
        GetLoyaltyConfiguration.Export();

        ImportEntry.Imported := true;
        ImportEntry."Runtime Error" := false;

        ImportEntry.Modify(true);
    end;

    procedure GetCouponEligibility(var LoyaltyCouponEligibility: XMLport "NPR MM Loyalty Coupon Elig.")
    var
        TempLoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup" temporary;
        TempMemberInfoCapture: Record "NPR MM Member Info Capture" temporary;
        MembershipEntryNo: Integer;
        ImportEntry: Record "NPR Nc Import Entry";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        OutStr: OutStream;
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
        ResponseMessage: Text;
        FileNameLbl: Label 'LoyaltyCouponEligibility-%1.xml', Locked = true;
    begin

        LoyaltyCouponEligibility.Import();

        InsertImportEntry('LoyaltyCouponEligibility', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();
        ImportEntry."Runtime Error" := true;
        ImportEntry.Modify(true);
        Commit();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        LoyaltyCouponEligibility.SetDestination(OutStr);
        LoyaltyCouponEligibility.Export();
        ImportEntry.Modify(true);
        Commit();

        // Process
        LoyaltyCouponEligibility.GetRequest(TempMemberInfoCapture);
        if (TempMemberInfoCapture."External Card No." <> '') then
            MembershipEntryNo := MembershipManagement.GetMembershipFromExtCardNo(TempMemberInfoCapture."External Card No.", Today, ResponseMessage);

        if (TempMemberInfoCapture."External Membership No." <> '') then
            MembershipEntryNo := MembershipManagement.GetMembershipFromExtMembershipNo(TempMemberInfoCapture."External Membership No.");

        if (TempMemberInfoCapture."Document No." <> '') then
            MembershipEntryNo := MembershipManagement.GetMembershipFromCustomerNo(TempMemberInfoCapture."Document No.");

        if (MembershipEntryNo > 0) then begin
            LoyaltyPointManagement.GetCouponToRedeemWS(MembershipEntryNo, TempLoyaltyPointsSetup, TempMemberInfoCapture."Amount Incl VAT", ResponseMessage);
            LoyaltyCouponEligibility.AddResponse(MembershipEntryNo, TempLoyaltyPointsSetup, ResponseMessage);

        end else begin
            LoyaltyCouponEligibility.AddErrorResponse('Invalid Search Value.');
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        LoyaltyCouponEligibility.SetDestination(OutStr);
        LoyaltyCouponEligibility.Export();

        ImportEntry.Imported := true;
        ImportEntry."Runtime Error" := false;

        ImportEntry.Modify(true);

    end;

    procedure CreateCoupon(var LoyaltyCreateCoupon: XMLport "NPR MM Loyalty Create Coup.")
    var
        TempMemberInfoCapture: Record "NPR MM Member Info Capture" temporary;
        TempLoyaltyPointsSetup: Record "NPR MM Loyalty Point Setup" temporary;
        TempLoyaltyPointsSetupEligible: Record "NPR MM Loyalty Point Setup" temporary;
        ImportEntry: Record "NPR Nc Import Entry";
        Coupon: Record "NPR NpDc Coupon";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
        OutStr: OutStream;
        ResponseMessage: Text;
        MembershipEntryNo: Integer;
        FileNameLbl: Label 'LoyaltyCreateCoupon-%1.xml', Locked = true;
    begin

        LoyaltyCreateCoupon.Import();

        InsertImportEntry('LoyaltyCreateCoupon', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := true;
        ImportEntry."Import Started at" := CurrentDateTime;
        ImportEntry.Modify(true);
        Commit();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        LoyaltyCreateCoupon.SetDestination(OutStr);
        LoyaltyCreateCoupon.Export();
        ImportEntry.Modify(true);
        Commit();

        // Process
        LoyaltyCreateCoupon.GetRequest(TempMemberInfoCapture, TempLoyaltyPointsSetup);
        if (TempMemberInfoCapture."External Membership No." <> '') then
            MembershipEntryNo := MembershipManagement.GetMembershipFromExtMembershipNo(TempMemberInfoCapture."External Membership No.");

        if (MembershipEntryNo > 0) then begin
            TempLoyaltyPointsSetup.Reset();
            if (TempLoyaltyPointsSetup.FindSet()) then begin
                repeat

                    TempLoyaltyPointsSetupEligible.DeleteAll();
                    LoyaltyPointManagement.GetCouponToRedeemWS(MembershipEntryNo, TempLoyaltyPointsSetupEligible, TempMemberInfoCapture."Amount Incl VAT", ResponseMessage);
                    if (TempLoyaltyPointsSetupEligible.Get(TempLoyaltyPointsSetup.Code, TempLoyaltyPointsSetup."Line No.")) then begin

                        TempLoyaltyPointsSetup.TransferFields(TempLoyaltyPointsSetupEligible, true);

                        if (Coupon.Get(LoyaltyPointManagement.IssueOneCoupon(MembershipEntryNo, TempLoyaltyPointsSetup, TempMemberInfoCapture."Document No.", TempMemberInfoCapture."Document Date", TempMemberInfoCapture."Amount Incl VAT"))) then begin

                            TempCoupon.TransferFields(Coupon, true);
                            TempCoupon.Insert();
                        end;
                    end;
                until (TempLoyaltyPointsSetup.Next() = 0);
            end;

            if (not TempCoupon.IsEmpty()) then begin
                LoyaltyCreateCoupon.AddResponse(MembershipEntryNo, TempCoupon, ResponseMessage);
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
        LoyaltyCreateCoupon.Export();

        ImportEntry.Imported := true;
        ImportEntry."Runtime Error" := false;
        ImportEntry."Import Completed at" := CurrentDateTime();
        ImportEntry."Import Duration" := ImportEntry."Import Completed at" - ImportEntry."Import Started at";
        ImportEntry.Modify(true);
    end;

    procedure ListCoupons(var LoyaltyListCoupon: XMLport "NPR MM Loyalty List Coupon")
    var
        TempMemberInfoCapture: Record "NPR MM Member Info Capture" temporary;
        ImportEntry: Record "NPR Nc Import Entry";
        Coupon: Record "NPR NpDc Coupon";
        TempCoupon: Record "NPR NpDc Coupon" temporary;
        Membership: Record "NPR MM Membership";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        OutStr: OutStream;
        ResponseMessage: Text;
        MembershipEntryNo: Integer;
        FileNameLbl: Label 'LoyaltyListCoupon-%1.xml', Locked = true;
    begin

        LoyaltyListCoupon.Import();

        InsertImportEntry('LoyaltyListCoupon', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := true;
        ImportEntry."Import Started at" := CurrentDateTime();
        ImportEntry.Modify(true);
        Commit();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        LoyaltyListCoupon.SetDestination(OutStr);
        LoyaltyListCoupon.Export();
        ImportEntry.Modify(true);
        Commit();

        // Process
        LoyaltyListCoupon.GetRequest(TempMemberInfoCapture);
        if (TempMemberInfoCapture."External Membership No." <> '') then
            MembershipEntryNo := MembershipManagement.GetMembershipFromExtMembershipNo(TempMemberInfoCapture."External Membership No.");

        if (MembershipEntryNo > 0) then begin

            if (Membership.Get(MembershipEntryNo)) then begin
                if (Membership."Customer No." <> '') then begin
                    Coupon.SetFilter("Customer No.", '=%1', Membership."Customer No.");
                    Coupon.SetFilter("Starting Date", '=%1|<=%2', 0DT, CurrentDateTime());
                    Coupon.SetFilter("Ending Date", '=%1|>=%2', 0DT, CurrentDateTime());
                    Coupon.SetAutoCalcFields("In-use Quantity", "Remaining Quantity");
                    if (Coupon.FindSet()) then begin
                        repeat
                            TempCoupon.TransferFields(Coupon, true);
                            if (Coupon."In-use Quantity" < Coupon."Remaining Quantity") then
                                TempCoupon.Insert();
                        until (Coupon.Next() = 0);
                    end;
                end;
            end;

            if (not TempCoupon.IsEmpty()) then begin
                LoyaltyListCoupon.AddResponse(MembershipEntryNo, TempCoupon, ResponseMessage);
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
        LoyaltyListCoupon.Export();

        ImportEntry.Imported := true;
        ImportEntry."Runtime Error" := false;
        ImportEntry."Import Completed at" := CurrentDateTime();
        ImportEntry."Import Duration" := ImportEntry."Import Completed at" - ImportEntry."Import Started at";
        ImportEntry.Modify(true);

    end;

    procedure DeleteCoupon(var LoyaltyDeleteCoupon: XMLport "NPR MM Loyalty Delete Coupont");
    var
        ImportEntry: Record "NPR Nc Import Entry";
        Coupon: Record "NPR NpDc Coupon";
        Membership: Record "NPR MM Membership";
        NpDcSaleLinePOSCoupon: Record "NPR NpDc SaleLinePOS Coupon";
        NpDcExtCouponReservation: Record "NPR NpDc Ext. Coupon Reserv.";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
        OutStr: OutStream;
        MembershipEntryNo: Integer;
        ExternalMembershipNo: Code[20];
        CouponReferenceNo: Text[30];
        CurrSaleCouponCount: Integer;
        FileNameLbl: Label 'LoyaltyDeleteCoupon-%1.xml', Locked = true;
    begin

        LoyaltyDeleteCoupon.Import();

        InsertImportEntry('LoyaltyDeleteCoupon', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := true;
        ImportEntry."Import Started at" := CurrentDateTime();
        ImportEntry.Modify(true);
        Commit();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        LoyaltyDeleteCoupon.SetDestination(OutStr);
        LoyaltyDeleteCoupon.Export();
        ImportEntry.Modify(true);
        Commit();

        // Process
        LoyaltyDeleteCoupon.GetRequest(ExternalMembershipNo, CouponReferenceNo);

        if (ExternalMembershipNo <> '') then
            MembershipEntryNo := MembershipManagement.GetMembershipFromExtMembershipNo(ExternalMembershipNo);

        if (MembershipEntryNo > 0) then begin

            if (Membership.Get(MembershipEntryNo)) then begin
                if (Membership."Customer No." <> '') then begin
                    Coupon.SetFilter("Customer No.", '=%1', Membership."Customer No.");
                    Coupon.SetFilter("Starting Date", '=%1|<=%2', 0DT, CurrentDateTime());
                    Coupon.SetFilter("Ending Date", '=%1|>=%2', 0DT, CurrentDateTime());
                    Coupon.SetFilter("Reference No.", '=%1', CouponReferenceNo);
                    Coupon.SETAUTOCALCFIELDS("In-use Quantity", "Remaining Quantity");
                    if (Coupon.FindFirst()) then begin

                        NpDcSaleLinePOSCoupon.SetFilter(Type, '=%1', NpDcSaleLinePOSCoupon.Type::Coupon);
                        NpDcSaleLinePOSCoupon.SetFilter("Coupon No.", '=%1', Coupon."No.");
                        CurrSaleCouponCount := NpDcSaleLinePOSCoupon.Count();

                        NpDcExtCouponReservation.SetFilter("Coupon No.", '=%1', Coupon."No.");
                        CurrSaleCouponCount += NpDcExtCouponReservation.Count();

                        if (CurrSaleCouponCount > 0) then begin
                            LoyaltyDeleteCoupon.AddErrorResponse('Coupon has been applied to a sale, coupon reservation must be cancelled before it can be deleted.');

                        end else begin
                            if (LoyaltyPointManagement.UnRedeemPointsCoupon(0, '', TODAY, Coupon."No.")) then begin
                                Coupon.Delete();
                                LoyaltyDeleteCoupon.AddResponse('');
                                Commit();
                            end;
                        end;

                    end else begin
                        LoyaltyDeleteCoupon.AddErrorResponse('Invalid coupon reference.');
                    end;
                end;
            end;

        end else begin
            LoyaltyDeleteCoupon.AddErrorResponse('Invalid Search Value.');
        end;

        // Log result
        ImportEntry."Document Source".CreateOutStream(OutStr);
        LoyaltyDeleteCoupon.SetDestination(OutStr);
        LoyaltyDeleteCoupon.Export();

        ImportEntry.Imported := true;
        ImportEntry."Runtime Error" := false;
        ImportEntry."Import Completed at" := CurrentDateTime();
        ImportEntry."Import Duration" := ImportEntry."Import Completed at" - ImportEntry."Import Started at";
        ImportEntry.Modify(true);

    end;

    local procedure InsertImportEntry(WebserviceFunction: Text; var ImportEntry: Record "NPR Nc Import Entry")
    var
        FileNameLbl: Label '%1-%2.xml', Locked = true;
    begin
        ImportEntry.Init();
        ImportEntry."Entry No." := 0;
        ImportEntry."Import Type" := GetImportTypeCode(CODEUNIT::"NPR MM Loyalty WebService", WebserviceFunction);
        if (ImportEntry."Import Type" = '') then begin
            IntegrationSetup();
            ImportEntry."Import Type" := GetImportTypeCode(CODEUNIT::"NPR MM Loyalty WebService", WebserviceFunction);
            if (ImportEntry."Import Type" = '') then
                Error(SETUP_MISSING, WebserviceFunction);
        end;

        ImportEntry.Date := CurrentDateTime;
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, ImportEntry."Import Type", Format(ImportEntry.Date, 0, 9));
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
        CreateImportType('LOYALTY-07', 'LoyaltyManagement', 'LoyaltyDeleteCoupon');

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

    local procedure GetImportTypeCode(WebServiceCodeunitID: Integer; WebserviceFunction: Text): Code[20]
    var
        ImportType: Record "NPR Nc Import Type";
    begin

        Clear(ImportType);
        ImportType.SetRange("Webservice Codeunit ID", WebServiceCodeunitID);
        ImportType.SetFilter("Webservice Function", '%1', CopyStr(WebserviceFunction, 1, MaxStrLen(ImportType."Webservice Function")));

        if (ImportType.FindFirst()) then
            exit(ImportType.Code);

        exit('');
    end;

#pragma warning disable AA0139
    local procedure CreateDocumentId(): Text[50]
    begin
        exit(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')));
    end;
#pragma warning restore
}

