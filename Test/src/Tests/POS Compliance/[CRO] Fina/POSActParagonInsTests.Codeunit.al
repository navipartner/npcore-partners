codeunit 85165 "NPR POS Act Paragon Ins. Tests"
{
    Subtype = Test;

    var
        _POSUnit: Record "NPR POS Unit";
        _Salesperson: Record "Salesperson/Purchaser";
        _Assert: Codeunit Assert;
        LibraryCROFiscal: Codeunit "NPR Library CRO Fiscal";
        _POSSession: Codeunit "NPR POS Session";
        _Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure InsertParagonNumber()
    var
        CROPOSSale: Record "NPR CRO POS Sale";
        SalePOS: Record "NPR POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        NewDesc: Text;
    begin
        // [Scenario] Activate POS Session and add Paragon Number to it
        // [Given] POS & Payment setup
        InitializeData();

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSale);

        // [When] Add Additional Paragon Number
        AddParagonNumber(SalePOS, POSSale, NewDesc);

        // [Then] Paragon Number is added to POS Sale
        POSSale.GetCurrentSale(SalePOS);
        CROPOSSale.Get(SalePOS.SystemId);
        _Assert.IsTrue(CROPOSSale."CRO Paragon Number" = NewDesc, 'Paragon Number is not inserted.');
    end;

    internal procedure InitializeData()
    var
        Item: Record Item;
        VoucherType: Record "NPR NpRv Voucher Type";
        ObjectOutputSelection: Record "NPR Object Output Selection";
        POSAuditLog: Record "NPR POS Audit Log";
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSEndOfDayProfile: Record "NPR POS End of Day Profile";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        TemplateHeader: Record "NPR RP Template Header";
        ReturnReason: Record "Return Reason";
        LibraryERM: Codeunit "Library - ERM";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryRPTemplate: Codeunit "NPR Library - RP Template Data";
        LibraryCROFiscal: Codeunit "NPR Library CRO Fiscal";
    begin
        //Clean any previous mock session
        _POSSession.ClearAll();
        Clear(_POSSession);

        if not _Initialized then begin
            NPRLibraryPOSMasterData.CreatePOSSetup(POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            POSPostingProfile."POS Period Register No. Series" := '';
            POSPostingProfile.Modify();
            NPRLibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(GetTestPOSUnitNo(), _POSUnit, POSStore.Code, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, POSStore);
            NPRLibraryPOSMasterData.CreateSalespersonForPOSUsage(_Salesperson);

            POSEndOfDayProfile.Code := 'EOD-TEST';
            POSEndOfDayProfile."Z-Report UI" := POSEndOfDayProfile."Z-Report UI"::BALANCING;
            POSEndOfDayProfile.Insert();

            _POSUnit."POS End of Day Profile" := POSEndOfDayProfile.Code;
            _POSUnit.Modify();

            LibraryERM.CreateReturnReasonCode(ReturnReason);
            Item."Unit Price" := 10;
            Item.Modify();

            LibraryCROFiscal.CreateAuditProfileAndCROSetup(POSAuditProfile, _POSUnit, POSPaymentMethod, _Salesperson);

            ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Sales Receipt (POS Entry)");
            ReportSelectionRetail.DeleteAll();
            ObjectOutputSelection.DeleteAll();

            LibraryRPTemplate.CreateDummySalesReceipt(TemplateHeader);
            LibraryRPTemplate.ConfigureReportSelection(ReportSelectionRetail."Report Type"::"Sales Receipt (POS Entry)", TemplateHeader);

            _Initialized := true;
        end;

        POSAuditLog.DeleteAll(true); //Clean in between tests
        Commit();
    end;

    local procedure AddParagonNumber(var SalePOS: Record "NPR POS Sale"; var POSSale: Codeunit "NPR POS Sale"; var NewDesc: Text)
    var
        CROPOSSale: Record "NPR CRO POS Sale";
        LibraryRandom: Codeunit "Library - Random";
    begin
        POSSale.GetCurrentSale(SalePOS);
        NewDesc := Format(LibraryRandom.RandIntInRange(111111111, 999999999));
        CROPOSSale."POS Sale SystemId" := SalePOS.SystemId;
        CROPOSSale."CRO Paragon Number" := NewDesc;
        if not CROPOSSale.Insert() then
            CROPOSSale.Modify();
    end;

    local procedure GetTestPOSUnitNo(): Code[10]
    begin
        exit('077');
    end;
}