codeunit 85148 "NPR POS Total Disc. and Tax"
{
    // [Feature] POS Total Discount
    Subtype = Test;
    EventSubscriberInstance = Manual;
    Permissions = TableData "G/L Entry" = rimd,
                  TableData "VAT Entry" = rimd;

    trigger OnRun()
    begin
        Initialized := false;
    end;


    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
        TaxGroup: Record "Tax Group";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        Assert: Codeunit Assert;
        LibraryTaxCalc: Codeunit "NPR POS Lib. - Tax Calc.";
        POSSession: Codeunit "NPR POS Session";

        Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VerifyDiscountEnabled()
    var
        DiscountPriority: Record "NPR Discount Priority";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
        DiscountPriorityList: TestPage "NPR Discount Priority List";
    begin
        // [SCENARIO] Exercise & verify discount is enabled

        // [GIVEN] Clear discounts priority
        DiscountPriority.DeleteAll();

        // [WHEN] Discount Priority List is opened
        DiscountPriorityList.OpenView();
        DiscountPriorityList.Close();

        // [THEN] Verify discount is enabled
        Assert.IsTrue(DiscountPriority.Get(NPRTotalDiscountManagement.DiscSourceTableId()), 'Discount not created');
        Assert.IsFalse(DiscountPriority.Disabled, 'Discount is disabled');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountEditableWhenEnabledAndLineCreated()
    var
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        StatusErrorLbl: Label 'Total Discount %1 must be set to pending before editing.', Comment = '%1 - Status';
    begin
        // [SCENARIO] Check if you can add a total discount line to the total discount when the discount is enabled.

        // [Given] Enabled Total Discount 
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);
        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [When] When you try to edit the total disocunt while it is enabled
        asserterror CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                            Enum::"NPR Total Discount Line Type"::All,
                                            '',
                                            '',
                                            NPRTotalDiscountLine);

        // [Then] The system should return an error that that you cannot edit the total discount while it is enabled  
        Assert.ExpectedError(StrSubstNo(StatusErrorLbl, NPRTotalDiscountHeader.Code));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountEditableWhenEnabledAndBenefitCreated()
    var
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        StatusErrorLbl: Label 'Total Discount %1 must be set to pending before editing.', Comment = '%1 - Status';
    begin
        // [SCENARIO] Check if you can add a total discount benefit line when the total discount is enabled.

        // [Given] Enabled Total Discount 
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);
        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [When] When you try to edit the total disocunt while it is enabled
        asserterror CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                                1000,
                                                Enum::"NPR Total Disc. Benefit Type"::Discount,
                                                '',
                                                '',
                                                0,
                                                Enum::"NPR Total Disc Ben Value Type"::Percent,
                                                50,
                                                false,
                                                NPRTotalDiscountBenefit);

        // [Then] The system should return an error that that you cannot edit the total discount while it is enabled 
        Assert.ExpectedError(StrSubstNo(StatusErrorLbl, NPRTotalDiscountHeader.Code));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountEditableWhenEnabledAndActiveTimeIntervalCreated()
    var
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        StatusErrorLbl: Label 'Total Discount %1 must be set to pending before editing.', Comment = '%1 - Status';
    begin
        // [SCENARIO] Check if you can add a total discount time interval when the total discount is enabled.

        // [Given] Enabled Total Discount 
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);
        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [When] When you try to edit the total disocunt while it is enabled
        asserterror CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                                          0T,
                                                          0T,
                                                          NPRTotalDiscTimeInterv);

        // [Then] The system should return an error that that you cannot edit the total discount while it is enabled 
        Assert.ExpectedError(StrSubstNo(StatusErrorLbl, NPRTotalDiscountHeader.Code));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountEditableWhenEnabledAndHeaderUpdated()
    var
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        StatusErrorLbl: Label 'Total Discount %1 must be set to pending before editing.', Comment = '%1 - Status';
    begin
        // [SCENARIO] Check if you can edit the total discount header when the total discount is enabled.

        // [Given] Enabled Total Discount 
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);
        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [When] When you try to edit the total disocunt while it is enabled
        asserterror ChangeTotalDiscountDescription(NPRTotalDiscountHeader,
                                                   'test');
        // [Then] The system should return an error that that you cannot edit the total discount while it is enabled  
        Assert.ExpectedError(StrSubstNo(StatusErrorLbl, NPRTotalDiscountHeader.Code));

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountEditableWhenEnabledAndLineUpdated()
    var
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        StatusErrorLbl: Label 'Total Discount %1 must be set to pending before editing.', Comment = '%1 - Status';
    begin
        // [SCENARIO] Check if you can edit the total discount lines when the total discount is enabled.

        // [Given] Total Discount Header 
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        // [Given] Total Discount Line 
        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::All,
                                '',
                                '',
                                NPRTotalDiscountLine);

        // [Given] Enabled Total Discount Header 
        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [When] When you try to edit the total disocunt line while the total discount it is enabled
        asserterror ChangeTotalDiscountLineDescription(NPRTotalDiscountLine,
                                                       'test');

        // [Then] The system should return an error that that you cannot edit the total discount while it is enabled  
        Assert.ExpectedError(StrSubstNo(StatusErrorLbl, NPRTotalDiscountHeader.Code));

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountEditableWhenEnabledAndBenefitUpdated()
    var
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        StatusErrorLbl: Label 'Total Discount %1 must be set to pending before editing.', Comment = '%1 - Status';
    begin
        // [SCENARIO] Check if you can edit the total discount benefit lines when the total discount is enabled.

        // [Given] Total Discount Header 
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        // [Given] Total Discount Discount Benefit 
        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Percent,
                                    50,
                                    false,
                                    NPRTotalDiscountBenefit);

        // [Given] Enabled Total Discount Header 
        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [When] When you try to edit the total disocunt benefit while the total discount it is enabled
        asserterror ChangeTotalDiscountBenefitDescription(NPRTotalDiscountBenefit,
                                                          'test');

        // [Then] The system should return an error that that you cannot edit the total discount while it is enabled  
        Assert.ExpectedError(StrSubstNo(StatusErrorLbl, NPRTotalDiscountHeader.Code));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountEditableWhenEnabledAndActiveTimeIntervalUpdated()
    var
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        StatusErrorLbl: Label 'Total Discount %1 must be set to pending before editing.', Comment = '%1 - Status';
    begin
        // [SCENARIO] Check if you can edit the total discount time interval lines when the total discount is enabled.

        // [Given] Total Discount Header 
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        // [Given] Total Discount Discount Active Period 
        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        // [Given] Enabled Total Discount Header 
        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [When] When you try to edit the total disocunt benefit active time interval while the total discount it is enabled
        asserterror NPRTotalDiscTimeInterv.Modify(true);

        // [Then] The system should return an error that that you cannot edit the total discount while it is enabled  
        Assert.ExpectedError(StrSubstNo(StatusErrorLbl, NPRTotalDiscountHeader.Code));
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountEditableWhenEnabledAndHeaderDelete()
    var
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        StatusErrorLbl: Label 'Total Discount %1 must be set to pending before editing.', Comment = '%1 - Status';
    begin
        // [SCENARIO] Check if you can delete the total discount header when the total discount is enabled.

        // [Given] Total Discount Header 
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        // [Given] Enabled Total Discount Header 
        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [When] When you try to delete the total disocunt header while the total discount it is enabled
        asserterror NPRTotalDiscountHeader.Delete(true);

        // [Then] The system should return an error that that you cannot edit the total discount while it is enabled  
        Assert.ExpectedError(StrSubstNo(StatusErrorLbl, NPRTotalDiscountHeader.Code));

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountEditableWhenEnabledAndLineDelete()
    var
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        StatusErrorLbl: Label 'Total Discount %1 must be set to pending before editing.', Comment = '%1 - Status';
    begin
        // [SCENARIO] Check if you can delete a total discount line when the total discount is enabled.

        // [Given] Total Discount Header 
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        // [Given] Total Discount Line 
        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::All,
                                '',
                                '',
                                NPRTotalDiscountLine);

        // [Given] Enabled Total Discount Header 
        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [When] When you try to delete the total disocunt line while the total discount it is enabled
        asserterror NPRTotalDiscountLine.Delete(true);

        // [Then] The system should return an error that that you cannot edit the total discount while it is enabled  
        Assert.ExpectedError(StrSubstNo(StatusErrorLbl, NPRTotalDiscountHeader.Code));

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountEditableWhenEnabledAndBenefitDelete()
    var
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        StatusErrorLbl: Label 'Total Discount %1 must be set to pending before editing.', Comment = '%1 - Status';
    begin
        // [SCENARIO] Check if you can delete a total discount benefit line when the total discount is enabled.

        // [Given] Total Discount Header 
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        // [Given] Total Discount Discount Benefit 
        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Percent,
                                    50,
                                    false,
                                    NPRTotalDiscountBenefit);

        // [Given] Enabled Total Discount Header 
        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [When] When you try to deelte the total disocunt benefit while the total discount it is enabled
        asserterror NPRTotalDiscountBenefit.Delete(true);

        // [Then] The system should return an error that that you cannot edit the total discount while it is enabled  
        Assert.ExpectedError(StrSubstNo(StatusErrorLbl, NPRTotalDiscountHeader.Code));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountEditableWhenEnabledAndActiveTimeIntervalDelete()
    var
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        StatusErrorLbl: Label 'Total Discount %1 must be set to pending before editing.', Comment = '%1 - Status';
    begin
        // [SCENARIO] Check if you can delete a total discount time interval line when the total discount is enabled.

        // [Given] Total Discount Header 
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                    '',
                                    Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                    Enum::"NPR Total Discount Application"::"Discount Filters",
                                    0);

        // [Given] Total Discount Discount Active Period 
        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        // [Given] Enabled Total Discount Header 
        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [When] When you try to delete the total disocunt benefit active time interval while the total discount it is enabled
        asserterror NPRTotalDiscTimeInterv.Delete(true);

        // [Then] The system should return an error that that you cannot edit the total discount while it is enabled  
        Assert.ExpectedError(StrSubstNo(StatusErrorLbl, NPRTotalDiscountHeader.Code));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountCanBeEnabledWithoutDiscountLines()
    var
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        StatusErrorLbl: Label 'No filters defined for total discount %1 - %2.', Comment = '%1 - Total Discount Code, %2 - Total Discount Description';
    begin
        // [SCENARIO] Check if you can enable the total discount without total discount lines

        // [Given] Total Discount Header 
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);
        // [When] When trying to enabled the total discount without lines
        asserterror NPRTotalDiscountHeader.Validate(Status, NPRTotalDiscountHeader.Status::Active);

        // [Then] The system should return an error that that you cannot edit the total discount while it is enabled  
        Assert.ExpectedError(StrSubstNo(StatusErrorLbl,
                                        NPRTotalDiscountHeader.Code,
                                        NPRTotalDiscountHeader.Description));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountCanBeEnabledWithoutBenefitLines()
    var
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        StatusErrorLbl: Label 'There is no Total Discount Benefit within the filter.';
    begin
        // [SCENARIO] Check if you can enable the total discount without total discount benefit lines

        // [Given] Total Discount Header 
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        // [Given] Total Discount Line 
        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::All,
                                '',
                                '',
                                NPRTotalDiscountLine);

        // [When] When trying to enabled the total discount without lines
        asserterror NPRTotalDiscountHeader.Validate(Status, NPRTotalDiscountHeader.Status::Active);

        // [Then] The system should return an error that that you cannot edit the total discount while it is enabled  
        Assert.ExpectedError(StatusErrorLbl);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountNotFoundOnNewPOSLine()
    var
        Item: Record Item;
        POSSaleLine: Record "NPR POS Sale Line";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleUnit: Codeunit "NPR POS Sale";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
        TotalDiscountPercent: Decimal;
        TotalDiscountStepAmount: Decimal;
    begin
        // [SCENARIO] Check if the total discount is triggered when adding a new line to the pos sale

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);

        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        TotalDiscountPercent := 50;
        TotalDiscountStepAmount := 1000;
        CreateTotalDiscountForAllWithWithOneStepDiscountPercent(NPRTotalDiscountHeader,
                                                                NPRTotalDiscountLine,
                                                                NPRTotalDiscountBenefit,
                                                                NPRTotalDiscTimeInterv,
                                                                TotalDiscountStepAmount,
                                                                TotalDiscountPercent);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSaleUnit);

        // [When] Insert operation is perfromed
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item."No.",
                                      1);

        // [THEN] Verify Discount 
        Assert.IsTrue(POSSaleLine."Total Discount Code" = '', 'Total Discount is activated on insert.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountWithoutFiltersTriggeredOnTotalPressed()
    var
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
        TotalDiscountPercent: Decimal;
        TotalDiscountStepAmount: Decimal;
    begin
        // [SCENARIO] Check if the total discount without filters is triggered when total pressed

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);

        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        TotalDiscountPercent := 50;
        TotalDiscountStepAmount := 1000;
        CreateTotalDiscountForAllWithWithOneStepDiscountPercent(NPRTotalDiscountHeader,
                                                                NPRTotalDiscountLine,
                                                                NPRTotalDiscountBenefit,
                                                                NPRTotalDiscTimeInterv,
                                                                TotalDiscountStepAmount,
                                                                TotalDiscountPercent);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);

        // [Given] POS Sale Line
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOS);

        //RefreshLine
        if SaleLinePOS.Get(SaleLinePOS.RecordId) then;

        // [THEN] Verify Discount 
        Assert.IsTrue(SaleLinePOS."Total Discount Code" <> '', 'Total Discount was not triggered but it had to be triggered.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountOutsideTimeInvervalNotTriggerOnTotalPressed()
    var
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        // [SCENARIO] Check if the total discount outside time interval is not triggered

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);

        Item."Unit Price" := 1000;
        Item.Modify();


        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::All,
                                '',
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    500,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              Time + 3600000,
                                              Time + 7200000,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);

        // [Given] POS Sale Line
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOS);

        //RefreshLine
        if SaleLinePOS.Get(SaleLinePOS.RecordId) then;

        // [THEN] Verify Discount 
        Assert.IsTrue(SaleLinePOS."Total Discount Code" = '', 'Total Discount was triggered incorrectly.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountInsideTimeInvervalTriggerOnTotalPressed()
    var
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        // [SCENARIO] Check if the total discount inside time interval is triggered

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);

        Item."Unit Price" := 1000;
        Item.Modify();


        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::All,
                                '',
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    500,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              Time - 3600000,
                                              Time + 7200000,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);

        // [Given] POS Sale Line
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOS);

        //RefreshLine
        if SaleLinePOS.Get(SaleLinePOS.RecordId) then;

        // [THEN] Verify Discount 
        Assert.IsTrue(SaleLinePOS."Total Discount Code" <> '', 'Total Discount was not triggered but it had to be triggered.');

    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountWithItemFilterWillNotTriggerOnTotalPressed()
    var
        FilterItem: Record Item;
        Item: Record Item;
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        // [SCENARIO] Check if the total discount with item filter is not triggered when total pressed

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);

        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Filter Item     
        CreateItem(FilterItem,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);

        FilterItem."Unit Price" := 1000;
        FilterItem.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::Item,
                                FilterItem."No.",
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    500,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] POS Sale Line with the item that is not part of the filter
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOS);

        //RefreshLine
        if SaleLinePOS.Get(SaleLinePOS.RecordId) then;

        // [THEN] The total discount must not be triggered 
        Assert.IsTrue(SaleLinePOS."Total Discount Code" = '', 'Total Discount was triggered incorrectly.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountWithItemCategoryFilterWillNotTriggerOnTotalPressed()
    var
        Item: Record Item;
        ItemCategory: Record "Item Category";
        SaleLinePOS: Record "NPR POS Sale Line";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        // [SCENARIO] Check if the total discount with Item Category filter is not triggered when total pressed

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);

        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Filter Item Category     
        LibraryInventory.CreateItemCategory(ItemCategory);

        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::"Item Category",
                                ItemCategory.Code,
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    500,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);

        // [Given] POS Sale Line with item that is not part of the filter item category
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOS);

        //RefreshLine
        if SaleLinePOS.Get(SaleLinePOS.RecordId) then;

        // [THEN] The total discount must not be triggered 
        Assert.IsTrue(SaleLinePOS."Total Discount Code" = '', 'Total Discount was triggered incorrectly.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountWithVendorFilterWillNotTriggerOnTotalPressed()
    var
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Vendor: Record Vendor;
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        // [SCENARIO] Check if the total discount with Vendor filter is not triggered when total pressed

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);

        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Filter Vendor 
        LibraryPurchase.CreateVendor(Vendor);

        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::Vendor,
                                Vendor."No.",
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    500,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);

        // [Given] POS Sale Line with the item which is not bought from the vendor filter
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOS);

        //RefreshLine
        if SaleLinePOS.Get(SaleLinePOS.RecordId) then;

        // [THEN] The total discount must not be triggered 
        Assert.IsTrue(SaleLinePOS."Total Discount Code" = '', 'Total Discount was triggered incorrectly.');

    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountWithItemFilterWillBeTriggeredOnTotalPressed()
    var
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        // [SCENARIO] Check if the total discount with item filter is triggered when total pressed

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);

        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::Item,
                                Item."No.",
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    500,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);

        // [Given] POS Sale Line with the item which is part of the filter
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOS);

        //RefreshLine
        if SaleLinePOS.Get(SaleLinePOS.RecordId) then;

        // [THEN] The total discount must be triggered 
        Assert.IsTrue(SaleLinePOS."Total Discount Code" <> '', 'Total Discount was not triggered but it should have been triggered.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountWithItemCategoryFilterWillBeTriggeredOnTotalPressed()
    var
        Item: Record Item;
        ItemCategory: Record "Item Category";
        SaleLinePOS: Record "NPR POS Sale Line";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        // [SCENARIO] Check if the total discount with Item Category filter is triggered when total pressed

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Filter Item Category     
        LibraryInventory.CreateItemCategory(ItemCategory);

        // [GIVEN] Item with unit price        
        CreateItem(Item,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);

        Item."Item Category Code" := ItemCategory.Code;
        Item."Unit Price" := 1000;
        Item.Modify();


        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::"Item Category",
                                ItemCategory.Code,
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    500,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);

        // [Given] POS Sale Line with the item which is part of the filter item category
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOS);

        //RefreshLine
        if SaleLinePOS.Get(SaleLinePOS.RecordId) then;

        // [THEN] The total discount must be triggered 
        Assert.IsTrue(SaleLinePOS."Total Discount Code" <> '', 'Total Discount was not triggered but it should have been triggered.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountWithVendorFilterWillBeTriggeredOnTotalPressed()
    var
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        Vendor: Record Vendor;
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        // [SCENARIO] Check if the total discount with Vendor filter is triggered when total pressed

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Filter Vendor     
        LibraryPurchase.CreateVendor(Vendor);

        // [GIVEN] Item with unit price        
        CreateItem(Item,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);

        Item.Validate("Vendor No.", Vendor."No.");
        Item."Unit Price" := 1000;
        Item.Modify();



        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::Vendor,
                                Vendor."No.",
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    500,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);

        // [Given] POS Sale Line with the item that is part of the vendor filter
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOS);

        //RefreshLine
        if SaleLinePOS.Get(SaleLinePOS.RecordId) then;

        // [THEN] The discount must be triggered 
        Assert.IsTrue(SaleLinePOS."Total Discount Code" <> '', 'Total Discount was not triggered but it should have been triggered.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountNotTriggeredWithoutStepCalculationFiltersOnTotalPressed()
    var
        FilterItem: Record Item;
        Item: Record Item;
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        // [SCENARIO] Check if total discount without step amount filter calculation is not triggered when total pressed

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Filter Item with unit price        
        CreateItem(FilterItem,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);
        FilterItem."Unit Price" := 0;
        FilterItem.Modify();


        // [GIVEN] Discount without step amount calculation filter
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"No Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::Item,
                                FilterItem."No.",
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Percent,
                                    25,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();


        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);

        // [GIVEN] Item with unit price        
        Clear(Item);
        CreateItem(Item,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   true);

        Item."Unit Price" := 2000;
        Item.Modify();

        // [Given] POS Sale Line
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item."No.",
                                      1);


        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOS);

        // [THEN] Total Discount should be applied to the transaction
        SaleLinePOS.Get(SaleLinePOS.RecordId);
        Assert.IsTrue(SaleLinePOS."Total Discount Code" = '', 'Total Discount was triggered but it shouldnt have been triggered.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountTriggeredWithoutStepCalculationFiltersOnTotalPressed()
    var
        FilterItem: Record Item;
        Item: Record Item;
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        // [SCENARIO] Check if total discount without step amount filter calculation is triggered when total pressed

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Filter Item with unit price        
        CreateItem(FilterItem,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);
        FilterItem."Unit Price" := 0;
        FilterItem.Modify();


        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"No Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::Item,
                                FilterItem."No.",
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Percent,
                                    25,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();


        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);

        // [GIVEN] Item with unit price        
        Clear(Item);
        CreateItem(Item,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   true);

        Item."Unit Price" := 2000;
        Item.Modify();

        // [Given] POS Sale Line with Item and Amount that has to trigger the total discountg
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item."No.",
                                      1);

        // [Given] POS Sale Line with the total discount filter item and Amount that shoulnd't trigger the total discount
        LibraryPOSMock.CreateItemLine(POSSession,
                                      FilterItem."No.",
                                      1);


        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOS);


        // [THEN] Total Discount should be applied to the transaction
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetFilter("Total Discount Code", '<>%1', '');
        Assert.IsTrue(not SaleLinePOS.IsEmpty, 'Total Discount was not triggered but it should have been triggered.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckTotalDiscountPercentApplicationWithoutDiscountApplicationFiltersAfterAllItemsHaveBeenAdded()
    var
        FilterItem: Record Item;
        Item: Record Item;
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        FilterItemSaleLinePOS: Record "NPR POS Sale Line";
        NoFilterItemPSaleLinePOS: Record "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        // [SCENARIO] Check if total discount percent benefit without discount application filter is applied to an item that is not part of the total discount filter

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Filter item      
        CreateItem(FilterItem,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);
        FilterItem."Unit Price" := 1000;
        FilterItem.Modify();


        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"No Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::Item,
                                FilterItem."No.",
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Percent,
                                    25,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();


        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);

        // [GIVEN] Item with unit price which is not part of the discount filter        
        Clear(Item);
        CreateItem(Item,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   true);

        Item."Unit Price" := 2000;
        Item.Modify();

        // [Given] POS Sale Line with the item that is not part of the discount filter but should get discounted
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(NoFilterItemPSaleLinePOS);

        // [Given] POS Sale Line with the discount filter item which is going to trigger the total discount
        LibraryPOSMock.CreateItemLine(POSSession,
                                      FilterItem."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(FilterItemSaleLinePOS);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(FilterItemSaleLinePOS);

        // [THEN] Total Discount should be applied to the item that is nor part of the trigger as well
        NoFilterItemPSaleLinePOS.Get(NoFilterItemPSaleLinePOS.RecordId);
        Assert.IsTrue(NoFilterItemPSaleLinePOS."Total Discount Code" = NPRTotalDiscountBenefit."Total Discount Code", 'Total Discount was not applied to the item but it should have been applied.');
        Assert.IsTrue(NoFilterItemPSaleLinePOS."Total Discount Step" = NPRTotalDiscountBenefit."Step Amount", 'The correct Total Discount Step was not applied to the item.');
        Assert.IsTrue(NoFilterItemPSaleLinePOS."Discount %" = NPRTotalDiscountBenefit.Value, 'The total discount benefit is incorrect.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckSubsequentTotalDiscountPercentApplicationWithoutDiscountApplicationFiltersAfterAllItemsHaveBeenAdded()
    var
        FilterItem: Record Item;
        Item: Record Item;
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        FilterItemSaleLinePOS: Record "NPR POS Sale Line";
        NoFilterItemPSaleLinePOS: Record "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        // [SCENARIO] Check if total discount percent benefit without discount application filter is applied to an item that is not part of the total discount filter after subsequent insertion

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Filter item      
        CreateItem(FilterItem,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);
        FilterItem."Unit Price" := 1000;
        FilterItem.Modify();


        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"No Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::Item,
                                FilterItem."No.",
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Percent,
                                    25,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();


        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);

        // [GIVEN] Item with unit price which is not part of the discount filter        
        Clear(Item);
        CreateItem(Item,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   true);

        Item."Unit Price" := 2000;
        Item.Modify();

        // [Given] POS Sale Line with the item that is not part of the discount filter but should get discounted
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(NoFilterItemPSaleLinePOS);
        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(FilterItemSaleLinePOS);

        // [THEN] Total Discount shouldn't be applied to the item that is not part of the trigger as well
        NoFilterItemPSaleLinePOS.Get(NoFilterItemPSaleLinePOS.RecordId);
        Assert.IsTrue(NoFilterItemPSaleLinePOS."Total Discount Code" = '', 'Total Discount was applied to the item but it shouldnt have been applied.');

        // [When] POS Sale Line with the discount filter item which is going to trigger the total discount added
        LibraryPOSMock.CreateItemLine(POSSession,
                                      FilterItem."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(FilterItemSaleLinePOS);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(FilterItemSaleLinePOS);
        // [THEN] Total Discount should be applied to the item that is part of the trigger as well
        FilterItemSaleLinePOS.Get(FilterItemSaleLinePOS.RecordId);
        Assert.IsTrue(FilterItemSaleLinePOS."Total Discount Code" = NPRTotalDiscountBenefit."Total Discount Code", 'Total Discount was not applied to the item but it should have been applied.');
        Assert.IsTrue(FilterItemSaleLinePOS."Total Discount Step" = NPRTotalDiscountBenefit."Step Amount", 'The incorrect total discount benefit was applied to the transaction.');
        Assert.IsTrue(FilterItemSaleLinePOS."Discount %" = NPRTotalDiscountBenefit.Value, 'The total discount benefit is incorrect.');

        // [THEN] Total Discount should be applied to the item that is not part of the trigger as well
        NoFilterItemPSaleLinePOS.Get(NoFilterItemPSaleLinePOS.RecordId);
        Assert.IsTrue(NoFilterItemPSaleLinePOS."Total Discount Code" = NPRTotalDiscountBenefit."Total Discount Code", 'Total Discount was not applied to the item but it should have been applied.');
        Assert.IsTrue(NoFilterItemPSaleLinePOS."Total Discount Step" = NPRTotalDiscountBenefit."Step Amount", 'The incorrect total discount benefit was applied to the transaction.');
        Assert.IsTrue(NoFilterItemPSaleLinePOS."Discount %" = NPRTotalDiscountBenefit.Value, 'The total discount benefit is incorrect.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckTotalDiscountAmountApplicationWithoutDiscountApplicationFiltersAfterAllItemsHaveBeenAdded()
    var
        FilterItem: Record Item;
        Item: Record Item;
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        FilterItemSaleLinePOS: Record "NPR POS Sale Line";
        NoFilterItemPSaleLinePOS: Record "NPR POS Sale Line";
        TotalSaleLinePOS: Record "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        // [SCENARIO] Check if total discount percent benefit without discount application filter is applied to an item that is not part of the total discount filter

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Filter item      
        CreateItem(FilterItem,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);
        FilterItem."Unit Price" := 1000;
        FilterItem.Modify();


        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"No Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::Item,
                                FilterItem."No.",
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    500,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();


        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);

        // [GIVEN] Item with unit price which is not part of the discount filter        
        Clear(Item);
        CreateItem(Item,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   true);

        Item."Unit Price" := 2000;
        Item.Modify();

        // [Given] POS Sale Line with the item that is not part of the discount filter but should get discounted
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(NoFilterItemPSaleLinePOS);

        // [Given] POS Sale Line with the discount filter item which is going to trigger the total discount
        LibraryPOSMock.CreateItemLine(POSSession,
                                      FilterItem."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(FilterItemSaleLinePOS);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(FilterItemSaleLinePOS);

        // [THEN] Total Discount should be applied to the item that is not part of the trigger as well
        NoFilterItemPSaleLinePOS.Get(NoFilterItemPSaleLinePOS.RecordId);
        Assert.IsTrue(NoFilterItemPSaleLinePOS."Total Discount Code" = NPRTotalDiscountBenefit."Total Discount Code", 'Total Discount was not applied to the item but it should have been applied.');
        Assert.IsTrue(NoFilterItemPSaleLinePOS."Total Discount Step" = NPRTotalDiscountBenefit."Step Amount", 'Total Discount was not applied to the item but it should have been applied.');

        // [THEN] Total Discount should be applied to the item that is part of the trigger as well
        FilterItemSaleLinePOS.Get(FilterItemSaleLinePOS.RecordId);
        Assert.IsTrue(FilterItemSaleLinePOS."Total Discount Code" = NPRTotalDiscountBenefit."Total Discount Code", 'Total Discount was not applied to the item but it should have been applied.');
        Assert.IsTrue(FilterItemSaleLinePOS."Total Discount Step" = NPRTotalDiscountBenefit."Step Amount", 'Total Discount was not applied to the item but it should have been applied.');


        TotalSaleLinePOS.Reset();
        TotalSaleLinePOS.SetCurrentKey("Register No.",
                                  "Sales Ticket No.",
                                  "Line Type",
                                  "Total Discount Code",
                                  "Benefit Item");
        TotalSaleLinePOS.SetRange("Register No.", NoFilterItemPSaleLinePOS."Register No.");
        TotalSaleLinePOS.SetRange("Sales Ticket No.", NoFilterItemPSaleLinePOS."Sales Ticket No.");
        TotalSaleLinePOS.SetRange("Line Type", TotalSaleLinePOS."Line Type"::Item);
        TotalSaleLinePOS.SetRange("Benefit Item", false);
        TotalSaleLinePOS.CalcSums("Total Discount Amount");

        // [THEN] The total discount amount should match the total disocount benefit amount
        Assert.IsTrue(TotalSaleLinePOS."Total Discount Amount" = NPRTotalDiscountBenefit.Value, 'Total Discount was not correctly applied to the item.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckSubsequentTotalDiscountAmountApplicationWithoutDiscountApplicationFiltersAfterAllItemsHaveBeenAdded()
    var
        FilterItem: Record Item;
        Item: Record Item;
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        FilterItemSaleLinePOS: Record "NPR POS Sale Line";
        NoFilterItemPSaleLinePOS: Record "NPR POS Sale Line";
        TotalSaleLinePOS: Record "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        // [SCENARIO] Check if total discount percent benefit without discount application filter is applied to an item that is not part of the total discount filter after subsequent insertion

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Filter item      
        CreateItem(FilterItem,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);
        FilterItem."Unit Price" := 1000;
        FilterItem.Modify();


        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"No Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::Item,
                                FilterItem."No.",
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    500,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();


        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);

        // [GIVEN] Item with unit price which is not part of the discount filter        
        Clear(Item);
        CreateItem(Item,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   true);

        Item."Unit Price" := 2000;
        Item.Modify();

        // [Given] POS Sale Line with the item that is not part of the discount filter but should get discounted
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(NoFilterItemPSaleLinePOS);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(FilterItemSaleLinePOS);

        // [THEN] Total Discount shouldn't be applied to the item that is not part of the trigger
        NoFilterItemPSaleLinePOS.Get(NoFilterItemPSaleLinePOS.RecordId);
        Assert.IsTrue(NoFilterItemPSaleLinePOS."Total Discount Code" = '', 'Total Discount was applied to the item but it shouldnt have been applied.');

        // [When] POS Sale Line with the discount filter item which is going to trigger the total discount added
        LibraryPOSMock.CreateItemLine(POSSession,
                                      FilterItem."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(FilterItemSaleLinePOS);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(FilterItemSaleLinePOS);

        // [THEN] Total Discount should be applied to the item that is not part of the trigger as well
        NoFilterItemPSaleLinePOS.Get(NoFilterItemPSaleLinePOS.RecordId);
        Assert.IsTrue(NoFilterItemPSaleLinePOS."Total Discount Code" = NPRTotalDiscountBenefit."Total Discount Code", 'Total Discount was not applied to the item but it should have been applied.');
        Assert.IsTrue(NoFilterItemPSaleLinePOS."Total Discount Step" = NPRTotalDiscountBenefit."Step Amount", 'Total Discount was not correctlt applied to the item.');

        // [THEN] Total Discount should be applied to the item that is part of the trigger as well
        FilterItemSaleLinePOS.Get(FilterItemSaleLinePOS.RecordId);
        Assert.IsTrue(FilterItemSaleLinePOS."Total Discount Code" = NPRTotalDiscountBenefit."Total Discount Code", 'Total Discount was not applied to the item but it should have been applied.');
        Assert.IsTrue(FilterItemSaleLinePOS."Total Discount Step" = NPRTotalDiscountBenefit."Step Amount", 'Total Discount was not correctlt applied to the item.');


        TotalSaleLinePOS.Reset();
        TotalSaleLinePOS.SetCurrentKey("Register No.",
                                  "Sales Ticket No.",
                                  "Line Type",
                                  "Total Discount Code",
                                  "Benefit Item");
        TotalSaleLinePOS.SetRange("Register No.", NoFilterItemPSaleLinePOS."Register No.");
        TotalSaleLinePOS.SetRange("Sales Ticket No.", NoFilterItemPSaleLinePOS."Sales Ticket No.");
        TotalSaleLinePOS.SetRange("Line Type", TotalSaleLinePOS."Line Type"::Item);
        TotalSaleLinePOS.SetRange("Benefit Item", false);
        TotalSaleLinePOS.CalcSums("Total Discount Amount");

        // [THEN] The total discount amount should match the total disocount benefit amount
        Assert.IsTrue(TotalSaleLinePOS."Total Discount Amount" = NPRTotalDiscountBenefit.Value, 'Total Discount was not correctly to the pos sale');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckTotalDiscountPercentApplicationWithDiscountApplicationFiltersAfterAllItemsHaveBeenAdded()
    var
        FilterItem: Record Item;
        Item: Record Item;
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        FilterItemSaleLinePOS: Record "NPR POS Sale Line";
        NoFilterItemPSaleLinePOS: Record "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        // [SCENARIO] Check if total discount percent benefit with discount application filter is applied to an item that is not part of the total discount filter

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Filter item      
        CreateItem(FilterItem,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);
        FilterItem."Unit Price" := 1000;
        FilterItem.Modify();


        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::Item,
                                FilterItem."No.",
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Percent,
                                    25,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();


        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);

        // [GIVEN] Item with unit price which is not part of the discount filter        
        Clear(Item);
        CreateItem(Item,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   true);

        Item."Unit Price" := 2000;
        Item.Modify();

        // [Given] POS Sale Line with the item that is not part of the discount filter and shouldn't get discounted
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(NoFilterItemPSaleLinePOS);

        // [Given] POS Sale Line with the discount filter item which is going to trigger the total discount
        LibraryPOSMock.CreateItemLine(POSSession,
                                      FilterItem."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(FilterItemSaleLinePOS);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(FilterItemSaleLinePOS);

        // [THEN] Total Discount shouldnt be applied to the item that is not part of the fiter
        NoFilterItemPSaleLinePOS.Get(NoFilterItemPSaleLinePOS.RecordId);
        Assert.IsTrue(NoFilterItemPSaleLinePOS."Total Discount Code" = '', 'Total Discount is applied to the item but it shouldnt have been applied.');

        // [THEN] Total Discount should be applied to the item that is part of the fiter
        FilterItemSaleLinePOS.Get(FilterItemSaleLinePOS.RecordId);
        Assert.IsTrue(FilterItemSaleLinePOS."Total Discount Code" = NPRTotalDiscountBenefit."Total Discount Code", 'Total Discount was not applied to the item but it shouldn have been applied.');
        Assert.IsTrue(FilterItemSaleLinePOS."Total Discount Step" = NPRTotalDiscountBenefit."Step Amount", 'Total Discount was not applied correctly to the sale line.');
        Assert.IsTrue(FilterItemSaleLinePOS."Discount %" = NPRTotalDiscountBenefit.Value, 'Total Discount was not applied correctly to the sale line.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckSubsequentTotalDiscountPercentApplicationWithDiscountApplicationFiltersAfterAllItemsHaveBeenAdded()
    var
        FilterItem: Record Item;
        Item: Record Item;
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        FilterItemSaleLinePOS: Record "NPR POS Sale Line";
        NoFilterItemPSaleLinePOS: Record "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        // [SCENARIO] Check if total discount percent benefit with discount application filter is applied to an item that is not part of the total discount filter after subsequent insertion

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Filter item      
        CreateItem(FilterItem,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);
        FilterItem."Unit Price" := 1000;
        FilterItem.Modify();


        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::Item,
                                FilterItem."No.",
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Percent,
                                    25,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();


        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);

        // [GIVEN] Item with unit price which is not part of the discount filter        
        Clear(Item);
        CreateItem(Item,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   true);

        Item."Unit Price" := 2000;
        Item.Modify();

        // [Given] POS Sale Line with the item that is not part of the discount filter and shouldn't get discounted
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(NoFilterItemPSaleLinePOS);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(NoFilterItemPSaleLinePOS);

        // [THEN] Total Discount shouldn't be applied to the item that is not part of the filter
        NoFilterItemPSaleLinePOS.Get(NoFilterItemPSaleLinePOS.RecordId);
        Assert.IsTrue(NoFilterItemPSaleLinePOS."Total Discount Code" = '', 'Total Discount applied to the item but it should have been applied.');


        // [When] POS Sale Line with the discount filter item which is going to trigger the total discount added
        LibraryPOSMock.CreateItemLine(POSSession,
                                      FilterItem."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(FilterItemSaleLinePOS);


        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(FilterItemSaleLinePOS);

        // [THEN] Total Discount should be applied to the item that is part of the filter
        FilterItemSaleLinePOS.Get(FilterItemSaleLinePOS.RecordId);
        Assert.IsTrue(FilterItemSaleLinePOS."Total Discount Code" = NPRTotalDiscountBenefit."Total Discount Code", 'Total Discount was not applied to the item but it shouldn have been applied.');
        Assert.IsTrue(FilterItemSaleLinePOS."Total Discount Step" = NPRTotalDiscountBenefit."Step Amount", 'Total Discount was not applied correctly to the sale line.');
        Assert.IsTrue(FilterItemSaleLinePOS."Discount %" = NPRTotalDiscountBenefit.Value, 'Total Discount was not applied correctly to the sale line.');

        // [THEN] Total Discount shouldn't be applied to the item that is not part of the filter
        NoFilterItemPSaleLinePOS.Get(NoFilterItemPSaleLinePOS.RecordId);
        Assert.IsTrue(NoFilterItemPSaleLinePOS."Total Discount Code" = '', 'Total Discount was applied to the item but it shouldnt have been applied.');


    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckTotalDiscountAmountApplicationWithDiscountApplicationFiltersAfterAllItemsHaveBeenAdded()
    var
        FilterItem: Record Item;
        Item: Record Item;
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        FilterItemSaleLinePOS: Record "NPR POS Sale Line";
        NoFilterItemPSaleLinePOS: Record "NPR POS Sale Line";
        TotalSaleLinePOS: Record "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        // [SCENARIO] Check if total discount amount benefit with discount application filter is not applied to an item that is not part of the total discount filter

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Filter item      
        CreateItem(FilterItem,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);
        FilterItem."Unit Price" := 1000;
        FilterItem.Modify();


        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::Item,
                                FilterItem."No.",
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    500,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();


        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);

        // [GIVEN] Item with unit price which is not part of the discount filter        
        Clear(Item);
        CreateItem(Item,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   true);

        Item."Unit Price" := 2000;
        Item.Modify();

        // [Given] POS Sale Line with the item that is not part of the discount filter and shound't get discounted
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(NoFilterItemPSaleLinePOS);

        // [Given] POS Sale Line with the discount filter item which is going to trigger the total discount
        LibraryPOSMock.CreateItemLine(POSSession,
                                      FilterItem."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(FilterItemSaleLinePOS);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(FilterItemSaleLinePOS);

        // [THEN] Total Discount shouldn't be applied to the item that is not part of the trigger
        NoFilterItemPSaleLinePOS.Get(NoFilterItemPSaleLinePOS.RecordId);
        Assert.IsTrue(NoFilterItemPSaleLinePOS."Total Discount Code" = '', 'Total Discount was applied to the item but it shouldnt have been applied.');

        // [THEN] Total Discount should be applied to the filter item
        FilterItemSaleLinePOS.Get(FilterItemSaleLinePOS.RecordId);
        Assert.IsTrue(FilterItemSaleLinePOS."Total Discount Code" = NPRTotalDiscountBenefit."Total Discount Code", 'Total Discount was not applied to the item but it should have been applied.');
        Assert.IsTrue(FilterItemSaleLinePOS."Total Discount Step" = NPRTotalDiscountBenefit."Step Amount", 'Total Discount was not applied to the item but it should have been applied.');
        Assert.IsTrue(FilterItemSaleLinePOS."Total Discount Amount" = NPRTotalDiscountBenefit.Value, 'Total Discount was not applied to the item but it should have been applied.');
        Assert.IsTrue(FilterItemSaleLinePOS."Discount Amount" = NPRTotalDiscountBenefit.Value, 'Total Discount was not applied to the item but it should have been applied.');

        TotalSaleLinePOS.Reset();
        TotalSaleLinePOS.SetCurrentKey("Register No.",
                                  "Sales Ticket No.",
                                  "Line Type",
                                  "Total Discount Code",
                                  "Benefit Item");
        TotalSaleLinePOS.SetRange("Register No.", NoFilterItemPSaleLinePOS."Register No.");
        TotalSaleLinePOS.SetRange("Sales Ticket No.", NoFilterItemPSaleLinePOS."Sales Ticket No.");
        TotalSaleLinePOS.SetRange("Line Type", TotalSaleLinePOS."Line Type"::Item);
        TotalSaleLinePOS.SetRange("Benefit Item", false);
        TotalSaleLinePOS.CalcSums("Total Discount Amount");

        // [THEN] The total discount value should be the same as the total discount in the POS Sale
        Assert.IsTrue(TotalSaleLinePOS."Total Discount Amount" = NPRTotalDiscountBenefit.Value, 'Total Discount was not correctly applied to the pos sale.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckSubsequentTotalDiscountAmountApplicationWithDiscountApplicationFiltersAfterAllItemsHaveBeenAdded()
    var
        FilterItem: Record Item;
        Item: Record Item;
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        FilterItemSaleLinePOS: Record "NPR POS Sale Line";
        NoFilterItemPSaleLinePOS: Record "NPR POS Sale Line";
        TotalSaleLinePOS: Record "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        // [SCENARIO] Check if total discount amount benefit with discount application filter is not applied to an item that is not part of the total discount filter after subsequent insertion

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Filter item      
        CreateItem(FilterItem,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);
        FilterItem."Unit Price" := 1000;
        FilterItem.Modify();


        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::Item,
                                FilterItem."No.",
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    500,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();


        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);

        // [GIVEN] Item with unit price which is not part of the discount filter        
        Clear(Item);
        CreateItem(Item,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   true);

        Item."Unit Price" := 2000;
        Item.Modify();

        // [Given] POS Sale Line with the item that is not part of the discount filter and shouldn't get discounted
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(NoFilterItemPSaleLinePOS);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(FilterItemSaleLinePOS);

        // [THEN] Total Discount shouldn;t be applied to the item that is not part of the filter
        NoFilterItemPSaleLinePOS.Get(NoFilterItemPSaleLinePOS.RecordId);
        Assert.IsTrue(NoFilterItemPSaleLinePOS."Total Discount Code" = '', 'Total Discount was applied to the item but it shouldnt have been applied.');

        // [When] POS Sale Line with the discount filter item which is going to trigger the total discount added
        LibraryPOSMock.CreateItemLine(POSSession,
                                      FilterItem."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(FilterItemSaleLinePOS);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(FilterItemSaleLinePOS);

        // [THEN] Total Discount shouldn't be applied to the item that is not part of the filter
        NoFilterItemPSaleLinePOS.Get(NoFilterItemPSaleLinePOS.RecordId);
        Assert.IsTrue(NoFilterItemPSaleLinePOS."Total Discount Code" = '', 'Total Discount was applied to the item but it shouldnt have been applied.');

        // [THEN] Total Discount should be applied to the filter item
        FilterItemSaleLinePOS.Get(FilterItemSaleLinePOS.RecordId);
        Assert.IsTrue(FilterItemSaleLinePOS."Total Discount Code" = NPRTotalDiscountBenefit."Total Discount Code", 'Total Discount was not applied to the item but it should have been applied.');
        Assert.IsTrue(FilterItemSaleLinePOS."Total Discount Step" = NPRTotalDiscountBenefit."Step Amount", 'Total Discount was not applied to the item but it should have been applied.');
        Assert.IsTrue(FilterItemSaleLinePOS."Total Discount Amount" = NPRTotalDiscountBenefit.Value, 'Total Discount was not applied to the item but it should have been applied.');
        Assert.IsTrue(FilterItemSaleLinePOS."Discount Amount" = NPRTotalDiscountBenefit.Value, 'Total Discount was not applied to the item but it should have been applied.');

        TotalSaleLinePOS.Reset();
        TotalSaleLinePOS.SetCurrentKey("Register No.",
                                  "Sales Ticket No.",
                                  "Line Type",
                                  "Total Discount Code",
                                  "Benefit Item");
        TotalSaleLinePOS.SetRange("Register No.", FilterItemSaleLinePOS."Register No.");
        TotalSaleLinePOS.SetRange("Sales Ticket No.", FilterItemSaleLinePOS."Sales Ticket No.");
        TotalSaleLinePOS.SetRange("Line Type", TotalSaleLinePOS."Line Type"::Item);
        TotalSaleLinePOS.SetRange("Benefit Item", false);
        TotalSaleLinePOS.CalcSums("Total Discount Amount");

        // [THEN] The total discount value should be the same as the total discount in the POS Sale
        Assert.IsTrue(TotalSaleLinePOS."Total Discount Amount" = NPRTotalDiscountBenefit.Value, 'Total Discount was not correctly applied to the pos sale.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfSingleLevelTotalDiscountPercentTriggeredOnTotalPressed()
    var
        SalePOS: Record "NPR POS Sale";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        // [SCENARIO] Check if single level total discount percent is triggered on total pressed

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::All,
                                '',
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Percent,
                                    25,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();


        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [THEN] Check Total Discount Applied
        CheckTotalDiscountBenefits(SalePOS,
                                   NPRTotalDiscountHeader,
                                   VATPostingSetup);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTwoLevelTotalDiscountPercentTriggeredOnTotalPressed()
    var
        SalePOS: Record "NPR POS Sale";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        // [SCENARIO] Check if two level total discount percent is triggered when total presssed

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::All,
                                '',
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Percent,
                                    25,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    3000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Percent,
                                    50,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();


        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [THEN] Check Total Discount Applied
        CheckTotalDiscountBenefits(SalePOS,
                                   NPRTotalDiscountHeader,
                                   VATPostingSetup);

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfThreeLevelTotalDiscountPercentTriggeredOnTotalPressed()
    var
        SalePOS: Record "NPR POS Sale";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        // [SCENARIO] Check if three level total discount percent is triggered when total pressed

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::All,
                                '',
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Percent,
                                    25,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    3000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Percent,
                                    50,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    5000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Percent,
                                    75,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();


        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [THEN] Check Total Discount Applied
        CheckTotalDiscountBenefits(SalePOS,
                                   NPRTotalDiscountHeader,
                                   VATPostingSetup);

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfSingleLevelTotalDiscountAmountTriggeredOnTotalPressed()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
        ExpectedTotalAmountIncludingVAT: Decimal;
        ExpectedTotalDiscountAmount: Decimal;
    begin
        // [SCENARIO] Check if single level total discount amount is triggered when total pressed

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);

        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::All,
                                '',
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    500,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);
        // [Given] POS Sale Line
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOS);

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);

        //RefreshLine
        if SaleLinePOS.Get(SaleLinePOS.RecordId) then;

        ExpectedTotalAmountIncludingVAT := SaleLinePOS."Unit Price" * SaleLinePOS.Quantity - NPRTotalDiscountBenefit.Value;
        ExpectedTotalAmountIncludingVAT := Round(ExpectedTotalAmountIncludingVAT, GeneralLedgerSetup."Amount Rounding Precision");

        ExpectedTotalDiscountAmount := NPRTotalDiscountBenefit.Value;
        ExpectedTotalDiscountAmount := Round(ExpectedTotalDiscountAmount, GeneralLedgerSetup."Amount Rounding Precision");


        // [THEN] Verify Discount 
        Assert.IsTrue(SaleLinePOS."Total Discount Code" = NPRTotalDiscountHeader.Code, 'Total Discount was not triggered but it should have been triggered.');
        Assert.IsTrue(SaleLinePOS."Amount Including VAT" = ExpectedTotalAmountIncludingVAT, 'Amount Including VAT is not correct after total discount application');
        Assert.IsTrue(SaleLinePOS."Discount Amount" = ExpectedTotalDiscountAmount, 'Discount Amount is not correct after total discount application');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTwoLevelTotalDiscountAmountTriggeredOnTotalPressed()
    var
        SalePOS: Record "NPR POS Sale";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        // [SCENARIO] Check if two level total discount amount is triggered when total pressed

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::All,
                                '',
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    500,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    3000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    1000,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();


        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [THEN] Check Total Discount Applied
        CheckTotalDiscountBenefits(SalePOS,
                                   NPRTotalDiscountHeader,
                                   VATPostingSetup);

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfThreeLevelTotalDiscountAmountTriggeredOnTotalPressed()
    var
        SalePOS: Record "NPR POS Sale";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        // [SCENARIO] Check if three level total discount amount is triggered when total pressed

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::All,
                                '',
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    500,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    3000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    1000,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    5000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    1500,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();


        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [THEN] Check Total Discount Applied
        CheckTotalDiscountBenefits(SalePOS,
                                   NPRTotalDiscountHeader,
                                   VATPostingSetup);

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfThreeLevelTotalDiscountAmountWithMixedDiscountTriggeredOnTotalPressed()
    var
        ItemCategory: Record "Item Category";
        NPRMixedDiscount: Record "NPR Mixed Discount";
        NPRMixedDiscountLine: Record "NPR Mixed Discount Line";
        SalePOS: Record "NPR POS Sale";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRMixedDiscountManagement: Codeunit "NPR Mixed Discount Management";
        POSSale: Codeunit "NPR POS Sale";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
        DisountFitlerLbl: Label '%1|%2', Locked = true, Comment = '%1 - discount code, %2 - discount code';
        DiscountFilter: Text;
    begin
        // [SCENARIO] Check if three level mixed total discount is triggered when total pressed

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        DiscountFilter := StrSubstNo(DisountFitlerLbl,
                                     NPRTotalDiscountManagement.DiscSourceTableId(),
                                     NPRMixedDiscountManagement.DiscSourceTableId());

        // [GIVEN] Enable discount
        EnableDiscount(DiscountFilter);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::All,
                                '',
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    500,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    3000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    1000,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    5000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    1500,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [GIVEN] Filter Item Category     
        LibraryInventory.CreateItemCategory(ItemCategory);


        // [GIVEN] Mixed discount
        CreateMixedDiscount(NPRMixedDiscount,
                            NPRMixedDiscountLine,
                            ItemCategory,
                            50);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [THEN] Check Total Discount Applied
        CheckTotalDiscountBenefitsWithMixedDiscount(SalePOS,
                                                    NPRTotalDiscountHeader,
                                                    NPRMixedDiscount,
                                                    VATPostingSetup);

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfThreeLevelTotalDiscountBenefitItemsTriggeredOnTotalPressed()
    var
        Item: Record Item;
        SalePOS: Record "NPR POS Sale";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        // [SCENARIO] Check if three level total discount amount is triggered when total pressed

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::All,
                                '',
                                '',
                                NPRTotalDiscountLine);

        // [GIVEN] Benefit item      
        Clear(Item);
        CreateItem(Item,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                    false);

        // [GIVEN] Benefit Item Line
        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Item,
                                    Item."No.",
                                    '',
                                    1,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    0,
                                    false,
                                    NPRTotalDiscountBenefit);

        // [GIVEN] Benefit item      
        Clear(Item);
        CreateItem(Item,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                    false);

        // [GIVEN] Benefit Item Line
        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    3000,
                                    Enum::"NPR Total Disc. Benefit Type"::Item,
                                    Item."No.",
                                    '',
                                    1,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    0,
                                    false,
                                    NPRTotalDiscountBenefit);

        // [GIVEN] Benefit item      
        Clear(Item);
        CreateItem(Item,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                    false);

        // [GIVEN] Benefit Item Line
        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    5000,
                                    Enum::"NPR Total Disc. Benefit Type"::Item,
                                    Item."No.",
                                    '',
                                    1,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    0,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();


        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [THEN] Check Total Discount Benefit Items Applied
        CheckTotalDiscountBenefits(SalePOS,
                                   NPRTotalDiscountHeader,
                                   VATPostingSetup);

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfThreeLevelTotalDiscountBenefitItemListsTriggeredOnTotalPressed()
    var
        NoSeries: Record "No. Series";
        NPRItemBenefitListHeader: Record "NPR Item Benefit List Header";
        SalePOS: Record "NPR POS Sale";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        // [SCENARIO] Check if three level total discount amount is triggered when total pressed

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        //[GIVEN] No Item Benefit Lits
        DeleteBenefitItemLists();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::All,
                                '',
                                '',
                                NPRTotalDiscountLine);

        // [GIVEN] Benefit List No Series    
        Clear(NoSeries);
        CreateNumberSeries(NoSeries);

        // [GIVEN] Benefit List    
        Clear(NPRItemBenefitListHeader);
        CreateBenefitItemList(NoSeries,
                              VATPostingSetup,
                              NPRItemBenefitListHeader);

        // [GIVEN] Benefit Item Line
        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::"Item List",
                                    NPRItemBenefitListHeader.Code,
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    0,
                                    false,
                                    NPRTotalDiscountBenefit);

        // [GIVEN] Benefit List      
        Clear(NPRItemBenefitListHeader);
        CreateBenefitItemList(NoSeries,
                              VATPostingSetup,
                              NPRItemBenefitListHeader);

        // [GIVEN] Benefit Item Line
        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    3000,
                                    Enum::"NPR Total Disc. Benefit Type"::"Item List",
                                    NPRItemBenefitListHeader.Code,
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    0,
                                    false,
                                    NPRTotalDiscountBenefit);

        // [GIVEN] Benefit List      
        Clear(NPRItemBenefitListHeader);
        CreateBenefitItemList(NoSeries,
                              VATPostingSetup,
                              NPRItemBenefitListHeader);

        // [GIVEN] Benefit Item Line
        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    5000,
                                    Enum::"NPR Total Disc. Benefit Type"::"Item List",
                                    NPRItemBenefitListHeader."Code",
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    0,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();


        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [THEN] Check Total Discount Applied
        CheckTotalDiscountBenefits(SalePOS,
                                   NPRTotalDiscountHeader,
                                   VATPostingSetup);

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckTotalDiscountResetOnTransactionChange()
    var
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        // [SCENARIO] Check if the total discount is removed from the POS Sale when the transaction is updated

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::All,
                                '',
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    500,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();


        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);

        // [GIVEN] Item with unit price        
        Clear(Item);
        CreateItem(Item,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);


        Item."Unit Price" := 1000;
        Item.Modify();


        // [Given] POS Sale Line
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item."No.",
                                      1);


        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [GIVEN] Total Discount Activated
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOS);

        // [WHEN] Add Sale Line after total discount calcualted
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item."No.",
                                      1);

        // [THEN] Total discount removed
        Assert.IsTrue(SaleLinePOS."Total Discount Code" = '', 'Total Discount was not cleared after total pressed.');
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfSingleLevelTotalDiscountPercentPostedCorrect()
    var
        GLEntry: Record "G/L Entry";
        GeneralPostingSetup: Record "General Posting Setup";
        Item: Record Item;
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
        SaleEnded: Boolean;
        AmountToPay: Decimal;
    begin
        // [SCENARIO] Check if single level total discount is posted correctly

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   true);

        Item."Unit Price" := 1000;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::All,
                                '',
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Percent,
                                    25,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();


        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] Total Disocunt Applied Correctly to POS Sale
        CheckTotalDiscountBenefits(SalePOS,
                                   NPRTotalDiscountHeader,
                                   VATPostingSetup);

        // Get Amount to Pay
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        AmountToPay := GetAmountToPay(SaleLinePOS);
        AmountToPay := Round(AmountToPay, 1, '>');

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify Discount applied
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();

        POSEntrySalesLine."POS Entry No." := POSEntry."Entry No.";
        POSEntrySalesLine."Line No." := SaleLinePOS."Line No.";

        //Verify POS Entry Sales Line
        Assert.IsTrue(POSEntrySalesLine.FindFirst(), 'Sale Line not created');
        Assert.AreEqual(SaleLinePOS."Discount %", POSEntrySalesLine."Line Discount %", 'POSSaleLine."Discount %" <>POSEntrySalesLine."Line Discount %"');
        Assert.AreEqual(SaleLinePOS."Discount Amount", POSEntrySalesLine."Line Discount Amount Incl. VAT", 'POSSaleLine."Discount Amount" <> POSEntrySalesLine."Line Discount Amount Incl. VAT"');
        Assert.AreEqual(SaleLinePOS.Amount, POSEntrySalesLine."Amount Excl. VAT", 'POSSaleLine.Amount <> POSEntrySalesLine."Amount Excl. VAT"');
        Assert.AreEqual(SaleLinePOS."Amount Including VAT", POSEntrySalesLine."Amount Incl. VAT", 'POSSaleLine."Amount Including VAT" <> POSEntrySalesLine."Amount Incl. VAT"');
        Assert.IsTrue(GeneralPostingSetup.Get(SaleLinePOS."Gen. Bus. Posting Group", SaleLinePOS."Gen. Prod. Posting Group"), 'General Posting Setup not found');

        //Verify G/L Entry
        GLEntry.SetRange("Document No.", POSEntry."Document No.");
        GLEntry.SetRange("Posting Date", POSEntry."Posting Date");
        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Account');
        Assert.AreEqual(SaleLinePOS."Amount Including VAT" + SaleLinePOS."Discount Amount", -(GLEntry.Amount + GLEntry."VAT Amount"), '(Item."Unit Price" * 1) <> (GLEntry.Amount + GLEntry."VAT Amount")');

        GLEntry.SetRange("G/L Account No.", GeneralPostingSetup."Sales Line Disc. Account");
        Assert.IsTrue(GLEntry.FindFirst(), 'G/L Entry not created for Sales Line Disc. Account');
        Assert.AreEqual(SaleLinePOS."Discount Amount", GLEntry.Amount + GLEntry."VAT Amount", '(Item."Unit Price" * LineDiscPct / 100 / (1 + VATPostingSetup."VAT %" / 100)) <> GLEntry.Amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountWithMultipleItemFiltersWillBeTriggeredOnTotalPressed()
    var
        FilterItem1: Record Item;
        FilterItem2: Record Item;
        SaleLinePOSFilterItem1: Record "NPR POS Sale Line";
        SaleLinePOSFilterItem2: Record "NPR POS Sale Line";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        // [SCENARIO] Check if the total discount with multiple item filters is triggered when total pressed

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Filter Item 1        
        CreateItem(FilterItem1,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);

        FilterItem1."Unit Price" := 500;
        FilterItem1."Price Includes VAT" := true;
        FilterItem1.Modify();


        // [GIVEN] Filter Item 2        
        CreateItem(FilterItem2,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);

        FilterItem2."Unit Price" := 500;
        FilterItem2."Price Includes VAT" := true;
        FilterItem2.Modify();


        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::Item,
                                FilterItem1."No.",
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::Item,
                                FilterItem2."No.",
                                '',
                                NPRTotalDiscountLine);


        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    500,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);

        // [Given] POS Sale Line with the Filter item 1 which is part of the filter
        LibraryPOSMock.CreateItemLine(POSSession,
                                      FilterItem1."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSFilterItem1);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOSFilterItem1);

        //RefreshLine
        if SaleLinePOSFilterItem1.Get(SaleLinePOSFilterItem1.RecordId) then;

        // [THEN] The total discount must not be triggered because the amount is not enought
        Assert.IsTrue(SaleLinePOSFilterItem1."Total Discount Code" = '', 'Total Discount was triggered but it shouldnt have been triggered.');

        // [When] POS Sale Line with Filter Item 2 is added
        LibraryPOSMock.CreateItemLine(POSSession,
                                      FilterItem2."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSFilterItem2);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOSFilterItem2);

        //RefreshLine
        if SaleLinePOSFilterItem1.Get(SaleLinePOSFilterItem1.RecordId) then;
        if SaleLinePOSFilterItem2.Get(SaleLinePOSFilterItem2.RecordId) then;

        // [THEN] The total discount must be triggered 
        Assert.IsTrue(SaleLinePOSFilterItem1."Total Discount Code" <> '', 'Total Discount was not applied correctly.');
        Assert.IsTrue(SaleLinePOSFilterItem2."Total Discount Code" <> '', 'Total Discount was not applied correctly.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountWithMultipleItemCategoryFiltersWillBeTriggeredOnTotalPressed()
    var
        Item1: Record Item;
        Item2: Record Item;
        FilterItemCategory1: Record "Item Category";
        FilterItemCategory2: Record "Item Category";
        SaleLinePOSFilterItem1: Record "NPR POS Sale Line";
        SaleLinePOSFilterItem2: Record "NPR POS Sale Line";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
        LibraryInventory: Codeunit "Library - Inventory";
    begin
        // [SCENARIO] Check if the total discount with multiple item category filters is triggered when total pressed

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Filter Item Category1     
        LibraryInventory.CreateItemCategory(FilterItemCategory1);

        // [GIVEN] Filter Item Category2     
        LibraryInventory.CreateItemCategory(FilterItemCategory1);

        // [GIVEN] Item 1 with Filter Item Category1        
        CreateItem(Item1,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);

        Item1."Item Category Code" := FilterItemCategory1.Code;
        Item1."Unit Price" := 500;
        Item1."Price Includes VAT" := true;
        Item1.Modify();


        // [GIVEN] Filter Item 2 with Filter Item Category2             
        CreateItem(Item2,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);

        Item2."Item Category Code" := FilterItemCategory2.Code;
        Item2."Unit Price" := 500;
        Item2."Price Includes VAT" := true;
        Item2.Modify();


        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::"Item Category",
                                FilterItemCategory1.Code,
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::"Item Category",
                                FilterItemCategory2.Code,
                                '',
                                NPRTotalDiscountLine);


        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    500,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);

        // [Given] POS Sale Line with the item 1 which has an item category that is part of the filter
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item1."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSFilterItem1);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOSFilterItem1);

        //RefreshLine
        if SaleLinePOSFilterItem1.Get(SaleLinePOSFilterItem1.RecordId) then;

        // [THEN] The total discount must not be triggered because the amount is not enought
        Assert.IsTrue(SaleLinePOSFilterItem1."Total Discount Code" = '', 'Total Discount was triggered but it shouldnt have been triggered.');

        // [When] POS Sale Line with Filter Item 2 which has an item category that is part of the filter is added
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item2."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSFilterItem2);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOSFilterItem2);

        //RefreshLine
        if SaleLinePOSFilterItem1.Get(SaleLinePOSFilterItem1.RecordId) then;
        if SaleLinePOSFilterItem2.Get(SaleLinePOSFilterItem2.RecordId) then;

        // [THEN] The total discount must be triggered 
        Assert.IsTrue(SaleLinePOSFilterItem1."Total Discount Code" <> '', 'Total Discount was not applied correctly.');
        Assert.IsTrue(SaleLinePOSFilterItem2."Total Discount Code" <> '', 'Total Discount was not applied correctly.');

    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountWithMultipleVendorFiltersWillBeTriggeredOnTotalPressed()
    var
        Item1: Record Item;
        Item2: Record Item;
        FilterVendor1: Record Vendor;
        FilterVendor2: Record Vendor;
        SaleLinePOSFilterItem1: Record "NPR POS Sale Line";
        SaleLinePOSFilterItem2: Record "NPR POS Sale Line";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
        LibraryPurchase: Codeunit "Library - Purchase";
    begin
        // [SCENARIO] Check if the total discount with multiple vendor filters is triggered when total pressed

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Filter Vendor 1     
        LibraryPurchase.CreateVendor(FilterVendor1);

        // [GIVEN] Filter Vendor 2     
        LibraryPurchase.CreateVendor(FilterVendor2);


        // [GIVEN] Item 1 with Filter Vendor1       
        CreateItem(Item1,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);

        Item1."Vendor No." := FilterVendor1."No.";
        Item1."Unit Price" := 500;
        Item1."Price Includes VAT" := true;
        Item1.Modify();


        // [GIVEN] Filter Item 2 with Filter Vendor2             
        CreateItem(Item2,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);

        Item2."Vendor No." := FilterVendor2."No.";
        Item2."Unit Price" := 500;
        Item2."Price Includes VAT" := true;
        Item2.Modify();


        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::Vendor,
                                FilterVendor1."No.",
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::Vendor,
                                FilterVendor2."No.",
                                '',
                                NPRTotalDiscountLine);


        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    500,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);

        // [Given] POS Sale Line with the item 1 which has a vendor that is part of the filter
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item1."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSFilterItem1);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOSFilterItem1);

        //RefreshLine
        if SaleLinePOSFilterItem1.Get(SaleLinePOSFilterItem1.RecordId) then;

        // [THEN] The total discount must not be triggered because the amount is not enought
        Assert.IsTrue(SaleLinePOSFilterItem1."Total Discount Code" = '', 'Total Discount was triggered but it shouldnt have been triggered.');

        // [When] POS Sale Line with Filter Item 2 which has a vendor that is part of the filter is added
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item2."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSFilterItem2);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOSFilterItem2);

        //RefreshLine
        if SaleLinePOSFilterItem1.Get(SaleLinePOSFilterItem1.RecordId) then;
        if SaleLinePOSFilterItem2.Get(SaleLinePOSFilterItem2.RecordId) then;

        // [THEN] The total discount must be triggered 
        Assert.IsTrue(SaleLinePOSFilterItem1."Total Discount Code" <> '', 'Total Discount was not applied correctly.');
        Assert.IsTrue(SaleLinePOSFilterItem2."Total Discount Code" <> '', 'Total Discount was not applied correctly.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountWithMixedFiltersWillBeTriggeredOnTotalPressed()
    var
        FilterItem1: Record Item;
        Item2: Record Item;
        Item3: Record Item;
        FilterVendor: Record Vendor;
        FilterItemCategory: Record "Item Category";
        SaleLinePOSFilterItem1: Record "NPR POS Sale Line";
        SaleLinePOSFilterItem2: Record "NPR POS Sale Line";
        SaleLinePOSFilterItem3: Record "NPR POS Sale Line";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryInventory: Codeunit "Library - Inventory";

    begin
        // [SCENARIO] Check if the total discount with mixed filters is triggered when total pressed

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(NPRTotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Filter Vendor 1     
        LibraryPurchase.CreateVendor(FilterVendor);

        // [GIVEN] Filter Vendor 2     
        LibraryInventory.CreateItemCategory(FilterItemCategory);


        // [GIVEN] Filter Item 1
        CreateItem(FilterItem1,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);

        FilterItem1."Unit Price" := 500;
        FilterItem1."Price Includes VAT" := true;
        FilterItem1.Modify();


        // [GIVEN] Filter Item 2 with Filter Vendor            
        CreateItem(Item2,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);

        Item2."Vendor No." := FilterVendor."No.";
        Item2."Price Includes VAT" := true;
        Item2."Unit Price" := 500;
        Item2.Modify();

        // [GIVEN] Filter Item 3 with Filter Item Category            
        CreateItem(Item3,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);

        Item3."Item Category Code" := FilterItemCategory.Code;
        Item3."Price Includes VAT" := true;
        Item3."Unit Price" := 500;
        Item3.Modify();


        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::Item,
                                FilterItem1."No.",
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::Vendor,
                                FilterVendor."No.",
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::"Item Category",
                                FilterItemCategory.Code,
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1500,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    500,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);

        // [Given] POS Sale Line with the Filter item 1
        LibraryPOSMock.CreateItemLine(POSSession,
                                      FilterItem1."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSFilterItem1);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOSFilterItem1);

        //RefreshLine
        if SaleLinePOSFilterItem1.Get(SaleLinePOSFilterItem1.RecordId) then;

        // [THEN] The total discount must not be triggered because the amount is not enought
        Assert.IsTrue(SaleLinePOSFilterItem1."Total Discount Code" = '', 'Total Discount was triggered but it shouldnt have been triggered.');

        // [When] POS Sale Line with Filter Item 2 which has a vendor that is part of the filter is added
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item2."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSFilterItem2);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOSFilterItem2);

        //RefreshLine
        if SaleLinePOSFilterItem1.Get(SaleLinePOSFilterItem1.RecordId) then;
        if SaleLinePOSFilterItem2.Get(SaleLinePOSFilterItem2.RecordId) then;

        // [THEN] The total discount must not be triggered because the amount is not enought
        Assert.IsTrue(SaleLinePOSFilterItem1."Total Discount Code" = '', 'Total Discount was triggered but it shouldnt have been triggered.');
        Assert.IsTrue(SaleLinePOSFilterItem2."Total Discount Code" = '', 'Total Discount was triggered but it shouldnt have been triggered.');


        // [When] POS Sale Line with Filter Item 3 which has an item category that is part of the filter is added
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item3."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSFilterItem3);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOSFilterItem3);

        //RefreshLine
        if SaleLinePOSFilterItem1.Get(SaleLinePOSFilterItem1.RecordId) then;
        if SaleLinePOSFilterItem2.Get(SaleLinePOSFilterItem2.RecordId) then;
        if SaleLinePOSFilterItem3.Get(SaleLinePOSFilterItem3.RecordId) then;

        // [THEN] The total discount must be triggered 
        Assert.IsTrue(SaleLinePOSFilterItem1."Total Discount Code" <> '', 'Total Discount was not applied correctly.');
        Assert.IsTrue(SaleLinePOSFilterItem2."Total Discount Code" <> '', 'Total Discount was not applied correctly.');
        Assert.IsTrue(SaleLinePOSFilterItem3."Total Discount Code" <> '', 'Total Discount was not applied correctly.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountIsRemovedWhenUsingRemoveLineDiscountWorkflow()
    var
        FilterItem: Record Item;
        BenefitItem: Record Item;
        SalePOS: Record "NPR POS Sale";
        SaleLinePOSFilterItem: Record "NPR POS Sale Line";
        SalesLineBenefitItem: Record "NPR POS Sale Line";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        TempNPRTotalDiscBenItemBuffer: Record "NPR Total Disc Ben Item Buffer" temporary;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        TotalDiscountManagement: Codeunit "NPR Total Discount Management";
        POSActionDiscountB: Codeunit "NPR POS Action - Discount B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        CalculateDiscountsB: Codeunit "NPR POS Action Calc DiscountsB";
        FrontEnd: Codeunit "NPR POS Front End Management";
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
        InputIncludesTax: Option Always,IfPricesInclTax,Never;
    begin
        // [SCENARIO] Check total discount percent is removed from the pos when remove discount workflow used

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(TotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Filter Item        
        CreateItem(FilterItem, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);

        FilterItem."Unit Price" := 1000;
        FilterItem."Price Includes VAT" := true;
        FilterItem.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader, '', Enum::"NPR Total Discount Amount Calc"::"Discount Filters", Enum::"NPR Total Discount Application"::"Discount Filters", 0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader, Enum::"NPR Total Discount Line Type"::Item, FilterItem."No.", '', NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader, 1000, Enum::"NPR Total Disc. Benefit Type"::Discount, '', '', 0, Enum::"NPR Total Disc Ben Value Type"::Percent, 25, false, NPRTotalDiscountBenefit);

        // [GIVEN] Benefit item      
        Clear(BenefitItem);
        CreateItem(BenefitItem, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);

        // [GIVEN] Benefit Item Line
        CreateTotalDiscountBenefits(NPRTotalDiscountHeader, 1000, Enum::"NPR Total Disc. Benefit Type"::Item, BenefitItem."No.", '', 1, Enum::"NPR Total Disc Ben Value Type"::Amount, 0, true, NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader, 0T, 0T, NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] POS Sale Line with the Filter item 1 which is part of the filter
        LibraryPOSMock.CreateItemLine(POSSession, FilterItem."No.", 1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSFilterItem);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOSFilterItem);

        if CalculateDiscountsB.GetTotalDiscountBenefitItems(SalePOS, Enum::"NPR Benefit Items Collection"::"No Input Needed", TempNPRTotalDiscBenItemBuffer) then
            CalculateDiscountsB.AddBenefitItems(SalePOS, TempNPRTotalDiscBenItemBuffer, FrontEnd);

        //RefreshLine
        if SaleLinePOSFilterItem.Get(SaleLinePOSFilterItem.RecordId) then;

        // [THEN] The total discount must be triggered
        Assert.IsTrue(SaleLinePOSFilterItem."Total Discount Code" <> '', 'Total Discount was not triggered but it shouldn have been triggered.');

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SalesLineBenefitItem);
        // [THEN] The total discount must be triggered 
        Assert.IsTrue(SalesLineBenefitItem."Total Discount Code" <> '', 'Total Discount was not triggered but it shouldn have been triggered.');

        // [THEN] The total discount must not be triggered because the amount is not enought
        Assert.IsTrue(SalesLineBenefitItem."Benefit Item", 'The line must be a benefit item but its not');


        // [WHEN] Clear Line Discount Pressed
        POSActionDiscountB.StoreAdditionalParams('', '', '', '', '', InputIncludesTax::Always);
        POSActionDiscountB.ProcessRequest(DiscountType::ClearTotalDiscount, 0, SalePOS, SaleLinePOSFilterItem, 1);

        // [Then] Total disocunt should be removed from the transaction
        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetFilter("Total Discount Code", '<>%1', '');
        Assert.IsTrue(SaleLinePOS.IsEmpty, 'Total Discount is applied to the POS Sale, but it shouldnt be.');

        SaleLinePOS.SetRange("Total Discount Code");
        SaleLinePOS.SetFilter("Total Discount Step", '<>0');
        Assert.IsTrue(SaleLinePOS.IsEmpty(), 'Total Discount is applied to the POS Sale, but it shouldnt be.');

        SaleLinePOS.SetRange("Total Discount Step");
        SaleLinePOS.SetFilter("Total Discount Amount", '<>0');
        Assert.IsTrue(SaleLinePOS.IsEmpty, 'Total Discount is applied to the POS Sale, but it shouldnt be.');

        // [Then] No benefit items should be present in the transaction
        SaleLinePOS.SetRange("Total Discount Amount");
        SaleLinePOS.SetRange("Benefit Item", true);
        Assert.IsTrue(SaleLinePOS.IsEmpty, 'Total Discount is applied to the POS Sale, but it shouldnt be.');

        // [Then] The discount in the transaction should be 0l
        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.CalcSums("Discount Amount");
        Assert.IsTrue(SaleLinePOS."Discount Amount" = 0, 'The discount amount in the transaction is different than 0, but it should be 0.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountIsRemovedWhenUsingRemoveTotalDiscountWorkflow()
    var
        FilterItem: Record Item;
        BenefitItem: Record Item;
        SalePOS: Record "NPR POS Sale";
        SaleLinePOSFilterItem: Record "NPR POS Sale Line";
        SalesLineBenefitItem: Record "NPR POS Sale Line";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        TempNPRTotalDiscBenItemBuffer: Record "NPR Total Disc Ben Item Buffer" temporary;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        TotalDiscountManagement: Codeunit "NPR Total Discount Management";
        POSActionDiscountB: Codeunit "NPR POS Action - Discount B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        CalculateDiscountsB: Codeunit "NPR POS Action Calc DiscountsB";
        FrontEnd: Codeunit "NPR POS Front End Management";
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
        InputIncludesTax: Option Always,IfPricesInclTax,Never;
    begin
        // [SCENARIO] Check total discount percent is removed from the pos when remove discount workflow used

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(TotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Filter Item        
        CreateItem(FilterItem, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);

        FilterItem."Unit Price" := 1000;
        FilterItem."Price Includes VAT" := true;
        FilterItem.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader, '', Enum::"NPR Total Discount Amount Calc"::"Discount Filters", Enum::"NPR Total Discount Application"::"Discount Filters", 0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader, Enum::"NPR Total Discount Line Type"::Item, FilterItem."No.", '', NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader, 1000, Enum::"NPR Total Disc. Benefit Type"::Discount, '', '', 0, Enum::"NPR Total Disc Ben Value Type"::Percent, 25, false, NPRTotalDiscountBenefit);

        // [GIVEN] Benefit item      
        Clear(BenefitItem);
        CreateItem(BenefitItem, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);

        // [GIVEN] Benefit Item Line
        CreateTotalDiscountBenefits(NPRTotalDiscountHeader, 1000, Enum::"NPR Total Disc. Benefit Type"::Item, BenefitItem."No.", '', 1, Enum::"NPR Total Disc Ben Value Type"::Amount, 0, true, NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader, 0T, 0T, NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] POS Sale Line with the Filter item 1 which is part of the filter
        LibraryPOSMock.CreateItemLine(POSSession, FilterItem."No.", 1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSFilterItem);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOSFilterItem);

        if CalculateDiscountsB.GetTotalDiscountBenefitItems(SalePOS, Enum::"NPR Benefit Items Collection"::"No Input Needed", TempNPRTotalDiscBenItemBuffer) then
            CalculateDiscountsB.AddBenefitItems(SalePOS, TempNPRTotalDiscBenItemBuffer, FrontEnd);

        //RefreshLine
        if SaleLinePOSFilterItem.Get(SaleLinePOSFilterItem.RecordId) then;

        // [THEN] The total discount must be triggered
        Assert.IsTrue(SaleLinePOSFilterItem."Total Discount Code" <> '', 'Total Discount was not triggered but it shouldn have been triggered.');

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SalesLineBenefitItem);
        // [THEN] The total discount must be triggered 
        Assert.IsTrue(SalesLineBenefitItem."Total Discount Code" <> '', 'Total Discount was not triggered but it shouldn have been triggered.');

        // [THEN] The total discount must not be triggered because the amount is not enought
        Assert.IsTrue(SalesLineBenefitItem."Benefit Item", 'The line must be a benefit item but its not');


        // [WHEN] Clear Line Discount Pressed
        POSActionDiscountB.StoreAdditionalParams('', '', '', '', '', InputIncludesTax::Always);
        POSActionDiscountB.ProcessRequest(DiscountType::ClearTotalDiscount, 0, SalePOS, SaleLinePOSFilterItem, 1);

        // [Then] Total disocunt should be removed from the transaction
        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetFilter("Total Discount Code", '<>%1', '');
        Assert.IsTrue(SaleLinePOS.IsEmpty, 'Total Discount is applied to the POS Sale, but it shouldnt be.');

        SaleLinePOS.SetRange("Total Discount Code");
        SaleLinePOS.SetFilter("Total Discount Step", '<>0');
        Assert.IsTrue(SaleLinePOS.IsEmpty(), 'Total Discount is applied to the POS Sale, but it shouldnt be.');

        SaleLinePOS.SetRange("Total Discount Step");
        SaleLinePOS.SetFilter("Total Discount Amount", '<>0');
        Assert.IsTrue(SaleLinePOS.IsEmpty, 'Total Discount is applied to the POS Sale, but it shouldnt be.');

        // [Then] No benefit items should be present in the transaction
        SaleLinePOS.SetRange("Total Discount Amount");
        SaleLinePOS.SetRange("Benefit Item", true);
        Assert.IsTrue(SaleLinePOS.IsEmpty, 'Total Discount is applied to the POS Sale, but it shouldnt be.');

        // [Then] The discount in the transaction should be 0l
        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.CalcSums("Discount Amount");
        Assert.IsTrue(SaleLinePOS."Discount Amount" = 0, 'The discount amount in the transaction is different than 0, but it should be 0.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountIsRemovedWhenAssigningLineDiscount()
    var
        FilterItem: Record Item;
        BenefitItem: Record Item;
        SalePOS: Record "NPR POS Sale";
        SaleLinePOSFilterItem: Record "NPR POS Sale Line";
        SalesLineBenefitItem: Record "NPR POS Sale Line";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        TempNPRTotalDiscBenItemBuffer: Record "NPR Total Disc Ben Item Buffer" temporary;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        TotalDiscountManagement: Codeunit "NPR Total Discount Management";
        POSActionDiscountB: Codeunit "NPR POS Action - Discount B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        CalculateDiscountsB: Codeunit "NPR POS Action Calc DiscountsB";
        FrontEnd: Codeunit "NPR POS Front End Management";
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
        InputIncludesTax: Option Always,IfPricesInclTax,Never;
    begin
        // [SCENARIO] Check total discount percent is removed from the pos when remove discount workflow used

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(TotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Filter Item        
        CreateItem(FilterItem, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);

        FilterItem."Unit Price" := 1000;
        FilterItem."Price Includes VAT" := true;
        FilterItem.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader, '', Enum::"NPR Total Discount Amount Calc"::"Discount Filters", Enum::"NPR Total Discount Application"::"Discount Filters", 0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader, Enum::"NPR Total Discount Line Type"::Item, FilterItem."No.", '', NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader, 1000, Enum::"NPR Total Disc. Benefit Type"::Discount, '', '', 0, Enum::"NPR Total Disc Ben Value Type"::Percent, 25, false, NPRTotalDiscountBenefit);

        // [GIVEN] Benefit item      
        Clear(BenefitItem);
        CreateItem(BenefitItem, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);

        // [GIVEN] Benefit Item Line
        CreateTotalDiscountBenefits(NPRTotalDiscountHeader, 1000, Enum::"NPR Total Disc. Benefit Type"::Item, BenefitItem."No.", '', 1, Enum::"NPR Total Disc Ben Value Type"::Amount, 0, true, NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader, 0T, 0T, NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] POS Sale Line with the Filter item 1 which is part of the filter
        LibraryPOSMock.CreateItemLine(POSSession, FilterItem."No.", 1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSFilterItem);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOSFilterItem);

        if CalculateDiscountsB.GetTotalDiscountBenefitItems(SalePOS, Enum::"NPR Benefit Items Collection"::"No Input Needed", TempNPRTotalDiscBenItemBuffer) then
            CalculateDiscountsB.AddBenefitItems(SalePOS, TempNPRTotalDiscBenItemBuffer, FrontEnd);

        //RefreshLine
        if SaleLinePOSFilterItem.Get(SaleLinePOSFilterItem.RecordId) then;

        // [THEN] The total discount must be triggered
        Assert.IsTrue(SaleLinePOSFilterItem."Total Discount Code" <> '', 'Total Discount was not triggered but it shouldn have been triggered.');

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SalesLineBenefitItem);
        // [THEN] The total discount must be triggered 
        Assert.IsTrue(SalesLineBenefitItem."Total Discount Code" <> '', 'Total Discount was not triggered but it shouldn have been triggered.');

        // [THEN] The total discount must not be triggered because the amount is not enought
        Assert.IsTrue(SalesLineBenefitItem."Benefit Item", 'The line must be a benefit item but its not');


        // [WHEN] Assign Line Discount Pressed
        POSActionDiscountB.StoreAdditionalParams('', '', '', '', '', InputIncludesTax::Always);
        POSActionDiscountB.ProcessRequest(DiscountType::LineDiscountPercentABS, 20, SalePOS, SaleLinePOSFilterItem, 1);

        // [Then] Total disocunt should be removed from the transaction
        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetFilter("Total Discount Code", '<>%1', '');
        Assert.IsTrue(SaleLinePOS.IsEmpty, 'Total Discount is applied to the POS Sale, but it shouldnt be.');

        SaleLinePOS.SetRange("Total Discount Code");
        SaleLinePOS.SetFilter("Total Discount Step", '<>0');
        Assert.IsTrue(SaleLinePOS.IsEmpty(), 'Total Discount is applied to the POS Sale, but it shouldnt be.');

        SaleLinePOS.SetRange("Total Discount Step");
        SaleLinePOS.SetFilter("Total Discount Amount", '<>0');
        Assert.IsTrue(SaleLinePOS.IsEmpty, 'Total Discount is applied to the POS Sale, but it shouldnt be.');

        // [Then] No benefit items should be present in the transaction
        SaleLinePOS.SetRange("Total Discount Amount");
        SaleLinePOS.SetRange("Benefit Item", true);
        Assert.IsTrue(SaleLinePOS.IsEmpty, 'Total Discount is applied to the POS Sale, but it shouldnt be.');

        // [Then] The discount in the transaction should be the same as the line discount
        //Refresh
        SaleLinePOSFilterItem.Get(SaleLinePOSFilterItem.RecordId);
        Assert.IsTrue(SaleLinePOSFilterItem."Discount %" = 20, 'The discount amount in the transaction is different than the assigned line discount.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountIsRemovedWhenAssigningTotalDiscount()
    var
        FilterItem: Record Item;
        BenefitItem: Record Item;
        SalePOS: Record "NPR POS Sale";
        SaleLinePOSFilterItem: Record "NPR POS Sale Line";
        SalesLineBenefitItem: Record "NPR POS Sale Line";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        TempNPRTotalDiscBenItemBuffer: Record "NPR Total Disc Ben Item Buffer" temporary;
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        TotalDiscountManagement: Codeunit "NPR Total Discount Management";
        POSActionDiscountB: Codeunit "NPR POS Action - Discount B";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        CalculateDiscountsB: Codeunit "NPR POS Action Calc DiscountsB";
        FrontEnd: Codeunit "NPR POS Front End Management";
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
        InputIncludesTax: Option Always,IfPricesInclTax,Never;
    begin
        // [SCENARIO] Check total discount percent is removed from the pos when remove discount workflow used

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(Format(TotalDiscountManagement.DiscSourceTableId()));

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Filter Item        
        CreateItem(FilterItem, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);

        FilterItem."Unit Price" := 1000;
        FilterItem."Price Includes VAT" := true;
        FilterItem.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader, '', Enum::"NPR Total Discount Amount Calc"::"Discount Filters", Enum::"NPR Total Discount Application"::"Discount Filters", 0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader, Enum::"NPR Total Discount Line Type"::Item, FilterItem."No.", '', NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader, 1000, Enum::"NPR Total Disc. Benefit Type"::Discount, '', '', 0, Enum::"NPR Total Disc Ben Value Type"::Percent, 25, false, NPRTotalDiscountBenefit);

        // [GIVEN] Benefit item      
        Clear(BenefitItem);
        CreateItem(BenefitItem, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", '', false);

        // [GIVEN] Benefit Item Line
        CreateTotalDiscountBenefits(NPRTotalDiscountHeader, 1000, Enum::"NPR Total Disc. Benefit Type"::Item, BenefitItem."No.", '', 1, Enum::"NPR Total Disc Ben Value Type"::Amount, 0, true, NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader, 0T, 0T, NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [Given] POS Sale Line with the Filter item 1 which is part of the filter
        LibraryPOSMock.CreateItemLine(POSSession, FilterItem."No.", 1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOSFilterItem);

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOSFilterItem);

        if CalculateDiscountsB.GetTotalDiscountBenefitItems(SalePOS, Enum::"NPR Benefit Items Collection"::"No Input Needed", TempNPRTotalDiscBenItemBuffer) then
            CalculateDiscountsB.AddBenefitItems(SalePOS, TempNPRTotalDiscBenItemBuffer, FrontEnd);

        //RefreshLine
        if SaleLinePOSFilterItem.Get(SaleLinePOSFilterItem.RecordId) then;

        // [THEN] The total discount must be triggered
        Assert.IsTrue(SaleLinePOSFilterItem."Total Discount Code" <> '', 'Total Discount was not triggered but it shouldn have been triggered.');

        POSSaleLine.SetLast();
        POSSaleLine.GetCurrentSaleLine(SalesLineBenefitItem);
        // [THEN] The total discount must be triggered 
        Assert.IsTrue(SalesLineBenefitItem."Total Discount Code" <> '', 'Total Discount was not triggered but it shouldn have been triggered.');

        // [THEN] The total discount must not be triggered because the amount is not enought
        Assert.IsTrue(SalesLineBenefitItem."Benefit Item", 'The line must be a benefit item but its not');


        // [WHEN] Assign Line Discount Pressed
        POSActionDiscountB.StoreAdditionalParams('', '', '', '', '', InputIncludesTax::Always);
        POSActionDiscountB.ProcessRequest(DiscountType::DiscountPercentABS, 20, SalePOS, SaleLinePOSFilterItem, 1);

        // [Then] Total disocunt should be removed from the transaction
        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetFilter("Total Discount Code", '<>%1', '');
        Assert.IsTrue(SaleLinePOS.IsEmpty, 'Total Discount is applied to the POS Sale, but it shouldnt be.');

        SaleLinePOS.SetRange("Total Discount Code");
        SaleLinePOS.SetFilter("Total Discount Step", '<>0');
        Assert.IsTrue(SaleLinePOS.IsEmpty(), 'Total Discount is applied to the POS Sale, but it shouldnt be.');

        SaleLinePOS.SetRange("Total Discount Step");
        SaleLinePOS.SetFilter("Total Discount Amount", '<>0');
        Assert.IsTrue(SaleLinePOS.IsEmpty, 'Total Discount is applied to the POS Sale, but it shouldnt be.');

        // [Then] No benefit items should be present in the transaction
        SaleLinePOS.SetRange("Total Discount Amount");
        SaleLinePOS.SetRange("Benefit Item", true);
        Assert.IsTrue(SaleLinePOS.IsEmpty, 'Total Discount is applied to the POS Sale, but it shouldnt be.');

        // [Then] The discount in the transaction should be the same as the line discount
        //Refresh
        SaleLinePOSFilterItem.Get(SaleLinePOSFilterItem.RecordId);
        Assert.IsTrue(SaleLinePOSFilterItem."Discount %" = 20, 'The discount amount in the transaction is different than the assigned line discount.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountIsTriggeredCorrectlyWithTotalDiscountPercentAndMixedDiscount()
    var
        ItemCategory: Record "Item Category";
        NPRMixedDiscount: Record "NPR Mixed Discount";
        NPRMixedDiscountLine: Record "NPR Mixed Discount Line";
        SalePOS: Record "NPR POS Sale";
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        NPRMixedDiscountManagement: Codeunit "NPR Mixed Discount Management";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
        POSActionDiscountB: Codeunit "NPR POS Action - Discount B";
        DisountFitlerLbl: Label '%1|%2', Locked = true, Comment = '%1 - discount code, %2 - discount code';
        DiscountFilter: Text;
        DiscountType: Option TotalAmount,TotalDiscountAmount,DiscountPercentABS,DiscountPercentREL,LineAmount,LineDiscountAmount,LineDiscountPercentABS,LineDiscountPercentREL,LineUnitPrice,ClearLineDiscount,ClearTotalDiscount,DiscountPercentExtra,LineDiscountPercentExtra;
        InputIncludesTax: Option Always,IfPricesInclTax,Never;
    begin
        // [SCENARIO] Check if three level mixed total discount is triggered when total pressed

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        DiscountFilter := StrSubstNo(DisountFitlerLbl, NPRTotalDiscountManagement.DiscSourceTableId(), NPRMixedDiscountManagement.DiscSourceTableId());

        // [GIVEN] Enable discount
        EnableDiscount(DiscountFilter);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader, '', Enum::"NPR Total Discount Amount Calc"::"Discount Filters", Enum::"NPR Total Discount Application"::"Discount Filters", 0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader, Enum::"NPR Total Discount Line Type"::All, '', '', NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader, 1000, Enum::"NPR Total Disc. Benefit Type"::Discount, '', '', 0, Enum::"NPR Total Disc Ben Value Type"::Amount, 500, false, NPRTotalDiscountBenefit);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader, 3000, Enum::"NPR Total Disc. Benefit Type"::Discount, '', '', 0, Enum::"NPR Total Disc Ben Value Type"::Amount, 1000, false, NPRTotalDiscountBenefit);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader, 5000, Enum::"NPR Total Disc. Benefit Type"::Discount, '', '', 0, Enum::"NPR Total Disc Ben Value Type"::Amount, 1500, false, NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader, 0T, 0T, NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [GIVEN] Filter Item Category     
        LibraryInventory.CreateItemCategory(ItemCategory);


        // [GIVEN] Mixed discount
        CreateMixedDiscount(NPRMixedDiscount, NPRMixedDiscountLine, ItemCategory, 50);

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        // [THEN] Check Total Discount Applied
        CheckTotalDiscountBenefitsWithMixedDiscount(SalePOS, NPRTotalDiscountHeader, NPRMixedDiscount, VATPostingSetup);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [WHEN] Assign Line Discount Pressed
        POSActionDiscountB.StoreAdditionalParams('', '', '', '', '', InputIncludesTax::Always);
        POSActionDiscountB.ProcessRequest(DiscountType::DiscountPercentABS, 20, SalePOS, SaleLinePOS, 1);

        // [Then] The discount in the transaction should be the same as the line discount
        //Refresh
        SaleLinePOS.Get(SaleLinePOS.RecordId);
        Assert.IsTrue(SaleLinePOS."Discount %" = 20, 'The discount amount in the transaction is different than the assigned line discount.');

        Assert.IsTrue(SaleLinePOS."Discount Type" = SaleLinePOS."Discount Type"::Manual, 'The discount type is not manual but it should be.');

        // [Then] Total disocunt should be removed from the transaction
        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetFilter("Total Discount Code", '<>%1', '');
        Assert.IsTrue(SaleLinePOS.IsEmpty, 'Total Discount is applied to the POS Sale, but it shouldnt be.');

        SaleLinePOS.SetRange("Total Discount Code");
        SaleLinePOS.SetFilter("Total Discount Step", '<>0');
        Assert.IsTrue(SaleLinePOS.IsEmpty(), 'Total Discount is applied to the POS Sale, but it shouldnt be.');

        SaleLinePOS.SetRange("Total Discount Step");
        SaleLinePOS.SetFilter("Total Discount Amount", '<>0');
        Assert.IsTrue(SaleLinePOS.IsEmpty, 'Total Discount is applied to the POS Sale, but it shouldnt be.');

        // [Then] Mix disocunt should be removed from the transaction
        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Discount Type", SaleLinePOS."Discount Type"::Mix);
        Assert.IsTrue(SaleLinePOS.IsEmpty, 'Mix discount is applied to the POS Sale, but it shouldnt be.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfPOSSaleTaxLinesExistAfterApplyTotalDiscountBeforePosting()
    var
        SalePOS: Record "NPR POS Sale";
        Item: Record Item;
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscTimeIntervSecond: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountBenefitSecond: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountHeaderSecond: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        NPRTotalDiscountLineSecond: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        DiscountFilter: Text;
    begin
        // [SCENARIO] Check if POS Sale Tax lines exist after total discount calculation before posting

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(DiscountFilter);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] 2 Total Discounts
        CreateTotalDiscountHeader(NPRTotalDiscountHeader, '', Enum::"NPR Total Discount Amount Calc"::"Discount Filters", Enum::"NPR Total Discount Application"::"Discount Filters", 0);
        CreateTotalDiscountLine(NPRTotalDiscountHeader, Enum::"NPR Total Discount Line Type"::All, '', '', NPRTotalDiscountLine);
        CreateTotalDiscountBenefits(NPRTotalDiscountHeader, 15000, Enum::"NPR Total Disc. Benefit Type"::Discount, '', '', 0, Enum::"NPR Total Disc Ben Value Type"::Amount, 500, false, NPRTotalDiscountBenefit);

        CreateTotalDiscountHeader(NPRTotalDiscountHeaderSecond, '', Enum::"NPR Total Discount Amount Calc"::"Discount Filters", Enum::"NPR Total Discount Application"::"Discount Filters", 1);
        CreateTotalDiscountLine(NPRTotalDiscountHeaderSecond, Enum::"NPR Total Discount Line Type"::All, '', '', NPRTotalDiscountLineSecond);
        CreateTotalDiscountBenefits(NPRTotalDiscountHeaderSecond, 15000, Enum::"NPR Total Disc. Benefit Type"::Discount, '', '', 0, Enum::"NPR Total Disc Ben Value Type"::Amount, 500, false, NPRTotalDiscountBenefitSecond);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader, 0T, 0T, NPRTotalDiscTimeInterv);
        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeaderSecond, 0T, 0T, NPRTotalDiscTimeIntervSecond);
        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeaderSecond.Status := NPRTotalDiscountHeaderSecond.Status::Active;
        NPRTotalDiscountHeader.Modify();
        NPRTotalDiscountHeaderSecond.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        CreateItem(Item,
                  VATPostingSetup."VAT Bus. Posting Group",
                  VATPostingSetup."VAT Prod. Posting Group",
                  '',
                  true);

        Item."Unit Price" := 14000;
        Item.Modify();

        // [Given] POS Sale Line with the item
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        //[THEN] POS Sale Tax Line should be created but discount not applied
        Assert.IsTrue(POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId), 'POS Sale Tax Line not created.');
        Assert.AreEqual(POSSaleTax."Source Discount Amount", 0, 'Total Discount was applied and that is not according to scenario.');

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOS);

        //RefreshLine
        if not SaleLinePOS.Get(SaleLinePOS.RecordId) then
            Clear(SaleLinePOS);
        Assert.IsTrue(POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId), 'POS Sale Tax Line not created.');

        // [THEN] Total Discount should not be applied
        SaleLinePOS.Get(SaleLinePOS.RecordId);
        Assert.IsTrue(SaleLinePOS."Total Discount Code" = '', 'Total Discount was applied.');
        Assert.IsTrue(SaleLinePOS."Total Discount Step" = 0, 'The correct Total Discount Step was applied.');
        Assert.IsTrue(SaleLinePOS."Discount Amount" = 0, 'The total discount amount is incorrect.');

        // [THEN] Total Discount should be same on POS Sale Line and POS Sale Tax line
        Assert.IsTrue(POSSaleTax."Source Rec. System Id" = SaleLinePOS.SystemId, 'POS Sale Tax Line not created.');
        Assert.IsTrue(SaleLinePOS."Discount Amount" = POSSaleTax."Source Discount Amount", 'Total Discount amount not applied accordign to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfPOSSaleTaxLinesExistAfterApplyTotalDiscountAfterPosting()
    var
        SalePOS: Record "NPR POS Sale";
        Item: Record Item;
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscTimeIntervSecond: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountBenefitSecond: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountHeaderSecond: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        NPRTotalDiscountLineSecond: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleTax: Record "NPR POS Sale Tax";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        POSEntry: Record "NPR POS Entry";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        DiscountFilter: Text;
        AmountToPay: Decimal;
        SaleEnded: Boolean;
    begin
        // [SCENARIO] Check if POS Sale Tax lines exist after total discount calculation after posting

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(DiscountFilter);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup, "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] 2 Total Discounts
        CreateTotalDiscountHeader(NPRTotalDiscountHeader, '', Enum::"NPR Total Discount Amount Calc"::"Discount Filters", Enum::"NPR Total Discount Application"::"Discount Filters", 0);
        CreateTotalDiscountLine(NPRTotalDiscountHeader, Enum::"NPR Total Discount Line Type"::All, '', '', NPRTotalDiscountLine);
        CreateTotalDiscountBenefits(NPRTotalDiscountHeader, 15000, Enum::"NPR Total Disc. Benefit Type"::Discount, '', '', 0, Enum::"NPR Total Disc Ben Value Type"::Amount, 500, false, NPRTotalDiscountBenefit);

        CreateTotalDiscountHeader(NPRTotalDiscountHeaderSecond, '', Enum::"NPR Total Discount Amount Calc"::"Discount Filters", Enum::"NPR Total Discount Application"::"Discount Filters", 1);
        CreateTotalDiscountLine(NPRTotalDiscountHeaderSecond, Enum::"NPR Total Discount Line Type"::All, '', '', NPRTotalDiscountLineSecond);
        CreateTotalDiscountBenefits(NPRTotalDiscountHeaderSecond, 15000, Enum::"NPR Total Disc. Benefit Type"::Discount, '', '', 0, Enum::"NPR Total Disc Ben Value Type"::Amount, 500, false, NPRTotalDiscountBenefitSecond);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader, 0T, 0T, NPRTotalDiscTimeInterv);
        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeaderSecond, 0T, 0T, NPRTotalDiscTimeIntervSecond);
        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeaderSecond.Status := NPRTotalDiscountHeaderSecond.Status::Active;
        NPRTotalDiscountHeader.Modify();
        NPRTotalDiscountHeaderSecond.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession, POSUnit, POSSale);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        CreateItem(Item,
                  VATPostingSetup."VAT Bus. Posting Group",
                  VATPostingSetup."VAT Prod. Posting Group",
                  '',
                  true);

        Item."Unit Price" := 14000;
        Item.Modify();

        // [Given] POS Sale Line with the item
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.SetFirst();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        //[THEN] POS Sale Tax Line should be created but discount not applied
        Assert.IsTrue(POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId), 'POS Sale Tax Line not created.');
        Assert.AreEqual(POSSaleTax."Source Discount Amount", 0, 'Total Discount was applied and that is not according to scenario.');

        // [When] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOS);

        //RefreshLine
        if not SaleLinePOS.Get(SaleLinePOS.RecordId) then
            Clear(SaleLinePOS);
        Assert.IsTrue(POSSaleTaxCalc.Find(POSSaleTax, SaleLinePOS.SystemId), 'POS Sale Tax Line not created.');

        // [THEN] Total Discount should not be applied
        SaleLinePOS.Get(SaleLinePOS.RecordId);
        Assert.IsTrue(SaleLinePOS."Total Discount Code" = '', 'Total Discount was not applied.');
        Assert.IsTrue(SaleLinePOS."Total Discount Step" = 0, 'The correct Total Discount Step was not applied.');
        Assert.IsTrue(SaleLinePOS."Discount Amount" = 0, 'The total discount amount is incorrect.');

        // [THEN] Total Discount should be same on POS Sale Line and POS Sale Tax line
        Assert.IsTrue(POSSaleTax."Source Rec. System Id" = SaleLinePOS.SystemId, 'POS Sale Tax Line not created.');
        Assert.IsTrue(SaleLinePOS."Discount Amount" = POSSaleTax."Source Discount Amount", 'Total Discount amount not applied accordign to scenario.');

        AmountToPay := GetAmountToPay(SaleLinePOS);
        AmountToPay := Round(AmountToPay, 1, '>');

        // [WHEN] End of Sale
        SaleEnded := LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, AmountToPay, '');
        Assert.IsTrue(SaleEnded, 'Sale should have ended when applying full payment.');

        // [THEN] Verify POS Entry and POS Entry Tax Line are created
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();
        POSEntryTaxLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntryTaxLine.FindFirst();

        //[THEN] Verify POS Entry Tax Line has correct line amount value
        Assert.AreEqual(SaleLinePOS."Amount Including VAT", POSEntryTaxLine."Amount Including Tax", 'Amount on POS Entry Tax Line is not calculated according to scenario.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountAppliedItemWithUOM()
    var
        SalePOS: Record "NPR POS Sale";
        Item: Record Item;
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        UnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        LibraryInventory: Codeunit "Library - Inventory";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        DiscountFilter: Text;
        ExpectedTotalAmountIncludingVAT: Decimal;
        ExpectedTotalDiscountAmount: Decimal;
    begin
        // [SCENARIO] Check if the total discount with item filter is triggered when total pressed

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(DiscountFilter);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitOfMeasure, Item."No.", UnitOfMeasure.Code, 1);
        Item."Unit Price" := 2000;
        Item."Base Unit of Measure" := UnitOfMeasure.Code;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::Item,
                                Item."No.",
                                '',
                                NPRTotalDiscountLine);
        NPRTotalDiscountLine."Unit Of Measure Code" := UnitOfMeasure.Code;
        NPRTotalDiscountLine.Modify();

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    500,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);

        // [GIVEN] POS Sale Line with the item which is part of the filter
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [WHEN] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOS);

        //Refresh Line
        if SaleLinePOS.Get(SaleLinePOS.RecordId) then;

        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);
        ExpectedTotalAmountIncludingVAT := SaleLinePOS."Unit Price" * SaleLinePOS.Quantity - NPRTotalDiscountBenefit.Value;
        ExpectedTotalAmountIncludingVAT := Round(ExpectedTotalAmountIncludingVAT, GeneralLedgerSetup."Amount Rounding Precision");
        ExpectedTotalDiscountAmount := NPRTotalDiscountBenefit.Value;
        ExpectedTotalDiscountAmount := Round(ExpectedTotalDiscountAmount, GeneralLedgerSetup."Amount Rounding Precision");

        // [THEN] Verify Discount 
        Assert.IsTrue(SaleLinePOS."Total Discount Code" = NPRTotalDiscountHeader.Code, 'Total Discount was not triggered but it should have been triggered.');
        Assert.IsTrue(SaleLinePOS."Amount Including VAT" = ExpectedTotalAmountIncludingVAT, 'Amount Including VAT is not correct after total discount application');
        Assert.IsTrue(SaleLinePOS."Discount Amount" = ExpectedTotalDiscountAmount, 'Discount Amount is not correct after total discount application');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CheckIfTotalDiscountAppliedItemWithDifferentUOMFromDiscountLine()
    var
        SalePOS: Record "NPR POS Sale";
        Item: Record Item;
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        VATPostingSetup: Record "VAT Posting Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        UnitOfMeasure: Record "Unit of Measure";
        SecondUnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        SecondItemUnitOfMeasure: Record "Item Unit of Measure";
        LibraryInventory: Codeunit "Library - Inventory";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        DiscountFilter: Text;
        DifferentUOMCode: Code[10];
        ExpectedTotalAmountIncludingVAT: Decimal;
        ExpectedTotalDiscountAmount: Decimal;
    begin
        // [SCENARIO] Apply total discount with different UOM than on Item on POS Sale

        // [GIVEN] POS, Payment & Tax Setup
        InitializeData();

        // [GIVEN] No Discouts
        DeleteDiscounts();

        // [GIVEN] Enable discount
        EnableDiscount(DiscountFilter);

        // [GIVEN] Tax Posting Setup
        CreateVATPostingSetup(VATPostingSetup,
                              "NPR POS Tax Calc. Type"::"Normal VAT");

        AssignVATBusPostGroupToPOSPostingProfile(VATPostingSetup."VAT Bus. Posting Group");
        AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup);

        // [GIVEN] Item with unit price        
        CreateItem(Item,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitOfMeasure, Item."No.", UnitOfMeasure.Code, 1);
        Item."Unit Price" := 2000;
        Item."Base Unit of Measure" := UnitOfMeasure.Code;
        Item.Modify();

        // [GIVEN] Discount
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::Item,
                                Item."No.",
                                '',
                                NPRTotalDiscountLine);
        LibraryInventory.CreateUnitOfMeasureCode(SecondUnitOfMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(SecondItemUnitOfMeasure, Item."No.", SecondUnitOfMeasure.Code, 1);
        NPRTotalDiscountLine."Unit Of Measure Code" := SecondUnitOfMeasure.Code;
        NPRTotalDiscountLine.Modify();

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    1000,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Amount,
                                    500,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

        // [GIVEN] Active POS session & sale
        LibraryPOSMock.InitializePOSSessionAndStartSaleWithoutActions(POSSession,
                                                                      POSUnit,
                                                                      POSSale);

        // [GIVEN] POS Sale Line with the item which is part of the filter
        LibraryPOSMock.CreateItemLine(POSSession,
                                      Item."No.",
                                      1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        // [WHEN] Total Pressed
        POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOS);

        //Refresh Line
        if SaleLinePOS.Get(SaleLinePOS.RecordId) then;

        // [THEN] Verify Discount not applied
        Assert.IsTrue(SaleLinePOS."Total Discount Code" = '', 'Total Discount was triggered but it should not have been triggered.');
        Assert.IsTrue(SaleLinePOS."Discount Amount" = 0, 'Discount Amount is not correct after total discount application');
    end;

    local procedure CheckTotalDiscountBenefits(SalePOS: Record "NPR POS Sale";
                                               NPRTotalDiscountHeader: Record "NPR Total Discount Header";
                                               VATPostingSetup: Record "VAT Posting Setup")
    var
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        xNPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        AppliedAmount: Decimal;
        ItemUnitPrice: Decimal;
    begin
        AppliedAmount := 0;

        NPRTotalDiscountBenefit.Reset();
        NPRTotalDiscountBenefit.SetRange("Total Discount Code", NPRTotalDiscountHeader.Code);
        if not NPRTotalDiscountBenefit.FindSet(false) then
            exit;

        repeat
            ItemUnitPrice := NPRTotalDiscountBenefit."Step Amount" - AppliedAmount;

            // [GIVEN] Item with unit price        
            Clear(Item);
            CreateItem(Item,
                       VATPostingSetup."VAT Bus. Posting Group",
                       VATPostingSetup."VAT Prod. Posting Group",
                       '',
                       true);

            Item."Unit Price" := ItemUnitPrice;
            Item.Modify();

            // [Given] POS Sale Line
            LibraryPOSMock.CreateItemLine(POSSession,
                                          Item."No.",
                                          1);

            POSSession.GetSaleLine(POSSaleLine);
            POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

            // [When] Total Pressed
            POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOS);

            case NPRTotalDiscountBenefit.Type of
                NPRTotalDiscountBenefit.Type::Discount:
                    CheckTotalDiscountBenefitDiscount(NPRTotalDiscountBenefit,
                                                      SalePOS);
                NPRTotalDiscountBenefit.Type::Item,
                NPRTotalDiscountBenefit.Type::"Item List":
                    if (xNPRTotalDiscountBenefit."Step Amount" <> NPRTotalDiscountBenefit."Step Amount") or
                       (xNPRTotalDiscountBenefit."Total Discount Code" <> NPRTotalDiscountBenefit."Total Discount Code")
                    then begin
                        CheckTotalDiscountNonDiscountBenefits(NPRTotalDiscountBenefit,
                                                              SalePOS);
                        xNPRTotalDiscountBenefit := NPRTotalDiscountBenefit;
                    end;
            end;

            AppliedAmount := NPRTotalDiscountBenefit."Step Amount";

        until NPRTotalDiscountBenefit.Next() = 0;

    end;

    local procedure CheckTotalDiscountBenefitDiscount(NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
                                                      SalePOS: Record "NPR POS Sale")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SaleLinePOS: Record "NPR POS Sale Line";
        TotalAmountIncludingVATWithoutTotalDiscount: Decimal;
        TotalDiscountAmount: Decimal;
        TotalDiscountPercentage: Decimal;
    begin
        if not GeneralLedgerSetup.Get() then
            Clear(GeneralLedgerSetup);


        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        SaleLinePOS.SetRange("Benefit Item", false);
        SaleLinePOS.CalcSums("Amount Including VAT",
                             "Discount Amount",
                             "Disc. Amt. Without Total Disc.",
                             "Total Discount Amount");

        TotalDiscountAmount := SaleLinePOS."Total Discount Amount";
        TotalAmountIncludingVATWithoutTotalDiscount := SaleLinePOS."Amount Including VAT" + SaleLinePOS."Total Discount Amount";

        if SaleLinePOS.FindFirst() then;

        // [Then] Total Discount Level Should have been triggered and assigned tot he line
        Assert.IsTrue(SaleLinePOS."Total Discount Code" = NPRTotalDiscountBenefit."Total Discount Code", 'Total Discount was not triggered but it should have been triggered.');
        Assert.IsTrue(SaleLinePOS."Total Discount Step" = NPRTotalDiscountBenefit."Step Amount", 'The correct total discount amount step was not triggered');
        Assert.IsTrue(TotalAmountIncludingVATWithoutTotalDiscount >= NPRTotalDiscountBenefit."Step Amount", 'The POS Sale trigger amount is not correct');

        // [Then] Total Discount Discount should have been applied to the transaction
        case NPRTotalDiscountBenefit."Value Type" Of
            NPRTotalDiscountBenefit."Value Type"::Amount:
                Assert.IsTrue(TotalDiscountAmount = NPRTotalDiscountBenefit.Value, 'Total Discount Amount is wrong.');

            NPRTotalDiscountBenefit."Value Type"::Percent:
                begin
                    TotalDiscountPercentage := Round(TotalDiscountAmount / TotalAmountIncludingVATWithoutTotalDiscount, GeneralLedgerSetup."Amount Rounding Precision") * 100;
                    Assert.IsTrue(TotalDiscountPercentage = NPRTotalDiscountBenefit.Value, 'Discount Amount is not correct after total discount application.');
                end;
        end;

    end;

    local procedure CheckTotalDiscountNonDiscountBenefits(CurrNPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
                                                          SalePOS: Record "NPR POS Sale")
    var
        TempNPRTotalDiscBenItemBuffer: Record "NPR Total Disc Ben Item Buffer" temporary;
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        NPRTotalDiscountManagement.GetTotalDiscountBenefitItemsForSale(SalePOS,
                                                                       Enum::"NPR Benefit Items Collection"::All,
                                                                       TempNPRTotalDiscBenItemBuffer);

        CheckTotalDiscountBenefitItem(CurrNPRTotalDiscountBenefit,
                                      TempNPRTotalDiscBenItemBuffer);

        CheckTotalDiscountBenefitItemList(CurrNPRTotalDiscountBenefit,
                                          TempNPRTotalDiscBenItemBuffer);

    end;

    local procedure CheckTotalDiscountBenefitItem(CurrNPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
                                                  var TempNPRTotalDiscBenItemBuffer: Record "NPR Total Disc Ben Item Buffer" temporary)
    var
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";

    begin
        NPRTotalDiscountBenefit.Reset();
        NPRTotalDiscountBenefit.SetCurrentKey("Total Discount Code",
                                              "Step Amount",
                                              Type);

        NPRTotalDiscountBenefit.SetRange("Total Discount Code", CurrNPRTotalDiscountBenefit."Total Discount Code");
        NPRTotalDiscountBenefit.SetRange("Step Amount", CurrNPRTotalDiscountBenefit."Step Amount");
        NPRTotalDiscountBenefit.SetRange(Type, NPRTotalDiscountBenefit.Type::Item);

        NPRTotalDiscountBenefit.SetLoadFields("Total Discount Code",
                                              "Step Amount",
                                              "No.",
                                              "Variant Code",
                                              Quantity,
                                              Value,
                                              Type);

        if not NPRTotalDiscountBenefit.FindSet(false) then
            exit;

        repeat
            TempNPRTotalDiscBenItemBuffer.Reset();
            TempNPRTotalDiscBenItemBuffer.SetRange("Total Discount Code", NPRTotalDiscountBenefit."Total Discount Code");
            TempNPRTotalDiscBenItemBuffer.SetRange("Total Discount Step", NPRTotalDiscountBenefit."Step Amount");
            TempNPRTotalDiscBenItemBuffer.SetRange("Item No.", NPRTotalDiscountBenefit."No.");
            TempNPRTotalDiscBenItemBuffer.SetRange("Variant Code", NPRTotalDiscountBenefit."Variant Code");
            TempNPRTotalDiscBenItemBuffer.SetRange(Quantity, NPRTotalDiscountBenefit.Quantity);
            TempNPRTotalDiscBenItemBuffer.SetRange("Unit Price", NPRTotalDiscountBenefit.Value);
            Assert.IsTrue(not TempNPRTotalDiscBenItemBuffer.IsEmpty, 'Benefit Item not assigned to sale.');
        until NPRTotalDiscountBenefit.Next() = 0;
    end;

    local procedure CheckTotalDiscountBenefitItemList(CurrNPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
                                                      var TempNPRTotalDiscBenItemBuffer: Record "NPR Total Disc Ben Item Buffer" temporary)
    var
        NPRItemBenefitListLine: Record "NPR Item Benefit List Line";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
    begin

        NPRTotalDiscountBenefit.Reset();
        NPRTotalDiscountBenefit.SetCurrentKey("Total Discount Code",
                                              "Step Amount",
                                              Type);

        NPRTotalDiscountBenefit.SetRange("Total Discount Code", CurrNPRTotalDiscountBenefit."Total Discount Code");
        NPRTotalDiscountBenefit.SetRange("Step Amount", CurrNPRTotalDiscountBenefit."Step Amount");
        NPRTotalDiscountBenefit.SetRange(Type, NPRTotalDiscountBenefit.Type::"Item List");

        NPRTotalDiscountBenefit.SetLoadFields("Total Discount Code",
                                              "Step Amount",
                                              "No.",
                                              Type);

        if not NPRTotalDiscountBenefit.FindSet(false) then
            exit;

        repeat
            NPRItemBenefitListLine.Reset();
            NPRItemBenefitListLine.SetRange("List Code", NPRTotalDiscountBenefit."No.");

            NPRItemBenefitListLine.SetLoadFields("List Code",
                                                 "No.",
                                                 "Variant Code",
                                                 Quantity,
                                                 "Unit Price");

            if NPRItemBenefitListLine.FindSet(false) then
                repeat
                    TempNPRTotalDiscBenItemBuffer.Reset();
                    TempNPRTotalDiscBenItemBuffer.SetRange("Total Discount Code", NPRTotalDiscountBenefit."Total Discount Code");
                    TempNPRTotalDiscBenItemBuffer.SetRange("Total Discount Step", NPRTotalDiscountBenefit."Step Amount");
                    TempNPRTotalDiscBenItemBuffer.SetRange("Item No.", NPRItemBenefitListLine."No.");
                    TempNPRTotalDiscBenItemBuffer.SetRange("Variant Code", NPRItemBenefitListLine."Variant Code");
                    TempNPRTotalDiscBenItemBuffer.SetRange(Quantity, NPRItemBenefitListLine.Quantity);
                    TempNPRTotalDiscBenItemBuffer.SetRange("Unit Price", NPRItemBenefitListLine."Unit Price");
                    TempNPRTotalDiscBenItemBuffer.SetRange("Benefit List Code", NPRItemBenefitListLine."List Code");
                    Assert.IsTrue(not TempNPRTotalDiscBenItemBuffer.IsEmpty, 'Benefit Item not assigned to sale.');
                until NPRItemBenefitListLine.Next() = 0;

        until NPRTotalDiscountBenefit.Next() = 0;
    end;

    local procedure CheckTotalDiscountBenefitsWithMixedDiscount(SalePOS: Record "NPR POS Sale";
                                                                NPRTotalDiscountHeader: Record "NPR Total Discount Header";
                                                                NPRMixedDiscount: Record "NPR Mixed Discount";
                                                                VATPostingSetup: Record "VAT Posting Setup")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        Item: Record Item;
        NPRMixedDiscountLine: Record "NPR Mixed Discount Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDiscountCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
        AppliedAmount: Decimal;
        ItemUnitPrice: Decimal;
        TotalAmountIncludingVATWithoutTotalDiscount: Decimal;
        TotalDiscountAmount: Decimal;
        TotalDiscountPercentage: Decimal;
    begin
        AppliedAmount := 0;

        NPRMixedDiscountLine.Reset();
        NPRMixedDiscountLine.SetRange(Code, NPRMixedDiscount.Code);
        NPRMixedDiscountLine.SetRange("Disc. Grouping Type", NPRMixedDiscountLine."Disc. Grouping Type"::"Item Group");
        NPRMixedDiscountLine.FindFirst();

        NPRTotalDiscountBenefit.Reset();
        NPRTotalDiscountBenefit.SetRange("Total Discount Code", NPRTotalDiscountHeader.Code);
        if not NPRTotalDiscountBenefit.FindSet(false) then
            exit;

        repeat

            if VATPostingSetup."VAT %" <> 0 then
                ItemUnitPrice := (NPRTotalDiscountBenefit."Step Amount" - AppliedAmount) * (1 / (NPRMixedDiscount."Total Discount %" / 100)) / (1 + VATPostingSetup."VAT %" / 100)
            else
                ItemUnitPrice := (NPRTotalDiscountBenefit."Step Amount" - AppliedAmount) * (1 + NPRMixedDiscount."Total Discount %" / 100);

            // [GIVEN] Item with unit price        
            Clear(Item);
            CreateItem(Item,
                       VATPostingSetup."VAT Bus. Posting Group",
                       VATPostingSetup."VAT Prod. Posting Group",
                       '',
                       false);

            Item."Item Category Code" := NPRMixedDiscountLine."No.";
            Item."Unit Price" := ItemUnitPrice;
            Item.Modify();

            // [Given] POS Sale Line
            LibraryPOSMock.CreateItemLine(POSSession,
                                          Item."No.",
                                          1);

            POSSession.GetSaleLine(POSSaleLine);
            POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

            // [When] Total Pressed
            POSSalesDiscountCalcMgt.OnAfterTotalPressedPOS(SaleLinePOS);

            if not GeneralLedgerSetup.Get() then
                Clear(GeneralLedgerSetup);


            SaleLinePOS.Reset();
            SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
            SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
            SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
            SaleLinePOS.SetRange("Benefit Item", false);
            SaleLinePOS.CalcSums("Amount Including VAT",
                                 "Discount Amount",
                                 "Disc. Amt. Without Total Disc.",
                                 "Total Discount Amount");

            TotalDiscountAmount := SaleLinePOS."Total Discount Amount";
            TotalAmountIncludingVATWithoutTotalDiscount := SaleLinePOS."Amount Including VAT" + SaleLinePOS."Total Discount Amount";

            if SaleLinePOS.FindFirst() then;

            // [Then] Total Discount Level Should have been triggered and assigned tot he line
            Assert.IsTrue(SaleLinePOS."Discount Code" = NPRMixedDiscount.Code, 'Mixed Discount was not triggered but it should have been triggered.');
            Assert.IsTrue(SaleLinePOS."Total Discount Code" = NPRTotalDiscountBenefit."Total Discount Code", 'Total Discount was not triggered but it should have been triggered.');
            Assert.IsTrue(SaleLinePOS."Total Discount Step" = NPRTotalDiscountBenefit."Step Amount", 'The correct total discount amount step was not triggered');
            Assert.IsTrue(TotalAmountIncludingVATWithoutTotalDiscount >= NPRTotalDiscountBenefit."Step Amount", 'The POS Sale trigger amount is not correct');

            // [Then] Total Discount Discount should have been applied to the transaction
            case NPRTotalDiscountBenefit."Value Type" Of
                NPRTotalDiscountBenefit."Value Type"::Amount:
                    Assert.IsTrue(TotalDiscountAmount = NPRTotalDiscountBenefit.Value, 'Total Discount Amount is wrong.');

                NPRTotalDiscountBenefit."Value Type"::Percent:
                    begin
                        TotalDiscountPercentage := Round(TotalDiscountAmount / TotalAmountIncludingVATWithoutTotalDiscount, GeneralLedgerSetup."Amount Rounding Precision") * 100;
                        Assert.IsTrue(TotalDiscountPercentage = NPRTotalDiscountBenefit.Value, 'Discount Amount is not correct after total discount application.');
                    end;
            end;

            AppliedAmount := NPRTotalDiscountBenefit."Step Amount";
        until NPRTotalDiscountBenefit.Next() = 0;

    end;

    local procedure GetAmountToPay(POSSaleLine: Record "NPR POS Sale Line"): Decimal
    var
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTaxCalc: Codeunit "NPR POS Sale Tax Calc.";
        AmountToPay: Decimal;
    begin
        POSSaleTaxCalc.Find(POSSaleTax, POSSaleLine.SystemId);
        AmountToPay := POSSaleTax."Calculated Amount Incl. Tax";
        exit(AmountToPay);
    end;

    local procedure ChangeTotalDiscountDescription(var NPRTotalDiscountHeader: Record "NPR Total Discount Header";
                                                   NewDescription: Text[50])
    begin
        NPRTotalDiscountHeader.Description := NewDescription;
        NPRTotalDiscountHeader.Modify(true);
    end;

    local procedure ChangeTotalDiscountLineDescription(var NPRTotalDiscountLine: Record "NPR Total Discount Line";
                                                       NewDescription: Text[100])
    begin
        NPRTotalDiscountLine.Description := NewDescription;
        NPRTotalDiscountLine.Modify(true);
    end;

    local procedure ChangeTotalDiscountBenefitDescription(var NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
                                                           NewDescription: Text[100])
    begin
        NPRTotalDiscountBenefit.Description := NewDescription;
        NPRTotalDiscountBenefit.Modify(true);
    end;

    procedure InitializeData()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        SalesSetup: Record "Sales & Receivables Setup";
        LibraryERM: Codeunit "Library - ERM";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        //Clean any previous mock session
        POSSession.ClearAll();
        Clear(POSSession);

        if not Initialized then begin
            SalesSetup.Get();
            SalesSetup."Discount Posting" := SalesSetup."Discount Posting"::"Line Discounts";
            SalesSetup.Modify();
            LibraryERM.CreateVATBusinessPostingGroup(VATBusinessPostingGroup);
            LibraryPOSMasterData.CreatePOSSetup(POSSetup);
            LibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            POSPostingProfile."POS Period Register No. Series" := '';
            POSPostingProfile.Modify();
            LibraryPOSMasterData.CreatePOSStore(POSStore, POSPostingProfile.Code);
            LibraryPOSMasterData.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
            LibraryPOSMasterData.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);

            LibraryTaxCalc.CreateTaxSetup();
            LibraryTaxCalc.CreateTaxGroup(TaxGroup);

            CreateEmptyTaxPostingSetup();

            DeletePOSPostedEntries();
            DeleteDiscounts();

            Initialized := true;
        end;

        Commit();
    end;

    local procedure CreateEmptyTaxPostingSetup()
    var
        TaxPostingSetup: Record "VAT Posting Setup";
    begin
        //we need this to be able to post sale to G/L Entry for Automatic VAT Entry
        //with unknown VAT Amount. VAT Amount later will be posted from POS Entry Tax Lines
        if not TaxPostingSetup.get('', '') then begin
            TaxPostingSetup."VAT Bus. Posting Group" := '';
            TaxPostingSetup."VAT Prod. Posting Group" := '';
            TaxPostingSetup.Init();
            TaxPostingSetup.Insert();
        end;
        TaxPostingSetup."VAT Calculation Type" := TaxPostingSetup."VAT Calculation Type"::"Sales Tax";
        TaxPostingSetup."Tax Category" := 'E';
        TaxPostingSetup.Modify();
    end;

    local procedure DeletePOSPostedEntries()
    var
        GLEntry: Record "G/L Entry";
        POSEntry: Record "NPR POS Entry";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        VATEntry: Record "VAT Entry";
    begin
        //Just in case if performance test is created and run on test company for POS test unit
        //then POS posting is terminated because POS entries are stored in database with sales tickect no.
        //defined in the Library POS Master Data 
        POSEntry.DeleteAll();
        POSEntrySalesLine.DeleteAll();
        POSEntryPaymentLine.DeleteAll();
        POSEntryTaxLine.DeleteAll();
        VATEntry.DeleteAll();
        GLEntry.DeleteAll();
    end;

    local procedure DeleteDiscounts()
    begin
        DeleteTotalDiscounts();
        DeletePeriodicDiscounts();
        DeleteMixedDiscounts();
        DeleteQuantityDiscounts();
    end;

    local procedure DeleteTotalDiscounts()
    var
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
    begin
        NPRTotalDiscountHeader.Reset();
        if NPRTotalDiscountHeader.IsEmpty then
            exit;

        NPRTotalDiscountHeader.ModifyAll(Status, NPRTotalDiscountHeader.Status::Closed, true);
        NPRTotalDiscountHeader.DeleteAll(true);
    end;

    local procedure DeletePeriodicDiscounts()
    var
        NPRPeriodDiscount: Record "NPR Period Discount";
    begin
        NPRPeriodDiscount.Reset();
        if NPRPeriodDiscount.IsEmpty then
            exit;

        NPRPeriodDiscount.ModifyAll(Status, NPRPeriodDiscount.Status::Closed);
        NPRPeriodDiscount.DeleteAll(true);

    end;

    local procedure DeleteMixedDiscounts()
    var
        NPRMixedDiscount: Record "NPR Mixed Discount";
    begin
        NPRMixedDiscount.Reset();
        if NPRMixedDiscount.IsEmpty then
            exit;

        NPRMixedDiscount.ModifyAll(Status, NPRMixedDiscount.Status::Closed);
        NPRMixedDiscount.DeleteAll(true);

    end;

    local procedure DeleteQuantityDiscounts()
    var
        NPRQuantityDiscountHeader: Record "NPR Quantity Discount Header";
    begin
        NPRQuantityDiscountHeader.Reset();
        if NPRQuantityDiscountHeader.IsEmpty then
            exit;
        NPRQuantityDiscountHeader.ModifyAll(Status, NPRQuantityDiscountHeader.Status::Await);
        NPRQuantityDiscountHeader.DeleteAll(true);
    end;

    local procedure DeleteBenefitItemLists()
    var
        NPRItemBenefitListHeader: Record "NPR Item Benefit List Header";
    begin
        NPRItemBenefitListHeader.Reset();
        if not NPRItemBenefitListHeader.IsEmpty then
            NPRItemBenefitListHeader.DeleteAll(true);
    end;

    local procedure EnableDiscount(DiscounteFilter: Text)
    var
        DiscountPriority: Record "NPR Discount Priority";
        DiscountPriorityList: TestPage "NPR Discount Priority List";
    begin
        DiscountPriority.DeleteAll();

        DiscountPriorityList.OpenView();
        DiscountPriorityList.Close();
        DiscountPriority.ModifyAll(Disabled, true);

        DiscountPriority.SetFilter("Table ID", DiscounteFilter);
        DiscountPriority.ModifyAll(Disabled, false);
    end;

    local procedure CreateVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup"; TaxCaclType: Enum "NPR POS Tax Calc. Type")
    var
        VATProductPostingGroup: Record "VAT Product Posting Group";
        LibraryERM: Codeunit "Library - ERM";
        LibraryTaxCalc2: codeunit "NPR POS Lib. - Tax Calc.";
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

    local procedure AssignVATPostGroupToPOSSalesRoundingAcc(VATPostingSetup: Record "VAT Posting Setup")
    var
        LibraryPOSMasterData: codeunit "NPR Library - POS Master Data";
    begin
        LibraryPOSMasterData.AssignVATPostGroupToPOSSalesRoundingAcc(POSStore, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
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

    local procedure CreateTotalDiscountForAllWithWithOneStepDiscountPercent(var NPRTotalDiscountHeader: Record "NPR Total Discount Header";
                                                                            var NPRTotalDiscountLine: Record "NPR Total Discount Line";
                                                                            var NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
                                                                            var NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
                                                                            TotalDiscountStepAmount: Decimal;
                                                                            TotalDiscountPercent: Decimal)

    begin
        CreateTotalDiscountHeader(NPRTotalDiscountHeader,
                                  '',
                                  Enum::"NPR Total Discount Amount Calc"::"Discount Filters",
                                  Enum::"NPR Total Discount Application"::"Discount Filters",
                                  0);

        CreateTotalDiscountLine(NPRTotalDiscountHeader,
                                Enum::"NPR Total Discount Line Type"::All,
                                '',
                                '',
                                NPRTotalDiscountLine);

        CreateTotalDiscountBenefits(NPRTotalDiscountHeader,
                                    TotalDiscountStepAmount,
                                    Enum::"NPR Total Disc. Benefit Type"::Discount,
                                    '',
                                    '',
                                    0,
                                    Enum::"NPR Total Disc Ben Value Type"::Percent,
                                    TotalDiscountPercent,
                                    false,
                                    NPRTotalDiscountBenefit);

        CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader,
                                              0T,
                                              0T,
                                              NPRTotalDiscTimeInterv);

        NPRTotalDiscountHeader.Status := NPRTotalDiscountHeader.Status::Active;
        NPRTotalDiscountHeader.Modify();

    end;

    local procedure CreateTotalDiscountHeader(var TotalDiscountHeader: Record "NPR Total Discount Header";
                                              CustomerDiscountGroupFilter: Text[250];
                                              NPRTotalDiscountAmountCalc: Enum "NPR Total Discount Amount Calc";
                                              NPRTotalDiscountApplication: Enum "NPR Total Discount Application";
                                              Priority: Integer)
    var
        LibraryUtility: Codeunit "Library - Utility";
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin

        TotalDiscountHeader.Init();
        TotalDiscountHeader.Code := LibraryUtility.GenerateRandomCode(TotalDiscountHeader.FieldNo(Code), NPRTotalDiscountManagement.DiscSourceTableId());
        TotalDiscountHeader.Status := TotalDiscountHeader.Status::Pending;
        TotalDiscountHeader."Starting date" := Today() - 7;
        TotalDiscountHeader."Ending date" := Today() + 7;
        TotalDiscountHeader.Priority := Priority;
        TotalDiscountHeader."Customer Disc. Group Filter" := CustomerDiscountGroupFilter;
        TotalDiscountHeader."Step Amount Calculation" := NPRTotalDiscountAmountCalc;
        TotalDiscountHeader."Discount Application" := NPRTotalDiscountApplication;
        TotalDiscountHeader.Insert(true);
    end;

    local procedure CreateTotalDiscountLine(NPRTotalDiscountHeader: Record "NPR Total Discount Header";
                                            NPRTotalDiscountLineType: Enum "NPR Total Discount Line Type";
                                                                          No: Code[20];
                                                                          VariantCode: Code[10];
                                            var NPRTotalDiscountLine: Record "NPR Total Discount Line")
    var
        NPRTotalDiscHeaderUtils: Codeunit "NPR Total Disc. Header Utils";
    begin
        NPRTotalDiscountLine.Init();
        NPRTotalDiscountLine."Total Discount Code" := NPRTotalDiscountHeader.Code;
        NPRTotalDiscountLine."Line No." := NPRTotalDiscHeaderUtils.GetLastTotalDiscountLineLineNo(NPRTotalDiscountHeader) + 10000;
        NPRTotalDiscountLine.Type := NPRTotalDiscountLineType;

        if No <> '' then
            NPRTotalDiscountLine.Validate("No.", No);

        if VariantCode <> '' then
            NPRTotalDiscountLine.Validate("Variant Code", VariantCode);

        NPRTotalDiscountLine.Insert(true);
    end;

    local procedure CreateTotalDiscountBenefits(NPRTotalDiscountHeader: Record "NPR Total Discount Header";
                                               StepAmount: Decimal;
                                               NPRTotalDiscBenefitType: Enum "NPR Total Disc. Benefit Type";
                                               No: Code[20];
                                               VariantCode: Code[10];
                                               Quantity: Decimal;
                                               NPRTotalDiscBenValueType: Enum "NPR Total Disc Ben Value Type";
                                               TotalDiscountValue: Decimal;
                                               NoInputNeeded: Boolean;
                                               var NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit")
    var
        NPRTotalDiscHeaderUtils: Codeunit "NPR Total Disc. Header Utils";
    begin
        NPRTotalDiscountBenefit.Init();
        NPRTotalDiscountBenefit."Total Discount Code" := NPRTotalDiscountHeader.Code;
        NPRTotalDiscountBenefit."Line No." := NPRTotalDiscHeaderUtils.GetLastTotalDiscountBenefitLineNo(NPRTotalDiscountHeader) + 10000;
        NPRTotalDiscountBenefit."Step Amount" := StepAmount;
        NPRTotalDiscountBenefit.Type := NPRTotalDiscBenefitType;
        if No <> '' then
            NPRTotalDiscountBenefit.Validate("No.", No);

        if VariantCode <> '' then
            NPRTotalDiscountBenefit.Validate("Variant Code", VariantCode);

        if NPRTotalDiscBenefitType = NPRTotalDiscBenefitType::Item then
            NPRTotalDiscountBenefit.Validate(Quantity, Quantity);

        NPRTotalDiscountBenefit."No Input Needed" := NoInputNeeded;
        NPRTotalDiscountBenefit.Validate("Value Type", NPRTotalDiscBenValueType);
        NPRTotalDiscountBenefit.Validate(Value, TotalDiscountValue);
        NPRTotalDiscountBenefit.Insert(true);

    end;

    local procedure CreateTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader: Record "NPR Total Discount Header";
                                                          StartTime: Time;
                                                          EndTime: Time;
                                                          var NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.")
    var
        NPRTotalDiscHeaderUtils: Codeunit "NPR Total Disc. Header Utils";
    begin
        NPRTotalDiscTimeInterv.Init();
        NPRTotalDiscTimeInterv."Total Discount Code" := NPRTotalDiscountHeader.Code;
        NPRTotalDiscTimeInterv."Period Type" := NPRTotalDiscTimeInterv."Period Type"::"Every Day";
        NPRTotalDiscTimeInterv."Start Time" := StartTime;
        NPRTotalDiscTimeInterv."End Time" := EndTime;
        NPRTotalDiscTimeInterv."Line No." := NPRTotalDiscHeaderUtils.GetLastLineNoTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader) + 10000;
        NPRTotalDiscTimeInterv.Insert(true);
    end;


    local procedure CreateMixedDiscount(var MixedDiscount: Record "NPR Mixed Discount";
                                        var NPRMixedDiscountLine: Record "NPR Mixed Discount Line";
                                        ItemCategory: Record "Item Category";
                                        DiscountPercent: Decimal)
    begin
        CreateMixedDiscountHeader(MixedDiscount,
                                  DiscountPercent);

        CreateMixedDiscountLine(MixedDiscount,
                                ItemCategory,
                                NPRMixedDiscountLine);
    end;

    local procedure CreateMixedDiscountHeader(var MixedDiscount: Record "NPR Mixed Discount";
                                              DiscountPercent: Decimal): Decimal
    var
        LibraryUtility: Codeunit "Library - Utility";
        NPRMixedDiscountManagement: Codeunit "NPR Mixed Discount Management";
    begin
        MixedDiscount.Code := LibraryUtility.GenerateRandomCode(MixedDiscount.FieldNo(Code), NPRMixedDiscountManagement.DiscSourceTableId());
        MixedDiscount.Init();
        MixedDiscount.Status := MixedDiscount.Status::Active;
        MixedDiscount."Starting date" := Today() - 7;
        MixedDiscount."Ending date" := Today() + 7;
        MixedDiscount."Discount Type" := MixedDiscount."Discount Type"::"Total Discount %";
        MixedDiscount."Total Discount %" := DiscountPercent;
        MixedDiscount."Min. Quantity" := 1;
        MixedDiscount.Insert();
    end;

    local procedure CreateMixedDiscountLine(MixedDiscount: Record "NPR Mixed Discount";
                                            ItemCategory: Record "Item Category";
                                            var MixedDiscountLine: Record "NPR Mixed Discount Line")
    begin
        MixedDiscountLine.Code := MixedDiscount.Code;
        MixedDiscountLine."Disc. Grouping Type" := MixedDiscountLine."Disc. Grouping Type"::"Item Group";
        MixedDiscountLine."No." := ItemCategory.Code;
        MixedDiscountLine."Variant Code" := '';
        MixedDiscountLine.Init();
        MixedDiscountLine.Status := MixedDiscount.Status;
        MixedDiscountLine."Starting date" := MixedDiscount."Starting date";
        MixedDiscountLine."Ending Date" := MixedDiscount."Ending date";
        MixedDiscountLine.Insert();
    end;

    local procedure CreateBenefitItemList(NoSeries: Record "No. Series";
                                          VATPostingSetup: Record "VAT Posting Setup";
                                          var NPRItemBenefitListHeader: Record "NPR Item Benefit List Header")
    var
        Item: Record Item;
        NPRItemBenefitListLine: Record "NPR Item Benefit List Line";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        NPRItemBenefListHeadUtils: Codeunit "NPR Item Benef List Head Utils";
    begin
        NPRItemBenefitListHeader.Init();
        NPRItemBenefitListHeader.Code := NoSeriesManagement.GetNextNo(NoSeries.Code,
                                                                      Today,
                                                                      true);
        NPRItemBenefitListHeader.Insert(true);

        CreateItem(Item,
                   VATPostingSetup."VAT Bus. Posting Group",
                   VATPostingSetup."VAT Prod. Posting Group",
                   '',
                   false);


        NPRItemBenefitListLine.Init();
        NPRItemBenefitListLine."List Code" := NPRItemBenefitListHeader.Code;
        NPRItemBenefitListLine."Line No." += NPRItemBenefListHeadUtils.GetBenefitItemListLinesLastLineNo(NPRItemBenefitListHeader) + 10000;
        NPRItemBenefitListLine."No." := Item."No.";
        NPRItemBenefitListLine.Quantity := 1;
        NPRItemBenefitListLine.Insert(true);
    end;

    procedure CreateNumberSeries(var NoSeries: Record "No. Series")
    var
        NoSeriesLine: Record "No. Series Line";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        LibraryUtility.CreateNoSeries(NoSeries, true, false, false);
        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, 'TEST_1', 'TEST_99999999');
    end;

    local procedure CreateGeneralPostingSetupForItem(Item: Record Item)
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        LibraryPOSMasterData: codeunit "NPR Library - POS Master Data";
    begin
        POSStore.GetProfile(POSPostingProfile);
        LibraryPOSMasterData.CreateGeneralPostingSetupForSaleItem(POSPostingProfile."Gen. Bus. Posting Group",
                                                                  Item."Gen. Prod. Posting Group",
                                                                  POSStore."Location Code",
                                                                  Item."Inventory Posting Group");
    end;


}