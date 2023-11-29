codeunit 85168 "NPR POS Act SI PreInv Ins Test"
{
    Subtype = Test;

    var
        _POSUnit: Record "NPR POS Unit";
        _Salesperson: Record "Salesperson/Purchaser";
        _Assert: Codeunit Assert;
        LibrarySIFiscal: Codeunit "NPR Library SI Fiscal";
        _POSSession: Codeunit "NPR POS Session";
        _Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure InsertSetSerialNumber()
    var
        SalePOS: Record "NPR POS Sale";
        SIPOSSale: Record "NPR SI POS Sale";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        NewDesc: Text;
        NewDesc2: Text;
    begin
        // [Scenario] Activate POS Session and add Set and Serial Numbers to it
        // [Given] POS & Payment setup
        BindSubscription(LibrarySIFiscal);

        InitializeData();

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSale);

        // [When] Add Additional Paragon Number
        AddPrenumberedBookNumbers(SalePOS, POSSale, NewDesc, NewDesc2);

        // [Then] Set and Serial Numbers is added to POS Sale
        POSSale.GetCurrentSale(SalePOS);
        SIPOSSale.Get(SalePOS.SystemId);
        _Assert.IsTrue((SIPOSSale."SI Set Number" = NewDesc) and (SIPOSSale."SI Serial Number" = NewDesc2), 'Set and Serial Numbers are not inserted.');

        UnbindSubscription(LibrarySIFiscal);
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
        _POSStore: Record "NPR POS Store";
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        TemplateHeader: Record "NPR RP Template Header";
        ReturnReason: Record "Return Reason";
        LibraryERM: Codeunit "Library - ERM";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryRPTemplate: Codeunit "NPR Library - RP Template Data";
        LibrarySIFiscal: Codeunit "NPR Library SI Fiscal";
    begin
        if _Initialized then begin
            //Clean any previous mock session
            _POSSession.ClearAll();
            Clear(_POSSession);
        end else begin
            NPRLibraryPOSMasterData.CreatePOSSetup(POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultVoucherType(VoucherType, false);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            POSPostingProfile."POS Period Register No. Series" := '';
            POSPostingProfile.Modify();
            NPRLibraryPOSMasterData.CreatePOSStore(_POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(GetTestPOSUnitNo(), _POSUnit, _POSStore.Code, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
            NPRLibraryPOSMasterData.CreateSalespersonForPOSUsage(_Salesperson);

            POSEndOfDayProfile.Code := 'EOD-TEST';
            POSEndOfDayProfile."Z-Report UI" := POSEndOfDayProfile."Z-Report UI"::BALANCING;
            POSEndOfDayProfile.Insert();

            _POSUnit."POS End of Day Profile" := POSEndOfDayProfile.Code;
            _POSUnit.Modify();

            LibraryERM.CreateReturnReasonCode(ReturnReason);
            Item."Unit Price" := 10;
            Item.Modify();

            LibrarySIFiscal.CreateAuditProfileAndSISetup(POSAuditProfile, _POSStore, _POSUnit, _Salesperson);

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

    local procedure AddPrenumberedBookNumbers(var SalePOS: Record "NPR POS Sale"; var POSSale: Codeunit "NPR POS Sale"; var NewDesc: Text; var NewDesc2: Text)
    var
        SIPOSSale: Record "NPR SI POS Sale";
        LibraryRandom: Codeunit "Library - Random";
    begin
        POSSale.GetCurrentSale(SalePOS);
        NewDesc := Format(LibraryRandom.RandIntInRange(111111111, 999999999));
        NewDesc2 := Format(LibraryRandom.RandIntInRange(111111111, 999999999));
        SIPOSSale."POS Sale SystemId" := SalePOS.SystemId;
        SIPOSSale."SI Set Number" := NewDesc;
        SIPOSSale."SI Serial Number" := NewDesc2;
        if not SIPOSSale.Insert() then
            SIPOSSale.Modify();
    end;

    local procedure GetTestPOSUnitNo(): Code[10]
    begin
        exit('077');
    end;
}