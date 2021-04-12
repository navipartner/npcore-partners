codeunit 85002 "NPR Library - POS Master Data"
{
    procedure CreatePOSUnit(var POSUnit: Record "NPR POS Unit"; POSStoreCode: Code[10]; POSProfileCode: Code[20])
    var
        POSStore: Record "NPR POS Store";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSPaymentBin: record "NPR POS Payment Bin";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        POSUnit.Init();
        POSUnit.Validate(
          "No.",
          CopyStr(
            LibraryUtility.GenerateRandomCode(POSUnit.FieldNo("No."), DATABASE::"NPR POS Unit"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"NPR POS Unit", POSUnit.FieldNo("No."))));
        if POSStoreCode = '' then
            CreatePOSStore(POSStore, POSProfileCode)
        else
            POSStore.Get(POSStoreCode);
        POSUnit."POS Store Code" := POSStore.Code;
        POSUnit.Validate(Status, POSUnit.Status::CLOSED);
        CreatePOSAuditProfile(POSAuditProfile);
        POSUnit."POS Audit Profile" := POSAuditProfile.Code;
        POSUnit.Insert(true);

        CreatePOSBin(POSPaymentBin);
        POSUnit."Default POS Payment Bin" := POSPaymentBin."No.";
        POSUnit.Modify();

        CreatePeriodRegister(POSUnit);
        CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);
    end;

    procedure CreatePOSStore(var POSStore: Record "NPR POS Store"; POSProfileCode: Code[20])
    var
        LibraryUtility: Codeunit "Library - Utility";
        Location: Record Location;
        LibraryWarehouse: Codeunit "Library - Warehouse";
    begin
        POSStore.Init();
        POSStore.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(POSStore.FieldNo(Code), DATABASE::"NPR POS Store"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"NPR POS Store", POSStore.FieldNo(Code))));

        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location);
        POSStore.Validate("Location Code", Location.Code);
        POSStore."POS Posting Profile" := POSProfileCode;

        POSStore.Insert(true);

        CreatePOSPostingSetupSet(POSStore.Code, '', '');
    end;

    procedure CreatePOSBin(var POSPaymentBin: Record "NPR POS Payment Bin")
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        POSPaymentBin.Init();
        POSPaymentBin.Validate(
          "No.",
          CopyStr(
            LibraryUtility.GenerateRandomCode(POSPaymentBin.FieldNo("No."), DATABASE::"NPR POS Payment Bin"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"NPR POS Payment Bin", POSPaymentBin.FieldNo(POSPaymentBin."No."))));
        POSPaymentBin.Insert(true);

    end;

    procedure CreatePOSPaymentMethod(var POSPaymentMethod: Record "NPR POS Payment Method"; ProcessingType: Option; CurrencyCode: Code[10]; PostCondensed: Boolean)
    var
        ReturnPOSPaymentMethod: Record "NPR POS Payment Method";
        POSPaymentBin: Record "NPR POS Payment Bin";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
    begin
        POSPaymentMethod.Init();
        POSPaymentMethod.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(POSPaymentMethod.FieldNo(Code), DATABASE::"NPR POS Payment Method"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"NPR POS Payment Method", POSPaymentMethod.FieldNo(POSPaymentMethod.Code))));
        POSPaymentMethod.Validate("Processing Type", ProcessingType);
        POSPaymentMethod.Validate("Currency Code", CurrencyCode);
        POSPaymentMethod.Validate("Post Condensed", PostCondensed);
        POSPaymentMethod.Validate("Rounding Type", LibraryRandom.RandIntInRange(0, 2));
        POSPaymentMethod.Validate("Account No.", LibraryERM.CreateGLAccountNo);
        POSPaymentMethod.Validate("Rounding Gains Account", LibraryERM.CreateGLAccountNo);
        POSPaymentMethod.Validate("Rounding Losses Account", LibraryERM.CreateGLAccountNo);
        POSPaymentMethod.Validate("Rounding Precision", GetRandomPrecision());
        POSPaymentMethod.Insert(true);

        if POSPaymentMethod."Processing Type" = POSPaymentMethod."Processing Type"::CASH then
            POSPaymentMethod."Return Payment Method Code" := POSPaymentMethod.Code
        else begin
            CreatePOSPaymentMethod(ReturnPOSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);
            POSPaymentMethod."Return Payment Method Code" := ReturnPOSPaymentMethod.Code;
        end;

        CreatePOSBin(POSPaymentBin);
        POSPaymentMethod."Bin for Virtual-Count" := POSPaymentBin."No.";
        POSPaymentMethod."Include In Counting" := POSPaymentMethod."Include In Counting"::VIRTUAL;
        POSPaymentMethod.Modify();

        CreatePOSPostingSetup(POSPaymentMethod);
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
        if POSStore.FindSet() then
            repeat
                POSPostingSetup.Init();
                POSPostingSetup."POS Store Code" := POSStore.Code;
                if POSPaymentMethod.FindSet() then
                    repeat
                        POSPostingSetup."POS Payment Method Code" := POSPaymentMethod.Code;
                        if POSPaymentBinCode = '' then begin
                            CreatePOSPostingSetupLine(POSPostingSetup, false);
                        end else begin
                            if POSPaymentBin.FindSet() then
                                repeat
                                    POSPostingSetup."POS Payment Bin Code" := POSPaymentBin."No.";
                                    CreatePOSPostingSetupLine(POSPostingSetup, false);
                                until POSPaymentBin.Next() = 0;
                        end;
                    until POSPaymentMethod.Next() = 0;
            until POSStore.Next() = 0;
    end;

    procedure CreatePOSPostingSetupLine(var POSPostingSetup: Record "NPR POS Posting Setup"; UseGLAsDifferenceAccounts: Boolean)
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
    begin
        if POSPostingSetup.Find() then
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
        POSPostingSetup.Insert();
    end;

    procedure CreatePOSSetup(var POSSetup: Record "NPR POS Setup")
    begin
        if POSSetup.FindFirst() then
            exit;

        POSSetup.Init();
        POSSetup.Insert();
    end;

    procedure CreatePOSPaymentMethod(var POSPaymentMethod: Record "NPR POS Payment Method"; No: Text; ProcessingType: Integer)
    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        POSPaymentMethod.Init();
        if No <> '' then begin
            POSPaymentMethod.Validate(Code, No);
        end else begin
            POSPaymentMethod.Validate(
              Code,
              CopyStr(
                LibraryUtility.GenerateRandomCode(POSPaymentMethod.FieldNo(Code), DATABASE::"NPR POS Payment Method"), 1,
                LibraryUtility.GetFieldLength(DATABASE::"NPR POS Payment Method", POSPaymentMethod.FieldNo(Code))));
        end;
        if not POSPaymentMethod.Find() then
            POSPaymentMethod.Insert();

        POSPaymentMethod."Processing Type" := ProcessingType;
        POSPaymentMethod."Block POS Payment" := false;
        POSPaymentMethod."Auto End Sale" := true;
        POSPaymentMethod.Modify();
    end;

    procedure CreatePeriodRegister(var POSUnit: Record "NPR POS Unit")
    var
        POSPeriodRegister: Record "NPR POS Period Register";
    begin
        POSPeriodRegister.Init();
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
        POSAuditProfile.Init();
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
        POSAuditProfile.Insert();
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
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        POSStore.GetProfile(POSPostingProfile);
        CreateVATPostingSetupForSaleItem(POSPostingProfile."VAT Bus. Posting Group", Item."VAT Prod. Posting Group");
        CreateGeneralPostingSetupForSaleItem(POSPostingProfile."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group", POSStore."Location Code", Item."Inventory Posting Group");
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
        VATPostingSetup.Modify();
    end;

    procedure CreateDefaultPostingSetup(var POSPostingProfile: Record "NPR POS Posting Profile")
    begin
        CreateDefaultPostingProfile(POSPostingProfile);
    end;


    local procedure CreateDefaultPostingProfile(var POSPostingProfile: Record "NPR POS Posting Profile")
    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        GeneralPostingSetup: Record "General Posting Setup";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        POSPostingProfile.Init();
        POSPostingProfile.Code := LibraryUtility.GenerateRandomCode20(POSPostingProfile.FieldNo(Code), Database::"NPR POS Posting Profile");
        if not POSPostingProfile.Find() then
            POSPostingProfile.Insert();

        POSPostingProfile."POS Posting Diff. Account" := LibraryERM.CreateGLAccountNo();
        POSPostingProfile."Max. POS Posting Diff. (LCY)" := 0.5;
        POSPostingProfile."POS Sales Rounding Account" := LibraryERM.CreateGLAccountWithSalesSetup();
        POSPostingProfile."POS Sales Amt. Rndng Precision" := 0.5;

        LibraryUtility.CreateNoSeries(NoSeries, true, false, true);
        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, 'TEST_PE_1', 'TEST_PE_999999999');
        POSPostingProfile."Default POS Entry No. Series" := NoSeries.Code;

        LibraryERM.CreateGeneralPostingSetupInvt(GeneralPostingSetup);
        POSPostingProfile.Validate("Gen. Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group");
        LibraryERM.CreateVATPostingSetupWithAccounts(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT", 25);
        POSPostingProfile.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");

        POSPostingProfile.Modify();
    end;

    local procedure CreatePOSPostingSetup(var POSPaymentMethod: Record "NPR POS Payment Method")
    var
        POSPostingSetup: Record "NPR POS Posting Setup";
        POSUnit: Record "NPR POS Unit";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSStore: Record "NPR POS Store";
    begin

        if not POSPaymentMethod.Get(POSPaymentMethod.Code) then
            exit;
        POSPostingSetup.Init();
        POSPostingSetup."POS Store Code" := '';
        POSPostingSetup."POS Payment Method Code" := POSPaymentMethod.Code;
        POSPostingSetup."POS Payment Bin Code" := '';
        POSPostingSetup."Account Type" := POSPostingSetup."Account Type"::"G/L Account";
        POSPostingSetup."Account No." := POSPaymentMethod."Account No.";

        if not POSPostingSetup.Find() then
            POSPostingSetup.Insert(true);

        if POSUnit.FindSet() then
            repeat
                if POSStore.Get(POSUnit."POS Store Code") then begin
                    if POSPostingProfile.Get(POSStore."POS Posting Profile") then begin
                        POSPostingSetup."POS Store Code" := POSStore.Code;
                        POSPostingSetup."Difference Account Type" := POSPostingSetup."Difference Account Type"::"G/L Account";
                        POSPostingSetup."Difference Acc. No." := POSPostingProfile."POS Posting Diff. Account";
                        POSPostingSetup."Difference Acc. No. (Neg)" := POSPostingProfile."Posting Diff. Account (Neg.)";
                        if not POSPostingSetup.Find() then
                            POSPostingSetup.Insert(true);
                    end;
                end;
            until POSUnit.Next() = 0;
    end;

    local procedure GetRandomPrecision() Precision: Decimal
    var
        LibraryRandom: Codeunit "Library - Random";
        Denominations: List of [Decimal];
    begin
        Denominations.Add(0.01);
        Denominations.Add(0.02);
        Denominations.Add(0.05);
        Denominations.Add(0.1);
        Denominations.Add(0.2);
        Denominations.Add(0.5);
        Denominations.Add(1);
        exit(Denominations.Get(LibraryRandom.RandIntInRange(1, Denominations.Count())));
    end;

    local procedure CreateDefaultValidateVoucherModule(): Code[20]
    var
        NpRvVoucherModule: Record "NPR NpRv Voucher Module";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        NpRvVoucherModule.SetRange(Type, NpRvVoucherModule.Type::"Validate Voucher");
        NpRvVoucherModule.SetRange("Event Codeunit ID", Codeunit::"NPR NpRv Module Valid.: Def.");
        if not NpRvVoucherModule.FindFirst() then begin
            NpRvVoucherModule.Init();
            NpRvVoucherModule.Type := NpRvVoucherModule.Type::"Validate Voucher";
            NpRvVoucherModule.Code := 'DEFAULT';
            NpRvVoucherModule."Event Codeunit ID" := Codeunit::"NPR NpRv Module Valid.: Def.";
            NpRvVoucherModule.Insert();
        end;
        exit(NpRvVoucherModule.Code);
    end;

    local procedure CreatePartialApplyVoucherModule(): Code[20]
    var
        NpRvVoucherModule: Record "NPR NpRv Voucher Module";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        NpRvVoucherModule.SetRange(Type, NpRvVoucherModule.Type::"Apply Payment");
        NpRvVoucherModule.SetRange("Event Codeunit ID", Codeunit::"NPR NpRv Module Pay. - Partial");
        if not NpRvVoucherModule.FindFirst() then begin
            NpRvVoucherModule.Init();
            NpRvVoucherModule.Type := NpRvVoucherModule.Type::"Apply Payment";
            NpRvVoucherModule.Code := 'PARTIAL';
            NpRvVoucherModule."Event Codeunit ID" := Codeunit::"NPR NpRv Module Pay. - Partial";
            NpRvVoucherModule.Insert();
        end;
        exit(NpRvVoucherModule.Code);
    end;

    local procedure CreateDefaultApplyVoucherModule(): Code[20]
    var
        NpRvVoucherModule: Record "NPR NpRv Voucher Module";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        NpRvVoucherModule.SetRange(Type, NpRvVoucherModule.Type::"Apply Payment");
        NpRvVoucherModule.SetRange("Event Codeunit ID", Codeunit::"NPR NpRv Module Pay.: Default");
        if not NpRvVoucherModule.FindFirst() then begin
            NpRvVoucherModule.Init();
            NpRvVoucherModule.Type := NpRvVoucherModule.Type::"Apply Payment";
            NpRvVoucherModule.Code := 'DEFAULT';
            NpRvVoucherModule."Event Codeunit ID" := Codeunit::"NPR NpRv Module Pay.: Default";
            NpRvVoucherModule.Insert();
        end;
        exit(NpRvVoucherModule.Code);
    end;

    local procedure CreateDefaultSendVoucherModule(): Code[20]
    var
        NpRvVoucherModule: Record "NPR NpRv Voucher Module";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        NpRvVoucherModule.SetRange(Type, NpRvVoucherModule.Type::"Send Voucher");
        NpRvVoucherModule.SetRange("Event Codeunit ID", Codeunit::"NPR NpRv Module Send: Def.");
        if not NpRvVoucherModule.FindFirst() then begin
            NpRvVoucherModule.Init();
            NpRvVoucherModule.Type := NpRvVoucherModule.Type::"Send Voucher";
            NpRvVoucherModule.Code := LibraryUtility.GenerateRandomCode20(NpRvVoucherModule.FieldNo(Code), Database::"NPR NpRv Voucher Module");
            NpRvVoucherModule."Event Codeunit ID" := Codeunit::"NPR NpRv Module Send: Def.";
            NpRvVoucherModule.Insert();
        end;
        exit(NpRvVoucherModule.Code);
    end;

    local procedure CreateVoucherPaymentMethod(): Code[10]
    var
        VoucherPOSPaymentMethod: Record "NPR POS Payment Method";
    begin
        CreatePOSPaymentMethod(VoucherPOSPaymentMethod, VoucherPOSPaymentMethod."Processing Type"::VOUCHER, '', false);
        exit(VoucherPOSPaymentMethod.Code);
    end;


    procedure CreateItemForPOSSaleUsage(var Item: Record Item; POSUnit: Record "NPR POS Unit"; POSStore: Record "NPR POS Store")
    var
        LibraryRandom: Codeunit "Library - Random";
        LibraryInventory: Codeunit "Library - Inventory";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        POSStore.GetProfile(POSPostingProfile);
        LibraryInventory.CreateItem(Item);
        Item.Validate("VAT Bus. Posting Gr. (Price)", POSPostingProfile."VAT Bus. Posting Group");

        Item."Price Includes VAT" := true;
        Item."Unit Price" := LibraryRandom.RandDec(1000, 2) + 1; //more than 1
        Item."Unit Cost" := LibraryRandom.RandDecInDecimalRange(0.01, Item."Unit Price", 1);
        Item.Modify();

        CreatePostingSetupForSaleItem(Item, POSUnit, POSStore);
    end;

    procedure CreateSalespersonForPOSUsage(var Salesperson: Record "Salesperson/Purchaser")
    var
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateSalesperson(Salesperson);
        Salesperson."NPR Register Password" := '1';
        Salesperson.Modify();
    end;

    procedure ItemReferenceCleanup()
    var
        ItemRef: Record "Item Reference";
    begin
        //Delete all item reference from template data, so all tests are independent instead of triggering lookup prompts for previous errors when not intended.
        ItemRef.SetCurrentKey("Reference No.");
        ItemRef.SetFilter("Reference No.", '<>%1', '');
        if not ItemRef.IsEmpty() then
            ItemRef.DeleteAll();
    end;

    procedure CreatePartialVoucherType(var VoucherType: Record "NPR NpRv Voucher Type"; AllowTopUp: Boolean)
    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";
    begin
        VoucherType.Init();
        VoucherType.Code := 'PARTIAL';
        VoucherType."Account No." := LibraryERM.CreateGLAccountWithSalesSetup();
        VoucherType."No. Series" := LibraryERM.CreateNoSeriesCode('P');
        VoucherType."Arch. No. Series" := LibraryERM.CreateNoSeriesCode('PA');
        VoucherType."Reference No. Type" := VoucherType."Reference No. Type"::Pattern;
        VoucherType."Reference No. Pattern" := '28[N][S][N*2]';
        VoucherType."Validate Voucher Module" := CreateDefaultValidateVoucherModule();
        VoucherType."Apply Payment Module" := CreatePartialApplyVoucherModule();
        VoucherType."Send Voucher Module" := CreateDefaultSendVoucherModule();
        VoucherType."Payment Type" := CreateVoucherPaymentMethod();
        VoucherType.Insert();
    end;

    procedure CreateDefaultVoucherType(var VoucherType: Record "NPR NpRv Voucher Type"; AllowTopUp: Boolean)
    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";
    begin
        VoucherType.Init();
        VoucherType.Code := 'DEFAULT';
        VoucherType."Account No." := LibraryERM.CreateGLAccountWithSalesSetup();
        VoucherType."No. Series" := LibraryERM.CreateNoSeriesCode('D');
        VoucherType."Arch. No. Series" := LibraryERM.CreateNoSeriesCode('DA');
        VoucherType."Reference No. Type" := VoucherType."Reference No. Type"::Pattern;
        VoucherType."Reference No. Pattern" := '18[N][S][N*2]';
        VoucherType."Validate Voucher Module" := CreateDefaultApplyVoucherModule();
        VoucherType."Apply Payment Module" := CreateDefaultApplyVoucherModule();
        VoucherType."Send Voucher Module" := CreateDefaultSendVoucherModule();
        VoucherType."Payment Type" := CreateVoucherPaymentMethod();
        VoucherType.Insert();
    end;

    procedure CreateReturnVoucherType(ReturnVoucherType: Code[20]; VoucherType: Code[20])
    var
        NpRvRetVouchType: Record "NPR NpRv Ret. Vouch. Type";
    begin
        NpRvRetVouchType.Init();
        NpRvRetVouchType."Voucher Type" := VoucherType;
        NpRvRetVouchType."Return Voucher Type" := ReturnVoucherType;
        NpRvRetVouchType.Insert();
    end;

}

