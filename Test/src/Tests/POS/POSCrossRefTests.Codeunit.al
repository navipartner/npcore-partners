codeunit 85036 "NPR POS Cross Ref. Tests"
{
    // // [Feature] POS Cross Reference
    Subtype = Test;
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
        Initialized := false;
    end;

    var
        POSUnit: Record "NPR POS Unit";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSStore: Record "NPR POS Store";
        POSSetup: Record "NPR POS Setup";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        POSSession: Codeunit "NPR POS Session";
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";
        LibraryTaxCalc: Codeunit "NPR POS Lib. - Tax Calc.";
        Initialized: Boolean;


    [Test]
    procedure VerifyCrossReferenceSetupRegistered()
    var
        POSCrossRefSetup: Record "NPR POS Cross Ref. Setup";
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSCrossRefSetupList: TestPage "NPR POS Cross Ref. Setup";
    begin
        // [SCENARIO] Verify POS Cross Reference are registered

        // [GIVEN] Clear cross references
        POSCrossRefSetup.DeleteAll();

        // [WHEN] POS Cross Reference Setup is opened
        POSCrossRefSetupList.OpenView();
        POSCrossRefSetupList.Close();

        // [THEN] Verify cross references are registered for active sale
        Assert.IsTrue(POSCrossRefSetup.Get(POSSale.TableName()), 'Cross Reference not registered for POS Sale');
        Assert.IsTrue(POSCrossRefSetup.Get(POSSaleLine.TableName()), 'Cross Reference Line not registered for POS Sale Line');
    end;

    [HandlerFunctions('TableObjectsModalPageHandler')]
    [Test]
    procedure CrossRefSetupLookupTableName()
    var
        POSCrossRefSetup: Record "NPR POS Cross Ref. Setup";
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        POSCrossRefSetupList: TestPage "NPR POS Cross Ref. Setup";
    begin
        // [SCENARIO] Verify table selection on table name lookup

        // [GIVEN] POS Cross Reference Setup is opened
        POSCrossRefSetupList.OpenEdit();

        // [GIVEN] Create new record
        POSCrossRefSetupList.New();

        // [WHEN] Lookup on Table Name
        POSCrossRefSetupList."Table Name".Lookup();

        // [THEN] Table Objects page is opened and closed with handler function
    end;

    [Test]
    procedure CrossRefSetupValidateUnknownTableNameErr()
    var
        POSCrossRefSetup: Record "NPR POS Cross Ref. Setup";
        POSCrossRefSetupList: TestPage "NPR POS Cross Ref. Setup";
    begin
        // [SCENARIO] Verify error is thrown when unknown table name is inserted manually

        // [GIVEN] POS Cross Reference Setup is opened
        POSCrossRefSetupList.OpenEdit();

        // [GIVEN] Create new record
        POSCrossRefSetupList.New();

        // [WHEN] Unknown table name is then error is thrown
        asserterror POSCrossRefSetupList."Table Name".SetValue('Dummy Table Name');
    end;

    [Test]
    procedure CrossRefSetupValidateTableName()
    var
        POSCrossRefSetup: Record "NPR POS Cross Ref. Setup";
        POSCrossRefSetupList: TestPage "NPR POS Cross Ref. Setup";
    begin
        // [SCENARIO] Verify table name when value is inserted manually

        // [GIVEN] POS Cross Reference Setup is opened
        POSCrossRefSetupList.OpenEdit();

        // [GIVEN] Create new record
        POSCrossRefSetupList.New();

        // [WHEN] Unknown table name is then error is thrown
        POSCrossRefSetupList."Table Name".SetValue(POSCrossRefSetup.TableName());
        POSCrossRefSetupList.Close();

        // [THEN] Verify record has been added to cross reference setup
        Assert.IsTrue(POSCrossRefSetup.Get(POSCrossRefSetup.TableName()), 'Cross Reference not registered for table POS Cross Ref. Setup');
    end;

    [Test]
    procedure VerifyCrossReferenceIsInitializedPOSSaleLine()
    var
        POSSaleLine: Record "NPR POS Sale Line";
        POSCrossReference: Record "NPR POS Cross Reference";
        POSCrossRefMgt: Codeunit "NPR POS Cross Reference Mgt.";
        POSCrossRefSetupList: TestPage "NPR POS Cross Ref. Setup";
        ReferenceNo: Text;
    begin
        // [SCENARIO] Verify POS Cross reference is created for POS Sale Line

        // [GIVEN] Registered POS Cross Reference Setup
        POSCrossRefSetupList.OpenView();
        POSCrossRefSetupList.Close();

        // [GIVEN] Start new sale and create reference for active sale line
        GetCurrentSaleLine(POSSaleLine);

        // Verify SystemId is set
        Assert.IsFalse(IsNullGuid(POSSaleLine.SystemId), 'POS Sale Line has not been created');

        // [WHEN] Cross reference is initialized
        ReferenceNo := Uppercase(LibraryRandom.RandText(MaxStrLen(POSCrossReference."Reference No.")));
        POSCrossRefMgt.InitReference(
                            POSSaleLine.SystemId,
                            ReferenceNo,
                            POSSaleLine.TableName(),
                            POSSaleLine."Sales Ticket No." + '_' + Format(POSSaleLine."Line No."));

        // [THEN] Verify Cross Reference is created for active sale
        Assert.IsTrue(POSCrossReference.GetBySystemId(POSSaleLine.SystemId), 'POS Cross Reference is not created for active sale');
        Assert.AreNotEqual(0, POSCrossReference."Entry No.", 'Entry No. of POS Cross Reference is not auto incremented');
        Assert.AreEqual(ReferenceNo, POSCrossReference."Reference No.", 'Reference No. is not properly initialized');
        Assert.AreEqual(POSSaleLine.TableName(), POSCrossReference."Table Name", 'Table Name is not properly initialized');
        Assert.AreEqual(
                    CopyStr(POSSaleLine."Sales Ticket No." + '_' + Format(POSSaleLine."Line No."), 1, MaxStrLen(POSCrossReference."Reference No.")),
                    POSCrossReference."Record Value", 'Record Value is not properly initialized');
    end;

    [Test]
    procedure VerifyCrossReferenceIsUpdatedEndOfSale()
    var
        POSSale: Record "NPR POS Sale";
        POSSaleLine: Record "NPR POS Sale Line";
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSCrossReference: Record "NPR POS Cross Reference";
        POSCrossRefSetupList: TestPage "NPR POS Cross Ref. Setup";
    begin
        // [SCENARIO] Verify POS Cross reference is updated when POS sale is ended

        // [GIVEN] Registered POS Cross Reference Setup
        POSCrossRefSetupList.OpenView();
        POSCrossRefSetupList.Close();

        // [WHEN] Sale is finished
        EndOfSale(POSEntry, POSEntrySalesLine, POSSale, POSSaleLine);

        // [THEN] Verify cross reference has been updated
        //Active and finished sales line have same systemid
        Assert.IsTrue(POSCrossReference.GetBySystemId(POSSaleLine.SystemId), 'POS Cross Reference is not created for active sale line');
        Assert.AreNotEqual(POSSale.TableName(), POSCrossReference."Table Name", 'Table Name is not properly initialized');
        Assert.IsTrue(POSCrossReference.GetBySystemId(POSEntrySalesLine.SystemId), 'POS Cross Reference is not created for entry sale line');
        Assert.AreEqual(POSEntrySalesLine.TableName(), POSCrossReference."Table Name", 'Table Name is not properly initialized for entry sale line');
    end;

    [Test]
    procedure VerifyCrossReferenceIsRemoved()
    var
        POSSale: Record "NPR POS Sale";
        POSSaleLine: Record "NPR POS Sale Line";
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSCrossReference: Record "NPR POS Cross Reference";
        POSCrossRefSetupList: TestPage "NPR POS Cross Ref. Setup";
    begin
        // [SCENARIO] Verify POS Cross reference is removed when POS Entries are deleted

        // [GIVEN] Registered POS Cross Reference Setup
        POSCrossRefSetupList.OpenView();
        POSCrossRefSetupList.Close();

        // [GIVEN] Sale is finished
        EndOfSale(POSEntry, POSEntrySalesLine, POSSale, POSSaleLine);

        // [WHEN] Finished sale is removed
        POSEntry.Delete(true);

        // [THEN] Verify Cross reference for active and finished sale is removed
        POSCrossReference.Setrange("Table Name", POSEntry.TableName());
        Assert.IsFalse(POSCrossReference.FindFirst(), 'POS Cross Reference is not removed for entry sale');

        POSCrossReference.Setrange("Table Name", POSSale.TableName());
        Assert.IsFalse(POSCrossReference.FindFirst(), 'POS Cross Reference is not removed for active sale');

        POSCrossReference.Setrange("Table Name", POSEntrySalesLine.TableName());
        Assert.IsFalse(POSCrossReference.FindFirst(), 'POS Cross Reference is not removed for entry sale line');
    end;

    procedure InitializeData()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryERM: Codeunit "Library - ERM";
    begin
        if Initialized then begin
            //Clean any previous mock session
            POSSession.Destructor();
            Clear(POSSession);
            DeletePOSPostedEntries();
        end;

        if not Initialized then begin
            LibraryTaxCalc.BindNormalTaxCalcTest();
            LibraryERM.CreateVATBusinessPostingGroup(VATBusinessPostingGroup);
            LibraryPOSMasterData.CreatePOSSetup(POSSetup);
            LibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            LibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
            LibraryPOSMasterData.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
            LibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);

            Initialized := true;
        end;

        Commit();
    end;

    local procedure DeletePOSPostedEntries()
    var
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
    begin
        POSEntry.DeleteAll();
        POSEntrySalesLine.DeleteAll();
        POSEntryPaymentLine.DeleteAll();
    end;

    local procedure GetCurrentSaleLine(var POSSaleLine: Record "NPR POS Sale Line")
    var
        POSSale: Record "NPR POS Sale";
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
        POSViewProfile: Record "NPR POS View Profile";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSSaleLineUnit: Codeunit "NPR POS Sale Line";

        Qty: Decimal;
    begin
        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");
        VATPostingSetup."VAT %" := 10;
        VATPostingSetup.Modify();
        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATProdPostGroupToPOSSalesRoundingAcc(VATPostingSetup."VAT Prod. Posting Group");

        // [GIVEN] POS View Profile
        CreatePOSViewProfile(POSViewProfile);
        POSViewProfile."Tax Type" := POSViewProfile."Tax Type"::VAT;
        POSViewProfile.Modify();
        AssignPOSViewProfileToPOSUnit(POSViewProfile.Code);

        // [GIVEN] Item with unit price        
        CreateItem(Item, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', true);
        Item."Unit Price" := 100;
        Item.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSaleUnit);

        // [GIVEN] Add Item to active sale
        Qty := 1;
        LibraryPOSMock.CreateItemLine(POSSession, Item."No.", Qty);

        POSSession.GetSaleLine(POSSaleLineUnit);
        POSSaleLineUnit.GetCurrentSaleLine(POSSaleLine);
    end;

    local procedure EndOfSale(var POSEntry: Record "NPR POS Entry"; var POSEntrySalesLine: Record "NPR POS Entry Sales Line"; var POSSale: Record "NPR POS Sale"; var POSSaleLine: Record "NPR POS Sale Line")
    var
        Item: Record Item;
        POSCrossReference: Record "NPR POS Cross Reference";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        POSCrossRefMgt: Codeunit "NPR POS Cross Reference Mgt.";
        AmountToPay: Decimal;
        SaleEnded: Boolean;
        ReferenceNo: Text;
    begin
        // [GIVEN] Initialize POS Sale
        GetCurrentSaleLine(POSSaleLine);

        // [GIVEN] Amount to pay
        Item.Get(POSSaleLine."No.");
        AmountToPay := Item."Unit Price";

        POSSession.GetSale(POSSaleUnit);
        POSSaleUnit.GetCurrentSale(POSSale);

        // [GIVEN] Cross reference is initialized for active sale line
        ReferenceNo := Uppercase(LibraryRandom.RandText(MaxStrLen(POSCrossReference."Reference No.")));
        POSCrossRefMgt.InitReference(
                            POSSaleLine.SystemId,
                            ReferenceNo,
                            POSSaleLine.TableName(),
                            POSSaleLine."Sales Ticket No." + '_' + Format(POSSaleLine."Line No."));

        // [GIVEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();

        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := POSSaleLine."Line No.";
        POSEntrySalesLine.Find();
    end;

    local procedure CreateVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; TaxCaclType: Enum "NPR POS Tax Calc. Type")
    var
        VATProductPostingGroup: Record "VAT Product Posting Group";
        LibraryTaxCalc2: codeunit "NPR POS Lib. - Tax Calc.";
        LibraryERM: Codeunit "Library - ERM";
    begin
        LibraryERM.CreateVATProductPostingGroup(VATProductPostingGroup);
        if TaxCaclType = TaxCaclType::"Sales Tax" then
            LibraryTaxCalc2.CreateSalesTaxPostingSetup(VATPostingSetup, VATBusinessPostingGroup.Code, VATProductPostingGroup.Code, TaxCaclType)
        else
            LibraryTaxCalc2.CreateTaxPostingSetup(VATPostingSetup, VATBusinessPostingGroup.Code, VATProductPostingGroup.Code, TaxCaclType);
    end;

    local procedure AssignVATBusPostGroupToPOSPostingProfile(VATBusPostingGroupCode: Code[20])
    var
        LibraryPOSMasterData: codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.AssignVATBusPostGroupToPOSPostingProfile(POSStore, VATBusPostingGroupCode);
    end;

    local procedure AssignVATProdPostGroupToPOSSalesRoundingAcc(VATProdPostingGroupCode: Code[20])
    var
        LibraryPOSMasterData: codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.AssignVATProdPostGroupToPOSSalesRoundingAcc(POSStore, VATProdPostingGroupCode);
    end;

    local procedure CreateItem(var Item: Record Item; VATBusPostingGroupCode: Code[20]; VATProdPostingGroupCode: Code[20]; TaxGroupCode: Code[20]; PricesIncludesVAT: Boolean)
    var
        LibraryTaxCalc2: codeunit "NPR POS Lib. - Tax Calc.";
    begin
        LibraryTaxCalc2.CreateItem(Item, VATProdPostingGroupCode, VATBusPostingGroupCode);
        Item."Price Includes VAT" := PricesIncludesVAT;
        Item."Tax Group Code" := TaxGroupCode;
        Item.Modify();
        CreateGeneralPostingSetupForItem(Item);
    end;

    local procedure CreateGeneralPostingSetupForItem(Item: Record Item)
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        LibraryPOSMasterData: codeunit "NPR Library - POS Master Data";
    begin
        POSStore.GetProfile(POSPostingProfile);
        LibraryPOSMasterData.CreateGeneralPostingSetupForSaleItem(
                                        POSPostingProfile."Gen. Bus. Posting Group",
                                        Item."Gen. Prod. Posting Group",
                                        POSStore."Location Code",
                                        Item."Inventory Posting Group");
    end;

    local procedure CreatePOSViewProfile(var POSViewProfile: Record "NPR POS View Profile")
    var
        LibraryPOSMasterData: codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.CreatePOSViewProfile(POSViewProfile);
    end;

    local procedure AssignPOSViewProfileToPOSUnit(POSViewProfileCode: Code[20])
    var
        LibraryPOSMasterData: codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.AssignPOSViewProfileToPOSUnit(POSUnit, POSViewProfileCode);
    end;

    [ModalPageHandler]
    procedure TableObjectsModalPageHandler(var TableObjects: TestPage "Table Objects")
    begin
    end;

}