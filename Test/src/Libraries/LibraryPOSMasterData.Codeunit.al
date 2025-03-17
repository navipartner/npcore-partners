codeunit 85002 "NPR Library - POS Master Data"
{

    procedure CreatePOSUnit(var POSUnit: Record "NPR POS Unit"; POSStoreCode: Code[10]; POSProfileCode: Code[20])
    var
    begin
        CreatePOSUnit('', POSUnit, POSStoreCode, POSProfileCode);
    end;

    procedure CreatePOSUnit(PosUnitNo: Code[10]; var POSUnit: Record "NPR POS Unit"; POSStoreCode: Code[10]; POSProfileCode: Code[20])
    var
        POSStore: Record "NPR POS Store";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSMemberProfile: Record "NPR MM POS Member Profile";
        POSLoyaltyProfile: Record "NPR MM POS Loyalty Profile";
        POSTicketProfile: Record "NPR TM POS Ticket Profile";
        POSPaymentBin: record "NPR POS Payment Bin";
        LibraryUtility: Codeunit "Library - Utility";
        POSManagePOSUnit: Codeunit "NPR POS Manage POS Unit";
    begin

        if (not (POSUnit.Get(PosUnitNo)) or (PosUnitNo = '')) then begin
            POSUnit.Init();
            if (PosUnitNo = '') then
                POSUnit.Validate(
                    "No.",
                    CopyStr(
                    LibraryUtility.GenerateRandomCode(POSUnit.FieldNo("No."), DATABASE::"NPR POS Unit"), 1,
                    LibraryUtility.GetFieldLength(DATABASE::"NPR POS Unit", POSUnit.FieldNo("No."))))
            else
                POSUnit.Validate("No.", PosUnitNo);

            CreatePOSAuditProfile(POSAuditProfile);
            POSUnit."POS Audit Profile" := POSAuditProfile.Code;
            CreatePOSBin(POSPaymentBin);
            POSUnit."Default POS Payment Bin" := POSPaymentBin."No.";
            CreatePOSMemberProfile(POSMemberProfile);
            POSUnit."POS Member Profile" := POSMemberProfile.Code;
            CreatePOSLoyaltyProfile(POSLoyaltyProfile);
            POSUnit."POS Loyalty Profile" := POSLoyaltyProfile.Code;
            CreatePOSTicketProfile(POSTicketProfile);
            POSUnit."POS Ticket Profile" := POSTicketProfile.Code;
            POSUnit.Insert(true);
        end;

        if POSStoreCode = '' then
            CreatePOSStore(POSStore, POSProfileCode)
        else
            POSStore.Get(POSStoreCode);

        POSUnit."POS Store Code" := POSStore.Code;
        POSUnit.Validate(Status, POSUnit.Status::CLOSED);
        POSUnit.Modify();

        POSManagePOSUnit.OpenPosUnit(POSUnit);
        CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);
    end;

    procedure CreatePOSStore(var POSStore: Record "NPR POS Store"; POSProfileCode: Code[20])
    begin
        CreatePOSStore('', POSStore, POSProfileCode);
    end;

    procedure CreatePOSStore(POSStoreCode: Code[10]; var POSStore: Record "NPR POS Store"; POSProfileCode: Code[20])
    var
        LibraryUtility: Codeunit "Library - Utility";
        Location: Record Location;
        LibraryWarehouse: Codeunit "Library - Warehouse";
    begin
        if (not (POSStore.Get(POSStoreCode)) or (POSStoreCode = '')) then begin
            POSStore.Init();

            if (POSStoreCode = '') then
                POSStore.Validate(
                    Code,
                    CopyStr(
                        LibraryUtility.GenerateRandomCode(POSStore.FieldNo(Code), DATABASE::"NPR POS Store"), 1,
                        LibraryUtility.GetFieldLength(DATABASE::"NPR POS Store", POSStore.FieldNo(Code))))
            else
                POSStore.Validate(Code, POSStoreCode);

            LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location);
            POSStore.Validate("Location Code", Location.Code);
            POSStore."POS Posting Profile" := POSProfileCode;

            POSStore.Insert(true);
            CreatePOSPostingSetupSet(POSStore.Code, '', '');
        end;
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

    procedure CreatePOSPaymentMethod(var POSPaymentMethod: Record "NPR POS Payment Method"; ProcessingType: Enum "NPR Payment Processing Type"; CurrencyCode: Code[10]; PostCondensed: Boolean)
    var
        ReturnPOSPaymentMethod: Record "NPR POS Payment Method";
        POSPaymentBin: Record "NPR POS Payment Bin";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";
        Currency: Record Currency;
    begin
        POSPaymentMethod.Init();
        POSPaymentMethod.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(POSPaymentMethod.FieldNo(Code), DATABASE::"NPR POS Payment Method"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"NPR POS Payment Method", POSPaymentMethod.FieldNo(POSPaymentMethod.Code))));
        POSPaymentMethod.Validate("Processing Type", ProcessingType);
        POSPaymentMethod.Validate("Currency Code", CurrencyCode);
        GetCurrency(Currency, CurrencyCode);
        POSPaymentMethod.Validate("Post Condensed", PostCondensed);
        POSPaymentMethod.Validate("Rounding Type", Currency."Invoice Rounding Type");
        POSPaymentMethod.Validate("Rounding Gains Account", LibraryERM.CreateGLAccountNo);
        POSPaymentMethod.Validate("Rounding Losses Account", LibraryERM.CreateGLAccountNo);
        POSPaymentMethod.Validate("Rounding Precision", Currency."Amount Rounding Precision");
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

    local procedure GetCurrency(var Currency: Record Currency; CurrencyCode: Code[10])
    begin
        if CurrencyCode <> '' then
            Currency.Get(CurrencyCode)
        else
            Currency.InitRoundingPrecision();
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
            POSPostingSetup."Difference Acc. No. (Neg)" := POSPostingSetup."Difference Acc. No.";
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

    procedure CreatePOSPaymentMethod(var POSPaymentMethod: Record "NPR POS Payment Method"; No: Text; ProcessingType: Enum "NPR Payment Processing Type")
    var
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

    procedure CreatePOSAuditProfile(var POSAuditProfile: Record "NPR POS Audit Profile")
    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryNoSeries: Codeunit "NPR Library - No. Series";
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        POSAuditProfile.Init();
        POSAuditProfile.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(POSAuditProfile.FieldNo(Code), DATABASE::"NPR POS Audit Profile"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"NPR POS Audit Profile", POSAuditProfile.FieldNo(Code))));

        LibraryNoSeries.GenerateNoSeries('', NoSeries);
        NoSeriesLine.SetRange("Series Code", NoSeries.Code);
        NoSeriesLine.FindFirst();
        NoSeriesLine.Validate("Allow Gaps in Nos.", true);
        NoSeriesLine.Modify();
        POSAuditProfile."Bin Eject After Sale" := true;
        POSAuditProfile."Sales Ticket No. Series" := NoSeries.Code;
        POSAuditProfile.Insert();
    end;

    procedure CreatePOSTicketProfile(var POSTicketProfile: Record "NPR TM POS Ticket Profile")
    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryNoSeries: Codeunit "NPR Library - No. Series";
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        POSTicketProfile.Init();
        POSTicketProfile.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(POSTicketProfile.FieldNo(Code), DATABASE::"NPR TM POS Ticket Profile"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"NPR TM POS Ticket Profile", POSTicketProfile.FieldNo(Code))));

        LibraryNoSeries.GenerateNoSeries('', NoSeries);
        NoSeriesLine.SetRange("Series Code", NoSeries.Code);
        NoSeriesLine.FindFirst();
        NoSeriesLine.Validate("Allow Gaps in Nos.", true);
        NoSeriesLine.Modify();
        POSTicketProfile."Print Ticket On Sale" := true;
        POSTicketProfile.Insert();
    end;

    procedure CreatePOSMemberProfile(var POSMemberProfile: Record "NPR MM POS Member Profile")
    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryNoSeries: Codeunit "NPR Library - No. Series";
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        POSMemberProfile.Init();
        POSMemberProfile.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(POSMemberProfile.FieldNo(Code), DATABASE::"NPR MM POS Member Profile"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"NPR MM POS Member Profile", POSMemberProfile.FieldNo(Code))));

        LibraryNoSeries.GenerateNoSeries('', NoSeries);
        NoSeriesLine.SetRange("Series Code", NoSeries.Code);
        NoSeriesLine.FindFirst();
        NoSeriesLine.Validate("Allow Gaps in Nos.", true);
        NoSeriesLine.Modify();
        POSMemberProfile.Insert();
    end;

    procedure CreatePOSLoyaltyProfile(var POSLoyaltyProfile: Record "NPR MM POS Loyalty Profile")
    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryNoSeries: Codeunit "NPR Library - No. Series";
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        POSLoyaltyProfile.Init();
        POSLoyaltyProfile.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(POSLoyaltyProfile.FieldNo(Code), DATABASE::"NPR MM POS Loyalty Profile"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"NPR MM POS Loyalty Profile", POSLoyaltyProfile.FieldNo(Code))));

        LibraryNoSeries.GenerateNoSeries('', NoSeries);
        NoSeriesLine.SetRange("Series Code", NoSeries.Code);
        NoSeriesLine.FindFirst();
        NoSeriesLine.Validate("Allow Gaps in Nos.", true);
        NoSeriesLine.Modify();
        POSLoyaltyProfile."Assign Loyalty On Sale" := true;
        POSLoyaltyProfile.Insert();
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
        POSOpenPOSUnit.ClosePOSUnitOpenPeriods(POSUnit."POS Store Code", POSUnit."No."); // make sure pos period register is correct
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
        GeneralPostingSetup: Record "General Posting Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryNoSeries: Codeunit "NPR Library - No. Series";

    begin
        POSPostingProfile.Init();
        POSPostingProfile.Code := LibraryUtility.GenerateRandomCode20(POSPostingProfile.FieldNo(Code), Database::"NPR POS Posting Profile");
        if not POSPostingProfile.Find() then
            POSPostingProfile.Insert();

        POSPostingProfile."POS Posting Diff. Account" := LibraryERM.CreateGLAccountNo();
        POSPostingProfile."Max. POS Posting Diff. (LCY)" := 0.5;
        POSPostingProfile."POS Sales Rounding Account" := LibraryERM.CreateGLAccountWithSalesSetup();
        POSPostingProfile."POS Sales Amt. Rndng Precision" := 0.5;

        LibraryERM.CreateGeneralPostingSetupInvt(GeneralPostingSetup);
        POSPostingProfile.Validate("Gen. Bus. Posting Group", GeneralPostingSetup."Gen. Bus. Posting Group");
        LibraryERM.CreateVATPostingSetupWithAccounts(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT", 25);
        POSPostingProfile.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");

        POSPostingProfile."Posting Compression" := POSPostingProfile."Posting Compression"::"Per POS Entry";
        POSPostingProfile."POS Period Register No. Series" := LibraryNoSeries.GenerateNoSeries();

        POSPostingProfile.Modify();
    end;

    local procedure CreatePOSPostingSetup(var POSPaymentMethod: Record "NPR POS Payment Method")
    var
        POSPostingSetup: Record "NPR POS Posting Setup";
        POSUnit: Record "NPR POS Unit";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSStore: Record "NPR POS Store";
        LibraryERM: Codeunit "Library - ERM";
    begin

        if not POSPaymentMethod.Get(POSPaymentMethod.Code) then
            exit;
        POSPostingSetup.Init();
        POSPostingSetup."POS Store Code" := '';
        POSPostingSetup."POS Payment Method Code" := POSPaymentMethod.Code;
        POSPostingSetup."POS Payment Bin Code" := '';
        POSPostingSetup."Account Type" := POSPostingSetup."Account Type"::"G/L Account";
        POSPostingSetup."Account No." := LibraryERM.CreateGLAccountNo;

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

    local procedure GetRandomPrecision(): Decimal
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

    procedure DontPrintReceiptOnSaleEnd(POSUnit: Record "NPR POS Unit")
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
    begin
        if not POSAuditProfile.Get(POSUnit."POS Audit Profile") then
            exit;
        if POSAuditProfile."Do Not Print Receipt on Sale" then
            exit;
        POSAuditProfile."Do Not Print Receipt on Sale" := true;
        POSAuditProfile.Modify();
    end;

    procedure CreateItemForPOSSaleUsage(var Item: Record Item; POSUnit: Record "NPR POS Unit"; POSStore: Record "NPR POS Store"; VATProductPostingGroup: Record "VAT Product Posting Group")
    var
        NPRLibraryInventory: Codeunit "NPR Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        POSStore.GetProfile(POSPostingProfile);
        NPRLibraryInventory.CreateItem(Item);
        Item.Validate("VAT Prod. Posting Group", VATProductPostingGroup.Code);
        Item.Validate("VAT Bus. Posting Gr. (Price)", POSPostingProfile."VAT Bus. Posting Group");

        Item."Price Includes VAT" := true;
        Item."Unit Price" := LibraryRandom.RandDec(1000, 2) + 1; //more than 1
        Item."Unit Cost" := LibraryRandom.RandDecInDecimalRange(0.01, Item."Unit Price", 1);
        Item.Modify;

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

    procedure CreatePOSViewProfile(var POSViewProfile: Record "NPR POS View Profile")
    var
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        POSViewProfile.Init();
        POSViewProfile.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(POSViewProfile.FieldNo(Code), DATABASE::"NPR POS View Profile"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"NPR POS Audit Profile", POSViewProfile.FieldNo(Code))));
        POSViewProfile."Show Prices Including VAT" := not ApplicationAreaMgmt.IsSalesTaxEnabled();
        POSViewProfile.Insert();
    end;

    procedure AssignPOSViewProfileToPOSUnit(var POSUnit: Record "NPR POS Unit"; POSViewProfileCode: Code[20])
    begin
        POSUnit."POS View Profile" := POSViewProfileCode;
        POSUnit.Modify();
    end;

    procedure AssignVATBusPostGroupToPOSPostingProfile(POSStore: Record "NPR POS Store"; VATBusPostingGroupCode: Code[20])
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."VAT Bus. Posting Group" := VATBusPostingGroupCode;
        POSPostingProfile.Modify();
    end;

    procedure AssignTaxDetailToPOSPostingProfile(POSStore: Record "NPR POS Store"; TaxAreaCode: Code[20]; TaxLiable: Boolean)
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        POSStore.GetProfile(POSPostingProfile);
        POSPostingProfile."Tax Area Code" := TaxAreaCode;
        POSPostingProfile."Tax Liable" := TaxLiable;
        POSPostingProfile.Modify();
    end;

    procedure AssignVATPostGroupToPOSSalesRoundingAcc(POSStore: Record "NPR POS Store"; VATBusPostingGroupCode: Code[20]; VATProdPostingGroupCode: Code[20])
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        GLAcc: Record "G/L Account";
    begin
        POSStore.GetProfile(POSPostingProfile);
        GLAcc."No." := POSPostingProfile."POS Sales Rounding Account";
        GLAcc.Find();
        GLAcc."VAT Prod. Posting Group" := VATProdPostingGroupCode;
        GLAcc."VAT Bus. Posting Group" := VATBusPostingGroupCode;
        GLAcc.Modify();
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
        LibraryERM: Codeunit "Library - ERM";
        GeneralPostingSetup: Record "General Posting Setup";
        GLAccount: Record "G/L Account";
    begin
        VoucherType.Init();
        if (not VoucherType.Get('PARTIAL')) then begin
            VoucherType.Code := 'PARTIAL';
            VoucherType.Insert();
        end;
        VoucherType."Account No." := LibraryERM.CreateGLAccountWithSalesSetup();

        GLAccount.Get(VoucherType."Account No.");
        GeneralPostingSetup.Get(GLAccount."Gen. Bus. Posting Group", GLAccount."Gen. Prod. Posting Group");
        LibraryERM.SetGeneralPostingSetupSalesAccounts(GeneralPostingSetup);
        GeneralPostingSetup.Modify();

        VoucherType."No. Series" := LibraryERM.CreateNoSeriesCode('P');
        VoucherType."Arch. No. Series" := LibraryERM.CreateNoSeriesCode('PA');
        VoucherType."Reference No. Type" := VoucherType."Reference No. Type"::Pattern;
        VoucherType."Reference No. Pattern" := '28[N][S][N*2]';
        VoucherType."Validate Voucher Module" := CreateDefaultValidateVoucherModule();
        VoucherType."Apply Payment Module" := CreatePartialApplyVoucherModule();
        VoucherType."Send Voucher Module" := CreateDefaultSendVoucherModule();
        VoucherType."Payment Type" := CreateVoucherPaymentMethod();
        VoucherType.Modify();
    end;

    procedure CreateDefaultVoucherType(var VoucherType: Record "NPR NpRv Voucher Type"; AllowTopUp: Boolean)
    var
        LibraryERM: Codeunit "Library - ERM";
    begin
        VoucherType.Init();
        if (not VoucherType.Get('DEFAULT')) then begin
            VoucherType.Code := 'DEFAULT';
            VoucherType.Insert();
        end;
        VoucherType."Account No." := LibraryERM.CreateGLAccountWithSalesSetup();
        VoucherType."No. Series" := LibraryERM.CreateNoSeriesCode('D');
        VoucherType."Arch. No. Series" := LibraryERM.CreateNoSeriesCode('DA');
        VoucherType."Reference No. Type" := VoucherType."Reference No. Type"::Pattern;
        VoucherType."Reference No. Pattern" := '18[N][S][N*2]';
        VoucherType."Validate Voucher Module" := CreateDefaultApplyVoucherModule();
        VoucherType."Apply Payment Module" := CreateDefaultApplyVoucherModule();
        VoucherType."Send Voucher Module" := CreateDefaultSendVoucherModule();
        VoucherType."Payment Type" := CreateVoucherPaymentMethod();
        VoucherType.Modify();
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

    procedure SetPOSUnitTaxFreeProfile(var POSUnit: Record "NPR POS Unit"; POSTaxFreeProfileCode: Code[10])
    begin
        POSUnit."POS Tax Free Prof." := POSTaxFreeProfileCode;
        POSUnit.Modify();
    end;

    procedure CreatePosMenuFilter(ObjectType: Option ,,,"Report",,"Codeunit","XMLPort",,"Page"; ObjectID: Integer; FilterCode: Code[20])
    var
        POSMenuFilter: Record "NPR POS Menu Filter";
    begin
        if not POSMenuFilter.Get(FilterCode) then begin
            POSMenuFilter.Init();
            POSMenuFilter."Filter Code" := FilterCode;
            POSMenuFilter.Insert();
        end;
        POSMenuFilter."Object Type" := ObjectType;
        POSMenuFilter."Object Id" := ObjectID;
        POSMenuFilter.Active := true;
        POSMenuFilter.Modify();
    end;

    procedure CreatePOSInfo(POSInfoCode: code[20]; InputType: Option "Text","SubCode","Table"; Type: Option "Show Message","Request Data","Write Default Message"; MessageTxt: Text[50])
    var
        POSInfo: Record "NPR POS Info";
    begin
        if not POSInfo.Get(POSInfoCode) then begin
            POSInfo.Init();
            POSInfo.Validate(Code, POSInfoCode);
            POSInfo.Insert(true);
        end;
        POSInfo.Validate("Input Type", InputType);
        POSInfo.Validate(Type, Type);
        POSInfo.Validate(Message, MessageTxt);
        POSInfo.Modify(true);
    end;

    internal procedure CreatePriceProfile(PriceProfileCode: Code[20])
    var
        POSPricingProfile: Record "NPR POS Pricing Profile";
        CustomerPriceGroup: Record "Customer Price Group";
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateCustomerPriceGroup(CustomerPriceGroup);
        POSPricingProfile.Init();
        POSPricingProfile.Code := PriceProfileCode;
        POSPricingProfile."Customer Price Group" := CustomerPriceGroup.Code;
        POSPricingProfile.Insert()
    end;

    internal procedure CreatePriceListLine(PriceSourceType: Enum "Price Source Type"; SourceNo: Code[20]; ItemNo: Code[20]; Price: Decimal; VATBusPostingGroup: Code[20])
    var
        PriceListHeader: Record "Price List Header";
        PriceListLine: Record "Price List Line";
        LibraryPriceCalculation: Codeunit "Library - Price Calculation";
    begin
        PriceListHeader.SetRange("Source Type", PriceSourceType);
        PriceListHeader.SetRange("Source No.", SourceNo);
        if not PriceListHeader.FindFirst() then
            LibraryPriceCalculation.CreatePriceHeader(PriceListHeader, Enum::"Price Type"::Sale, PriceSourceType, SourceNo);

        PriceListHeader.Validate("Price Includes VAT", true);
        PriceListHeader.Validate("VAT Bus. Posting Gr. (Price)", VATBusPostingGroup);
        PriceListHeader.Modify();

        PriceListLine.SetRange("Price List Code", PriceListHeader.Code);
        PriceListLine.SetRange("Asset Type", PriceListLine."Asset Type"::Item);
        PriceListLine.SetRange("Asset No.", ItemNo);
        if not PriceListLine.FindFirst() then
            LibraryPriceCalculation.CreatePriceListLine(PriceListLine, PriceListHeader, Enum::"Price Amount Type"::Price, Enum::"Price Asset Type"::Item, ItemNo);
        PriceListLine."Unit Price" := Price;
        PriceListLine.Modify();

        if PriceListHeader.Status <> PriceListHeader.Status::Active then begin
            PriceListHeader.Validate(Status, PriceListHeader.Status::Active);
            PriceListHeader.Modify();
        end;
    end;

    #region CreateDefaultGroupCodeSetup
    internal procedure CreateDefaultGroupCodeSetup(var NPRGroupCode: Record "NPR Group Code")
    begin
        NPRGroupCode.Init();
        NPRGroupCode.Code := 'DEFAULT';
        NPRGroupCode.Description := 'DEFAULT';
        NPRGroupCode.Insert();
    end;
    #endregion CreateDefaultGroupCodeSetup
}

