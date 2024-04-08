codeunit 85153 "NPR POS Act. BlockDisc Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";
        Initialized: Boolean;
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSStore: Record "NPR POS Store";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ShowPassPropmtTest()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSecurityProfile: Record "NPR POS Security Profile";
        POSActBlockDiscountB: Codeunit "NPR POS Action:Block DiscountB";
        Setup: Codeunit "NPR POS Setup";
        ShowPasswordPrompt: Boolean;
        Pass: Code[4];
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        CreateSecurityProfile(POSSecurityProfile, Pass);
        POSUnit."POS Security Profile" := POSSecurityProfile.Code;
        POSUnit.Modify();

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        POSSession.GetSetup(Setup);

        POSActBlockDiscountB.ShowPassPrompt(Setup, ShowPasswordPrompt);

        Assert.IsTrue(ShowPasswordPrompt = true, 'Asked for pass')
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ShowPassPropmtFalseTest()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSecurityProfile: Record "NPR POS Security Profile";
        POSActBlockDiscountB: Codeunit "NPR POS Action:Block DiscountB";
        Setup: Codeunit "NPR POS Setup";
        ShowPasswordPrompt: Boolean;
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        POSUnit."POS Security Profile" := '';
        POSUnit.Modify();

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        POSSession.GetSetup(Setup);

        POSActBlockDiscountB.ShowPassPrompt(Setup, ShowPasswordPrompt);

        Assert.IsTrue(ShowPasswordPrompt = false, 'Not asked for pass')
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ToggleBlockSaleTest()
    var
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSecurityProfile: Record "NPR POS Security Profile";
        POSActBlockDiscountB: Codeunit "NPR POS Action:Block DiscountB";
        Setup: Codeunit "NPR POS Setup";
        ShowPasswordPrompt: Boolean;
        Item: Record Item;
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        Pass: Code[4];
    begin
        // [Given] POS & Payment setup
        LibraryPOSMock.InitializeData(Initialized, POSUnit, POSStore);

        CreateSecurityProfile(POSSecurityProfile, Pass);
        POSUnit."POS Security Profile" := POSSecurityProfile.Code;
        POSUnit.Modify();

        // [Given] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);

        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        Item."NPR Custom Discount Blocked" := true;
        Item.Modify();
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSession.GetSetup(Setup);

        POSActBlockDiscountB.VerifyPassword(Setup, Pass);
        POSActBlockDiscountB.ToggleBlockState(POSSaleLine);

        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        Assert.IsTrue(SaleLinePOS."Custom Disc Blocked" = false, 'Discount unblocked.')
    end;

    local procedure CreateSecurityProfile(var POSSecurityProfile: Record "NPR POS Security Profile"; var Pass: Code[4])
    var
        LibraryRandom: Codeunit "Library - Random";
    begin
        If not POSSecurityProfile.Get('BD-TEST') then begin
            POSSecurityProfile.Init();
            POSSecurityProfile.Code := 'BD-TEST';
            POSSecurityProfile.Insert();
        end;
        Pass := LibraryRandom.RandText(4);
        POSSecurityProfile."Password on Unblock Discount" := Pass;
        POSSecurityProfile.Modify();
    end;
}