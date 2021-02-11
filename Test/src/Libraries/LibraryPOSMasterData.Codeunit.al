codeunit 85002 "NPR Library - POS Master Data"
{
    trigger OnRun()
    begin
    end;

    procedure CreatePOSUnit(var POSUnit: Record "NPR POS Unit"; POSStoreCode: Code[10]; POSProfileCode: Code[20])
    var
        POSStore: Record "NPR POS Store";
        Register: Record "NPR Register";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSAuditProfile: Record "NPR POS Audit Profile";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        POSUnit.Init;
        POSUnit.Validate(
          "No.",
          CopyStr(
            LibraryUtility.GenerateRandomCode(POSUnit.FieldNo("No."), DATABASE::"NPR POS Unit"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"NPR POS Unit", POSUnit.FieldNo("No."))));
        if POSStoreCode = '' then
            CreatePOSStore(POSStore)
        else
            POSStore.Get(POSStoreCode);
        POSUnit."POS Store Code" := POSStore.Code;
        POSUnit.Validate(Status, POSUnit.Status::CLOSED);
        CreatePOSAuditProfile(POSAuditProfile);
        POSUnit."POS Audit Profile" := POSAuditProfile.Code;
        POSUnit."POS Posting Profile" := POSProfileCode;
        POSUnit.Insert(true);

        CreatePeriodRegister(POSUnit);
        CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);
        CreateRegister(Register, POSUnit, POSPaymentMethod.Code, POSPaymentMethod.Code);
    end;

    procedure CreatePOSStore(var POSStore: Record "NPR POS Store")
    var
        LibraryUtility: Codeunit "Library - Utility";
        NPRetailSetup: Record "NPR NP Retail Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        Location: Record Location;
        GeneralPostingSetup: Record "General Posting Setup";
        POSPostingProfile: Record "NPR POS Posting Profile";
        LibraryERM: Codeunit "Library - ERM";
        LibraryWarehouse: Codeunit "Library - Warehouse";
    begin
        NPRetailSetup.Get;
        POSStore.Init;
        POSStore.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(POSStore.FieldNo(Code), DATABASE::"NPR POS Store"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"NPR POS Store", POSStore.FieldNo(Code))));

        LibraryERM.CreateGeneralPostingSetupInvt(GeneralPostingSetup);
        POSStore.Validate("Gen. Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group");
        LibraryERM.CreateVATPostingSetupWithAccounts(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT", 25);
        POSStore.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location);
        POSStore.Validate("Location Code", Location.Code);

        POSStore.Insert(true);

        CreatePOSPostingSetupSet(POSStore.Code, '', '');
    end;

    procedure CreatePOSBin(var POSPaymentBin: Record "NPR POS Payment Bin")
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        POSPaymentBin.Init;
        POSPaymentBin.Validate(
          "No.",
          CopyStr(
            LibraryUtility.GenerateRandomCode(POSPaymentBin.FieldNo("No."), DATABASE::"NPR POS Payment Bin"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"NPR POS Payment Bin", POSPaymentBin.FieldNo(POSPaymentBin."No."))));
        POSPaymentBin.Insert(true);

        CreatePOSPostingSetupSet('', '', POSPaymentBin."No.");
    end;

    procedure CreatePOSPaymentMethod(var POSPaymentMethod: Record "NPR POS Payment Method"; ProcessingType: Option; CurrencyCode: Code[10]; PostCondensed: Boolean)
    var
        LibraryUtility: Codeunit "Library - Utility";
        PaymentTypePOS: Record "NPR Payment Type POS";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
    begin
        POSPaymentMethod.Init;
        POSPaymentMethod.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(POSPaymentMethod.FieldNo(Code), DATABASE::"NPR POS Payment Method"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"NPR POS Payment Method", POSPaymentMethod.FieldNo(POSPaymentMethod.Code))));
        POSPaymentMethod.Validate("Processing Type", ProcessingType);
        POSPaymentMethod.Validate("Currency Code", CurrencyCode);
        POSPaymentMethod.Validate("Post Condensed", PostCondensed);
        POSPaymentMethod.Validate("Rounding Type", LibraryRandom.RandIntInRange(0, 2));
        POSPaymentMethod.Validate("Rounding Gains Account", LibraryERM.CreateGLAccountNo);
        POSPaymentMethod.Validate("Rounding Losses Account", LibraryERM.CreateGLAccountNo);
        POSPaymentMethod.Validate("Rounding Precision", LibraryRandom.RandDec(1, 2));
        POSPaymentMethod.Insert(true);

        CreatePOSPostingSetupSet('', POSPaymentMethod.Code, '');

        case POSPaymentMethod."Processing Type" of
            POSPaymentMethod."Processing Type"::CASH:
                CreatePaymentTypePOS(PaymentTypePOS, POSPaymentMethod.Code, PaymentTypePOS."Processing Type"::Cash);
            POSPaymentMethod."Processing Type"::EFT:
                CreatePaymentTypePOS(PaymentTypePOS, POSPaymentMethod.Code, PaymentTypePOS."Processing Type"::EFT);
            else
                CreatePaymentTypePOS(PaymentTypePOS, POSPaymentMethod.Code, PaymentTypePOS."Processing Type"::Cash);
        end;
    end;

    procedure CreatePOSPostingSetupSet(POSStoreCode: Code[10]; POSPaymentMethodCode: Code[10]; POSPaymentBinCode: Code[10])
    var
        POSPostingSetup: Record "NPR POS Posting Setup";
        POSStore: Record "NPR POS Store";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSPaymentBin: Record "NPR POS Payment Bin";
    begin
        if POSStoreCode <> '' then
            POSStore.SetRange(Code, POSStoreCode);
        if POSPaymentMethodCode <> '' then
            POSPaymentMethod.SetRange(Code, POSPaymentMethodCode);
        if POSPaymentBinCode <> '' then
            POSPaymentBin.SetRange("No.", POSPaymentBinCode);
        if POSStore.FindSet then
            repeat
                POSPostingSetup.Init;
                POSPostingSetup."POS Store Code" := POSStore.Code;
                if POSPaymentMethod.FindSet then
                    repeat
                        POSPostingSetup."POS Payment Method Code" := POSPaymentMethod.Code;
                        if POSPaymentBinCode = '' then begin
                            CreatePOSPostingSetupLine(POSPostingSetup, false);
                        end else begin
                            if POSPaymentBin.FindSet then
                                repeat
                                    POSPostingSetup."POS Payment Bin Code" := POSPaymentBin."No.";
                                    CreatePOSPostingSetupLine(POSPostingSetup, false);
                                until POSPaymentBin.Next = 0;
                        end;
                    until POSPaymentMethod.Next = 0;
            until POSStore.Next = 0;
    end;

    procedure CreatePOSPostingSetupLine(var POSPostingSetup: Record "NPR POS Posting Setup"; UseGLAsDifferenceAccounts: Boolean)
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
    begin
        if POSPostingSetup.Find then
            exit;
        POSPaymentMethod.Get(POSPostingSetup."POS Payment Method Code");
        case POSPaymentMethod."Processing Type" of
            POSPaymentMethod."Processing Type"::CASH:
                begin
                    POSPostingSetup."Account Type" := POSPostingSetup."Account Type"::"Bank Account";
                    POSPostingSetup."Account No." := LibraryERM.CreateBankAccountNo;
                    if not UseGLAsDifferenceAccounts then begin
                        POSPostingSetup."Difference Account Type" := POSPostingSetup."Account Type"::"Bank Account";
                        POSPostingSetup."Difference Acc. No." := LibraryERM.CreateBankAccountNo;
                        POSPostingSetup."Difference Acc. No. (Neg)" := LibraryERM.CreateBankAccountNo;
                    end;
                end;
            POSPaymentMethod."Processing Type"::EFT:
                begin
                    POSPostingSetup."Account Type" := POSPostingSetup."Account Type"::Customer;
                    POSPostingSetup."Account No." := LibrarySales.CreateCustomerNo;
                    if not UseGLAsDifferenceAccounts then begin
                        POSPostingSetup."Difference Account Type" := POSPostingSetup."Account Type"::Customer;
                        POSPostingSetup."Difference Acc. No." := LibrarySales.CreateCustomerNo;
                        POSPostingSetup."Difference Acc. No. (Neg)" := LibrarySales.CreateCustomerNo;
                    end;
                end;
            else begin
                    POSPostingSetup."Account Type" := POSPostingSetup."Account Type"::"G/L Account";
                    POSPostingSetup."Account No." := LibraryERM.CreateGLAccountNo;
                end;
        end;
        if POSPostingSetup."Difference Acc. No." = '' then begin
            POSPostingSetup."Difference Account Type" := POSPostingSetup."Account Type"::"G/L Account";
            POSPostingSetup."Difference Acc. No." := LibraryERM.CreateGLAccountNo;
            POSPostingSetup."Difference Acc. No. (Neg)" := LibrarySales.CreateCustomerNo;
        end;
        POSPostingSetup.Insert;
    end;

    procedure CreatePOSSetup(var POSSetup: Record "NPR POS Setup")
    begin
        if POSSetup.FindFirst() then
            exit;

        POSSetup.Init;
        POSSetup.Insert();
    end;

    procedure CreateRegister(var Register: Record "NPR Register"; POSUnit: Record "NPR POS Unit"; PrimaryPaymentType: Code[10]; ReturnPaymentType: Code[10])
    begin
        if not Register.Get(POSUnit."No.") then begin
            Register.Init;
            Register."Register No." := POSUnit."No.";
            Register.Insert;
        end;
        Register."Primary Payment Type" := PrimaryPaymentType;
        Register."Return Payment Type" := ReturnPaymentType;
        Register.Modify;
    end;

    procedure CreatePaymentTypePOS(var PaymentTypePOS: Record "NPR Payment Type POS"; No: Text; ProcessingType: Integer)
    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        PaymentTypePOS.Init;
        if No <> '' then begin
            PaymentTypePOS.Validate("No.", No);
        end else begin
            PaymentTypePOS.Validate(
              "No.",
              CopyStr(
                LibraryUtility.GenerateRandomCode(PaymentTypePOS.FieldNo("No."), DATABASE::"NPR Payment Type POS"), 1,
                LibraryUtility.GetFieldLength(DATABASE::"NPR Payment Type POS", PaymentTypePOS.FieldNo("No."))));
        end;
        if not PaymentTypePOS.Find then
            PaymentTypePOS.Insert;

        PaymentTypePOS."Processing Type" := ProcessingType;
        PaymentTypePOS.Status := PaymentTypePOS.Status::Active;
        PaymentTypePOS."G/L Account No." := LibraryERM.CreateGLAccountNo();
        PaymentTypePOS."Auto End Sale" := true;
        PaymentTypePOS."To be Balanced" := true;
        PaymentTypePOS."Balancing Type" := PaymentTypePOS."Balancing Type"::Normal;
        PaymentTypePOS.Modify;
    end;

    procedure CreatePeriodRegister(var POSUnit: Record "NPR POS Unit")
    var
        POSPeriodRegister: Record "NPR POS Period Register";
    begin
        POSPeriodRegister.Init;
        POSPeriodRegister."No." := 0;
        POSPeriodRegister.Validate("POS Store Code", POSUnit."POS Store Code");
        POSPeriodRegister."POS Unit No." := POSUnit."No.";
        POSPeriodRegister.Status := POSPeriodRegister.Status::OPEN;
        POSPeriodRegister.Insert(true);
    end;

    procedure CreatePOSAuditProfile(var POSAuditProfile: Record "NPR POS Audit Profile")
    var
        LibraryUtility: Codeunit "Library - Utility";
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        POSAuditProfile.Init;
        POSAuditProfile.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(POSAuditProfile.FieldNo(Code), DATABASE::"NPR POS Audit Profile"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"NPR POS Audit Profile", POSAuditProfile.FieldNo(Code))));

        LibraryUtility.CreateNoSeries(NoSeries, true, false, false);
        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, 'TEST_ST_1', 'TEST_ST_999999999');
        NoSeriesLine.Validate("Allow Gaps in Nos.", true);
        NoSeriesLine.Modify();
        POSAuditProfile."Sales Ticket No. Series" := NoSeries.Code;
        POSAuditProfile.Insert;
    end;

    procedure CreateGeneralPostingSetupForSaleItem(GenBusPostGrp: Code[10]; GenProdPostGrp: Code[10]; LocationCode: Code[20]; InvPostingGroup: Code[10])
    var
        LibraryERM: Codeunit "Library - ERM";
        GeneralPostingSetup: Record "General Posting Setup";
        InventoryPostingSetup: Record "Inventory Posting Setup";
        Location: Record Location;
        LibraryInventory: Codeunit "Library - Inventory";
    begin
        if GeneralPostingSetup.Get(GenBusPostGrp, GenProdPostGrp) then
            exit;

        LibraryERM.CreateGeneralPostingSetup(GeneralPostingSetup, GenBusPostGrp, GenProdPostGrp);
        GeneralPostingSetup.Validate("Sales Account", LibraryERM.CreateGLAccountNo);
        GeneralPostingSetup."Sales Line Disc. Account" := LibraryERM.CreateGLAccountNo;
        GeneralPostingSetup.Validate("Purch. Account", LibraryERM.CreateGLAccountNo);
        GeneralPostingSetup.Validate("COGS Account", LibraryERM.CreateGLAccountNo);
        GeneralPostingSetup.Validate("Inventory Adjmt. Account", LibraryERM.CreateGLAccountNo);
        GeneralPostingSetup.Modify(true);
        if not InventoryPostingSetup.Get(LocationCode, InvPostingGroup) then
            LibraryInventory.CreateInventoryPostingSetup(InventoryPostingSetup, LocationCode, InvPostingGroup);
        if Location.Get(LocationCode) then
            LibraryInventory.UpdateInventoryPostingSetup(Location);
    end;

    procedure CreatePostingSetupForSaleItem(Item: Record Item; POSUnit: Record "NPR POS Unit"; POSStore: Record "NPR POS Store")
    begin
        CreateVATPostingSetupForSaleItem(POSStore."VAT Bus. Posting Group", Item."VAT Prod. Posting Group");
        CreateGeneralPostingSetupForSaleItem(POSStore."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group", POSStore."Location Code", Item."Inventory Posting Group");
    end;

    procedure OpenPOSUnit(var POSUnit: Record "NPR POS Unit")
    var
        POSOpenPOSUnit: Codeunit "NPR POS Manage POS Unit";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        Setup: Codeunit "NPR POS Setup";
        OpeningEntryNo: Integer;
    begin
        POSOpenPOSUnit.ClosePOSUnitOpenPeriods(POSUnit."No."); // make sure pos period register is correct
        POSOpenPOSUnit.OpenPOSUnit(POSUnit);
        OpeningEntryNo := POSCreateEntry.InsertUnitOpenEntry(POSUnit."No.", Setup.Salesperson());
        POSOpenPOSUnit.SetOpeningEntryNo(POSUnit."No.", OpeningEntryNo);
        Commit();
    end;

    procedure CreateVATPostingSetupForSaleItem(VATBusPostGrp: Code[10]; VATProdPostGrp: Code[10])
    var
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";
    begin
        if VATPostingSetup.Get(VATBusPostGrp, VATProdPostGrp) then
            exit;

        LibraryERM.CreateVATPostingSetup(VATPostingSetup, VATBusPostGrp, VATProdPostGrp);
        VATPostingSetup."VAT %" := 25; //TODO: should be something like this - LibraryRandom.RandIntInRange(5,95);
        VATPostingSetup."VAT Calculation Type" := VATPostingSetup."VAT Calculation Type"::"Normal VAT";
        VATPostingSetup.Validate("VAT Identifier",
          LibraryUtility.GenerateRandomCode(VATPostingSetup.FieldNo("VAT Identifier"), DATABASE::"VAT Posting Setup"));
        VATPostingSetup.Validate("Sales VAT Account", LibraryERM.CreateGLAccountNo);
        VATPostingSetup.Validate("Purchase VAT Account", LibraryERM.CreateGLAccountNo);
        VATPostingSetup.Validate("Tax Category", 'S');
        VATPostingSetup.Modify;
    end;

    procedure CreateDefaultPostingSetup(var POSPostingProfile: Record "NPR POS Posting Profile")
    begin
        CreateDefaultPostingProfile(POSPostingProfile);

        CreateDefaultNPRetailSetup();

        CreateDefaultRetailSetup();
    end;


    local procedure CreateDefaultPostingProfile(var POSPostingProfile: Record "NPR POS Posting Profile")
    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        POSPostingProfile.Init;
        POSPostingProfile.Code := LibraryUtility.GenerateRandomCode20(POSPostingProfile.FieldNo(Code), Database::"NPR POS Posting Profile");
        if not POSPostingProfile.Find then
            POSPostingProfile.Insert;

        POSPostingProfile."POS Posting Diff. Account" := LibraryERM.CreateGLAccountNo();
        POSPostingProfile."Max. POS Posting Diff. (LCY)" := 0.5;
        POSPostingProfile."Automatic Item Posting" := POSPostingProfile."Automatic Item Posting"::AfterSale;
        POSPostingProfile."Automatic POS Posting" := POSPostingProfile."Automatic POS Posting"::AfterSale;
        POSPostingProfile."Automatic Posting Method" := POSPostingProfile."Automatic Posting Method"::Direct;
        POSPostingProfile."POS Sales Rounding Account" := LibraryERM.CreateGLAccountNo();
        POSPostingProfile."POS Sales Amt. Rndng Precision" := 0.5;

        LibraryUtility.CreateNoSeries(NoSeries, true, false, true);
        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, 'TEST_PE_1', 'TEST_PE_999999999');
        POSPostingProfile."Default POS Entry No. Series" := NoSeries.Code;
        POSPostingProfile.Modify;
    end;

    local procedure CreateDefaultNPRetailSetup()
    var
        NPRetailSetup: Record "NPR NP Retail Setup";
    begin
        if not NPRetailSetup.Get then
            NPRetailSetup.Insert;
    end;

    local procedure CreateDefaultRetailSetup()
    var
        RetailSetup: Record "NPR Retail Setup";
    begin
        if not RetailSetup.Get then
            RetailSetup.Insert;
        RetailSetup."Prices incl. VAT" := true;
        RetailSetup.Modify;
    end;

    procedure CreateItemForPOSSaleUsage(var Item: Record Item; POSUnit: Record "NPR POS Unit"; POSStore: Record "NPR POS Store")
    var
        NPRLibraryInventory: Codeunit "NPR Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
    begin
        NPRLibraryInventory.CreateItem(Item);
        Item.Validate("VAT Bus. Posting Gr. (Price)", POSStore."VAT Bus. Posting Group");

        Item."Price Includes VAT" := true;
        Item."Unit Price" := LibraryRandom.RandDec(1000, 2) + 1; //more than 1
        Item."Unit Cost" := LibraryRandom.RandDecInDecimalRange(0.01, Item."Unit Price", 1);
        Item.Modify;

        CreatePostingSetupForSaleItem(Item, POSUnit, POSStore);
    end;
}

