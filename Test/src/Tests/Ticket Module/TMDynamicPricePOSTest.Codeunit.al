codeunit 85233 "NPR TM Dynamic Price POS Test"
{
    Subtype = Test;

    var
        Initialized: Boolean;
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        Assert: Codeunit Assert;
        POSPaymentMethodCash: Record "NPR POS Payment Method";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";

    #region POS Integration
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SimplePOSSalesTest()
    var
        ItemNo: Code[20];
        Item: Record Item;
        Salesperson: Record "Salesperson/Purchaser";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        POSSaleLine: Record "NPR POS Sale Line";
    begin
        ItemNo := SelectDynamicPriceScenario();

        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, Salesperson, POSSale);

        LibraryPOSMock.CreateItemLine(POSSession, ItemNo, 1);

        Item.Get(ItemNo);
        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(POSSaleLine);

        Assert.AreEqual(
            Item."Unit Price" - 10,
            POSSaleLine."Unit Price",
            'Unit price on sales line did not match expected dynamic price'
        );
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure POSSaleWithMixDiscountAmount()
    var
        ItemNo: Code[20];
        Item: Record Item;
        Salesperson: Record "Salesperson/Purchaser";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        POSSaleLine: Record "NPR POS Sale Line";
        LibraryPOSDiscount: Codeunit "NPR Library - POS Discount";
    begin
        ItemNo := SelectDynamicPriceScenario();
        Item.Get(ItemNo);

        LibraryPOSDiscount.CreateMultipleDiscountLevels(
            Item,
            1,
            5,
            25,
            25,
            false
        );

        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, Salesperson, POSSale);

        LibraryPOSMock.CreateItemLine(POSSession, ItemNo, 1);

        POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(POSSaleLine);

        Assert.AreEqual(
            Item."Unit Price" - 10,
            POSSaleLine."Unit Price",
            'Unit price on sales line did not match expected dynamic price'
        );

        Assert.AreEqual(
            25,
            POSSaleLine."Discount Amount",
            'Discount amount did not match expected amount on line'
        );
    end;
    #endregion

    #region Aux functions
    local procedure Initialize()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        PriceList: Record "Price List Line";
    begin
        if Initialized then begin
            //Clean any previous mock session
            POSSession.ClearAll();
            Clear(POSSession);
        end;

        if not Initialized then begin
            NPRLibraryPOSMasterData.CreatePOSSetup(POSSetup);
            NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            NPRLibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
            NPRLibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethodCash, POSPaymentMethodCash."Processing Type"::CASH, '', false);

            Initialized := true;
        end;

        Commit();
    end;

    local procedure SetRelativeUntilEventDate(PriceProfileCode: Code[10]; LineNo: Integer; RelativeDateFormula: Text; RelativeAmount: Decimal; VatPercentage: Decimal)
    var
        Rule: Record "NPR TM Dynamic Price Rule";
    begin
        if (not Rule.Get(PriceProfileCode, LineNo)) then begin
            Rule.Init();
            Rule.ProfileCode := PriceProfileCode;
            Rule.LineNo := LineNo;
            Rule.Insert();
        end;

        Evaluate(Rule.RelativeUntilEventDate, RelativeDateFormula);

        Rule.PricingOption := Rule.PricingOption::RELATIVE;
        Rule.Amount := RelativeAmount;
        Rule.AmountIncludesVAT := true;
        Rule.VatPercentage := VatPercentage;

        Rule.Modify();
    end;

    local procedure GetPriceProfileCode(ItemNo: Code[20]): Code[10]
    var
        AdmSchLine: Record "NPR TM Admis. Schedule Lines";
    begin
        AdmSchLine.SetFilter("Admission Code", '=%1', GetAdmissionCode(ItemNo));
        AdmSchLine.FindFirst();
        exit(AdmSchLine."Dynamic Price Profile Code");
    end;

    local procedure GetAdmissionCode(ItemNo: Code[20]): Code[20]
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
    begin
        TicketBom.SetFilter("Item No.", '=%1', ItemNo);
        TicketBom.FindFirst();
        exit(TicketBom."Admission Code");
    end;

    local procedure SelectDynamicPriceScenario() ItemNo: Code[20]
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
        Item: Record Item;
        POSPostingProfile: Record "NPR POS Posting Profile";
        VATPostingSetup: Record "VAT Posting Setup";
        ProfileCode: Code[10];
    begin
        Initialize();
        POSStore.GetProfile(POSPostingProfile);

        ItemNo := TicketLibrary.CreateScenario_DynamicPrice();

        Item.Get(ItemNo);
        Item."VAT Bus. Posting Gr. (Price)" := POSPostingProfile."VAT Bus. Posting Group"; // To avoid "funny" VAT recalculations on the lines
        Item.Modify();

        LibraryPOSMasterData.CreateVATPostingSetupForSaleItem(POSPostingProfile."VAT Bus. Posting Group", Item."VAT Prod. Posting Group");
        VATPostingSetup.Get(POSPostingProfile."VAT Bus. Posting Group", Item."VAT Prod. Posting Group");

        ProfileCode := GetPriceProfileCode(ItemNo);
        SetRelativeUntilEventDate(ProfileCode, 10000, '0D', -10, VATPostingSetup."VAT %");
    end;
    #endregion
}