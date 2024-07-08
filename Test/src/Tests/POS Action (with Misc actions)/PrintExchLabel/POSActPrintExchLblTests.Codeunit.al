codeunit 85150 "NPR POS Act:PrintExchLbl Tests"
{
    Subtype = Test;

    var
        POSUnit: Record "NPR POS Unit";
        POSPaymentMethod: Record "NPR POS Payment Method";
        Item: Record Item;
        POSSession: Codeunit "NPR POS Session";
        _Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExchangeLabelPrint()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        Setting: Option Single,"Line Quantity","All Lines",Selection,Package;
        ValidFromDate: Date;
        SaleLinePOS: Record "NPR POS Sale Line";
        PrintLines: Record "NPR POS Sale Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSActionPrintExchLblB: Codeunit "NPR POS Action: PrintExchLbl-B";
        i: Integer;
    begin
        // [Given] Active POS session & sale
        InitializeData;
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        ValidFromDate := Today;
        Setting := Setting::"All Lines";
        //insert 3 lines
        for i := 1 to 3 do
            LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);
        // [When]
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        PrintLines := SaleLinePOS;
        PrintLines.SetRecFilter();
        POSActionPrintExchLblB.PrintLabelsFromPOS(Setting, PrintLines, ValidFromDate);
        // [Then] Barcode will be generated and label sent to Printer
    end;

    internal procedure InitializeData()
    var
        ObjectOutputSelection: Record "NPR Object Output Selection";
        POSAuditLog: Record "NPR POS Audit Log";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        ReportSelectionRetail: Record "NPR Report Selection Retail";
        TemplateHeader: Record "NPR RP Template Header";
        VATPostingSetup: Record "VAT Posting Setup";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryRPTemplate: Codeunit "NPR Library - RP Template Data";
        ExchangeLabel: Record "NPR Exchange Label";
    begin
        if _Initialized then begin
            //Clean any previous mock session
            POSSession.ClearAll();
            Clear(POSSession);
        end else begin
            NPRLibraryPOSMasterData.CreatePOSSetup(POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            POSPostingProfile."POS Period Register No. Series" := '';
            POSPostingProfile.Modify();
            NPRLibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);
            NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);

            POSStore."Exchange Label EAN Code" := '762';
            POSStore.Modify();

            ExchangeLabel.SetRange("Store ID", CopyStr(POSUnit."POS Store Code", 1, MaxStrLen(ExchangeLabel."Store ID")));
            ExchangeLabel.DeleteAll();

            Item."Unit Price" := 10;
            Item.Modify();

            VATPostingSetup.SetRange("VAT Prod. Posting Group", Item."VAT Prod. Posting Group");
            VATPostingSetup.SetRange("VAT Bus. Posting Group", POSPostingProfile."VAT Bus. Posting Group");
            VATPostingSetup.SetFilter("VAT %", '<>%1', 0);
            VATPostingSetup.FindFirst();

            ReportSelectionRetail.SetRange("Report Type", ReportSelectionRetail."Report Type"::"Exchange Label");
            ReportSelectionRetail.DeleteAll();
            ObjectOutputSelection.DeleteAll();

            LibraryRPTemplate.CreateDummyExchangeLabelTemplate(TemplateHeader);
            LibraryRPTemplate.ConfigureReportSelection(ReportSelectionRetail."Report Type"::"Exchange Label", TemplateHeader);
            InitExchangeLabelSetup();

            _Initialized := true;
        end;

        POSAuditLog.DeleteAll(true); //Clean in between tests
        Commit();
    end;

    local procedure InitExchangeLabelSetup()
    var
        ExchangeLabelSetup: Record "NPR Exchange Label Setup";
        VarietySetup: Record "NPR Variety Setup";
    begin
        if not ExchangeLabelSetup.Get() then begin
            ExchangeLabelSetup.Init();
            ExchangeLabelSetup.Insert();
        end;
        ExchangeLabelSetup."Exchange Label  No. Series" := GenerateNoSeries();
        ExchangeLabelSetup."EAN Prefix Exhange Label" := '57';
        ExchangeLabelSetup.Modify();

        if not VarietySetup.Get() then begin
            VarietySetup.Init();
            VarietySetup.Insert();
        end;

        VarietySetup."EAN-Internal" := 57;
        VarietySetup.Modify();
    end;

    procedure GenerateNoSeries(): Code[20]
    var
        NoSeriesLine: Record "No. Series Line";
        LibraryRandom: Codeunit "Library - Random";
        NoSeries: Record "No. Series";
    begin
        NoSeries.Init();
        NoSeries.Code := LibraryRandom.RandText(20);
        NoSeries."Default Nos." := true;
        NoSeries."Manual Nos." := false;
        NoSeries."Date Order" := false;
        NoSeries.Insert();

        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := NoSeries.Code;
        NoSeriesLine."Starting No." := '10000000';
        NoSeriesLine."Increment-by No." := 5000000;
        NoSeriesLine.Open := true;
        NoSeriesLine.Insert();
        exit(NoSeries.Code);
    end;
}
