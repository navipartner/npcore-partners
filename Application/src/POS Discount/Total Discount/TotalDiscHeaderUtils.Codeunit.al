codeunit 6151079 "NPR Total Disc. Header Utils"
{
    Access = Internal;

    internal procedure DeleteRelatedRecord(NPRTotalDiscountHeader: Record "NPR Total Discount Header")
    var
        DimensionManagement: Codeunit DimensionManagement;
    begin
        DeleteDiscountLines(NPRTotalDiscountHeader);
        DeleteTotalBenefits(NPRTotalDiscountHeader);
        DeleteTotalDiscountTimeInterval(NPRTotalDiscountHeader);
        DimensionManagement.DeleteDefaultDim(DATABASE::"NPR Total Discount Header", NPRTotalDiscountHeader.Code);
    end;

    local procedure DeleteDiscountLines(NPRTotalDiscountHeader: Record "NPR Total Discount Header")
    var
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
    begin
        NPRTotalDiscountLine.Reset();
        NPRTotalDiscountLine.SetRange("Total Discount Code", NPRTotalDiscountHeader.Code);
        if not NPRTotalDiscountLine.IsEmpty then
            NPRTotalDiscountLine.DeleteAll(true);
    end;

    local procedure DeleteTotalBenefits(NPRTotalDiscountHeader: Record "NPR Total Discount Header")
    var
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
    begin
        NPRTotalDiscountBenefit.Reset();
        NPRTotalDiscountBenefit.SetRange("Total Discount Code", NPRTotalDiscountHeader.Code);
        if not NPRTotalDiscountBenefit.IsEmpty then
            NPRTotalDiscountBenefit.DeleteAll(true);
    end;

    local procedure DeleteTotalDiscountTimeInterval(NPRTotalDiscountHeader: Record "NPR Total Discount Header")
    var
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
    begin
        NPRTotalDiscTimeInterv.Reset();
        NPRTotalDiscTimeInterv.SetRange("Total Discount Code", NPRTotalDiscountHeader.Code);
        if not NPRTotalDiscTimeInterv.IsEmpty then
            NPRTotalDiscTimeInterv.DeleteAll(true);
    end;

    internal procedure UpdatePeriodDates(var NPRTotalDiscountHeader: Record "NPR Total Discount Header")
    var
        DatePeriod: Record Date;
    begin
        NPRTotalDiscountHeader."Starting date" := Today();


        DatePeriod.SetRange("Period Type", DatePeriod."Period Type"::Date);
        if not DatePeriod.FindLast() then
            exit;

        NPRTotalDiscountHeader."Ending date" := DatePeriod."Period Start";
    end;

    internal procedure CheckEndingDate(NPRTotalDiscountHeader: Record "NPR Total Discount Header")
    var
        InvalidClosingDateErrorLbl: Label 'Invalid Closing Date';
    begin
        if NPRTotalDiscountHeader."Starting date" = 0D then
            exit;

        if NPRTotalDiscountHeader."Ending date" < NPRTotalDiscountHeader."Starting date" then
            Error(InvalidClosingDateErrorLbl);
    end;

    internal procedure CheckStartingDate(NPRTotalDiscountHeader: Record "NPR Total Discount Header")
    var
        InvalidStartingDateErrorLbl: Label 'Invalid Starting Date';
    begin
        if NPRTotalDiscountHeader."Ending date" = 0D then
            exit;

        if NPRTotalDiscountHeader."Ending date" < NPRTotalDiscountHeader."Starting date" then
            Error(InvalidStartingDateErrorLbl);
    end;

    local procedure TestTotalDiscountDates(NPRTotalDiscountHeader: Record "NPR Total Discount Header")
    begin
        if NPRTotalDiscountHeader.Status <> NPRTotalDiscountHeader.Status::Active then
            exit;

        NPRTotalDiscountHeader.TestField("Starting date");
        NPRTotalDiscountHeader.TestField("Ending date");
    end;

    internal procedure UpdateLines(var NPRTotalDiscountHeader: Record "NPR Total Discount Header")
    begin
        UpdateTotalDiscountLines(NPRTotalDiscountHeader);
        UpdateTotalDiscountBenefits(NPRTotalDiscountHeader);
    end;

    local procedure UpdateTotalDiscountLines(var NPRTotalDiscountHeader: Record "NPR Total Discount Header")
    var
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
    begin
        if NPRTotalDiscountHeader.IsTemporary then
            exit;

        NPRTotalDiscountLine.SetRange("Total Discount Code", NPRTotalDiscountHeader.Code);
        if not NPRTotalDiscountLine.FindSet() then
            exit;

        repeat
            NPRTotalDiscountLine."Starting Date" := NPRTotalDiscountHeader."Starting date";
            NPRTotalDiscountLine."Ending Date" := NPRTotalDiscountHeader."Ending date";
            NPRTotalDiscountLine.Status := NPRTotalDiscountHeader.Status;
            NPRTotalDiscountLine."Starting Time" := NPRTotalDiscountHeader."Starting time";
            NPRTotalDiscountLine."Ending Time" := NPRTotalDiscountHeader."Ending time";
            NPRTotalDiscountLine.Modify();
        until NPRTotalDiscountLine.Next() = 0;
    end;

    local procedure UpdateTotalDiscountBenefits(var NPRTotalDiscountHeader: Record "NPR Total Discount Header")
    var
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
    begin
        if NPRTotalDiscountHeader.IsTemporary then
            exit;

        NPRTotalDiscountBenefit.Reset();
        NPRTotalDiscountBenefit.SetRange("Total Discount Code", NPRTotalDiscountHeader.Code);
        if NPRTotalDiscountBenefit.IsEmpty then
            exit;

        NPRTotalDiscountBenefit.ModifyAll(Status, NPRTotalDiscountHeader.Status);
    end;

    internal procedure ValidateShortcutDimCode(TotalDiscountCode: Code[20];
                                               FieldNumber: Integer;
                                               var ShortcutDimCode: Code[20])
    var
        DimensionManagement: Codeunit DimensionManagement;
    begin
        DimensionManagement.ValidateDimValueCode(FieldNumber,
                                                 ShortcutDimCode);

        DimensionManagement.SaveDefaultDim(DATABASE::"NPR Total Discount Header",
                                           TotalDiscountCode,
                                           FieldNumber,
                                           ShortcutDimCode);
    end;


    internal procedure AssitedEdit(var CurrNPRTotalDiscountHeader: Record "NPR Total Discount Header") Assited: Boolean
    var
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesMgt: Codeunit "No. Series";
#ELSE
        NoSeriesMgt: Codeunit NoSeriesManagement;
#ENDIF
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        NPRTotalDiscountHeader := CurrNPRTotalDiscountHeader;
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        if not NoSeriesMgt.LookupRelatedNoSeries(NPRTotalDiscountManagement.GetNoSeries(),
                                        CurrNPRTotalDiscountHeader."No. Serie",
                                        NPRTotalDiscountHeader."No. Serie")
#ELSE
        if not NoSeriesMgt.SelectSeries(NPRTotalDiscountManagement.GetNoSeries(),
                                        CurrNPRTotalDiscountHeader."No. Serie",
                                        NPRTotalDiscountHeader."No. Serie")
#ENDIF
        then
            exit;
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NPRTotalDiscountHeader.Code := NoSeriesMgt.GetNextNo(NPRTotalDiscountHeader."No. Serie");
#ELSE
        NoSeriesMgt.SetSeries(NPRTotalDiscountHeader.Code);
#ENDIF
        CurrNPRTotalDiscountHeader := NPRTotalDiscountHeader;
        Assited := true;
    end;

    internal procedure InitNoSeries(var NPRTotalDiscountHeader: Record "NPR Total Discount Header";
                                    var xNPRTotalDiscountHeader: Record "NPR Total Discount Header")
    var
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesManagement: Codeunit "No. Series";
        NoSeries: Code[20];
#ELSE
        NoSeriesManagement: Codeunit NoSeriesManagement;
#ENDIF
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        if NPRTotalDiscountHeader.Code <> '' then
            exit;

#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeries := NPRTotalDiscountManagement.GetNoSeries();
        NPRTotalDiscountHeader."No. Serie" := NoSeries;
        if NoSeriesManagement.AreRelated(NoSeries, xNPRTotalDiscountHeader."No. Serie") then
            NPRTotalDiscountHeader."No. Serie" := xNPRTotalDiscountHeader."No. Serie";
        NPRTotalDiscountHeader.Code := NoSeriesManagement.GetNextNo(NPRTotalDiscountHeader."No. Serie");
#ELSE
        NoSeriesManagement.InitSeries(NPRTotalDiscountManagement.GetNoSeries(),
                                      xNPRTotalDiscountHeader."No. Serie",
                                      0D,
                                      NPRTotalDiscountHeader.Code,
                                      NPRTotalDiscountHeader."No. Serie");
#ENDIF
    end;

    internal procedure CheckIfTotalDiscountEditable(NPRTotalDiscountHeader: Record "NPR Total Discount Header")
    var
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        CurrErrorInfo: ErrorInfo;
        OpenActionLbl: Label 'Open Total Discount';
#endif
        StatusErrorLbl: Label 'Total Discount %1 must be set to pending before editing.', Comment = '%1 - Status';

    begin
        if NPRTotalDiscountHeader.Status <> NPRTotalDiscountHeader.Status::Active then
            exit;
#if (BC17 or BC18 or BC19 or BC20 or BC21)
        Error(StatusErrorLbl,
            NPRTotalDiscountHeader.Code);
#else
        CurrErrorInfo.Message(StrSubstNo(StatusErrorLbl,
                                         NPRTotalDiscountHeader.Code));

        CurrErrorInfo.SystemId := NPRTotalDiscountHeader.SystemId;
        CurrErrorInfo.AddAction(OpenActionLbl,
                                Codeunit::"NPR Total Disc. Header Utils",
                                'OpenTotalDiscount');
        Error(CurrErrorInfo);
#endif    
    end;

    local procedure TransferItemSelectionToTotalDiscount(NPRTotalDiscountHeader: Record "NPR Total Discount Header";
                                                         var Item: Record Item;
                                                         ShowDialog: Boolean)
    var
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        ItemExistsErrorLbl: Label 'Item No. %1 already exists in Total Discount %2.', Comment = '%1 - Item No. %2 - Total Discount Code';
        ItemTransferLbl: Label '%1 Item(s) has been transferred to Total Discount No. %2', Comment = '%1 - Item Count, %2 - Total Discount Code';
    begin
        Item.SetLoadFields("No.", Description);
        if not Item.FindSet() then
            exit;

        repeat
            if NPRTotalDiscountLine.Get(NPRTotalDiscountHeader.Code,
                                        NPRTotalDiscountLine.Type::Item,
                                        Item."No.",
                                        '')
            then
                Error(ItemExistsErrorLbl,
                      Item."No.",
                      NPRTotalDiscountHeader.Code);

            NPRTotalDiscountLine.Init();
            NPRTotalDiscountLine."Total Discount Code" := NPRTotalDiscountHeader.Code;
            NPRTotalDiscountLine."No." := Item."No.";
            NPRTotalDiscountLine."Type" := NPRTotalDiscountLine."Type"::Item;
            NPRTotalDiscountLine.Description := Item.Description;
            NPRTotalDiscountLine.Status := NPRTotalDiscountHeader.Status;
            NPRTotalDiscountLine.Insert();

        until Item.Next() = 0;

        if ShowDialog and
           GuiAllowed
        then
            Message(ItemTransferLbl,
                    Item.Count,
                    NPRTotalDiscountHeader.Code);
    end;

    internal procedure SelectItemAndTransferToTotalDiscount(NPRTotalDiscountHeader: Record "NPR Total Discount Header")
    var
        Item: Record Item;
        ItemList: Page "Item List";

    begin
        Clear(Item);
        Clear(ItemList);
        ItemList.LookupMode(true);
        if ItemList.RunModal() <> Action::LookupOK then
            exit;

        ItemList.SetSelection(Item);
        TransferItemSelectionToTotalDiscount(NPRTotalDiscountHeader,
                                             Item,
                                             true);
    end;

    internal procedure SelectCategoryAndTransferToTotalDiscount(NPRTotalDiscountHeader: Record "NPR Total Discount Header")
    var
        Item: Record Item;
        ItemCategory: Record "Item Category";
    begin
        Clear(ItemCategory);
        if Page.RunModal(0, ItemCategory) <> Action::LookupOK then
            exit;

        Clear(Item);
        Item.SetRange("Item Category Code", ItemCategory.Code);
        TransferItemSelectionToTotalDiscount(NPRTotalDiscountHeader,
                                             Item,
                                             true);
    end;

    internal procedure SelectVendorAndTransferToTotalDiscount(NPRTotalDiscountHeader: Record "NPR Total Discount Header")
    var
        Item: Record Item;
        Vendor: Record Vendor;
    begin
        Clear(Vendor);
        if Page.RunModal(0, Vendor) <> Action::LookupOK then
            exit;

        Clear(Item);
        Item.SetRange("Vendor No.", Vendor."No.");
        TransferItemSelectionToTotalDiscount(NPRTotalDiscountHeader,
                                            Item,
                                            true);
    end;


    internal procedure CopyTotalDiscountLinesToCurrent(CurrNPRTotalDiscountHeader: Record "NPR Total Discount Header")
    var
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NewNPRTotalDiscountLine: Record "NPR Total Discount Line";
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
    begin
        NPRTotalDiscountHeader.Reset();
        NPRTotalDiscountHeader.SetFilter(Code, '<>%1', CurrNPRTotalDiscountHeader.Code);
        if Page.RunModal(0, NPRTotalDiscountHeader) <> Action::LookupOK then
            exit;

        NPRTotalDiscountLine.SetRange("Total Discount Code", NPRTotalDiscountHeader.Code);
        if not NPRTotalDiscountLine.IsEmpty then
            NPRTotalDiscountLine.DeleteAll();

        NPRTotalDiscountLine.Reset();
        NPRTotalDiscountLine.SetRange("Total Discount Code", NPRTotalDiscountHeader.Code);
        if NPRTotalDiscountLine.FindSet() then
            repeat
                NewNPRTotalDiscountLine.Init();
                NewNPRTotalDiscountLine.TransferFields(NPRTotalDiscountLine);
                NewNPRTotalDiscountLine."Total Discount Code" := NPRTotalDiscountHeader.Code;
                NewNPRTotalDiscountLine.Insert(true);
            until NewNPRTotalDiscountLine.Next() = 0;
    end;

    local procedure CheckDiscountLinesExist(NPRTotalDiscountHeader: Record "NPR Total Discount Header")
    var
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        NoFiltersDefinedErrorLbl: Label 'No filters defined for total discount %1 - %2.', Comment = '%1 - Total Discount Code, %2 - Total Discount Description';
    begin
        if NPRTotalDiscountHeader.Status <> NPRTotalDiscountHeader.Status::Active then
            exit;

        if (NPRTotalDiscountHeader."Discount Application" = NPRTotalDiscountHeader."Discount Application"::"No Filters") and
           (NPRTotalDiscountHeader."Step Amount Calculation" = NPRTotalDiscountHeader."Step Amount Calculation"::"No Filters")
        then
            exit;

        NPRTotalDiscountLine.Reset();
        NPRTotalDiscountLine.SetRange("Total Discount Code", NPRTotalDiscountHeader.Code);
        if NPRTotalDiscountLine.FindFirst() then
            exit;

        Error(NoFiltersDefinedErrorLbl,
              NPRTotalDiscountHeader.Code,
              NPRTotalDiscountHeader.Description);
    end;

    local procedure CheckDiscountLinesWithoutNoExist(NPRTotalDiscountHeader: Record "NPR Total Discount Header")
    var
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
        EmptyNoErrorLbl: Label 'The No. field must be populated in total discount filter: %1 - %2.', Comment = '%1 - Total Discount Code, %2 - Total Discount Line';
    begin
        if NPRTotalDiscountHeader.Status <> NPRTotalDiscountHeader.Status::Active then
            exit;

        NPRTotalDiscountLine.Reset();
        NPRTotalDiscountLine.SetRange("Total Discount Code", NPRTotalDiscountHeader.Code);
        NPRTotalDiscountLine.SetFilter(Type, '<>%1', NPRTotalDiscountLine.Type::All);
        NPRTotalDiscountLine.SetRange("No.", '');
        if not NPRTotalDiscountLine.FindFirst() then
            exit;

        Error(EmptyNoErrorLbl,
              NPRTotalDiscountLine."Total Discount Code",
              NPRTotalDiscountLine."Line No.");
    end;

    local procedure CheckTotalDiscountBenefits(NPRTotalDiscountHeader: Record "NPR Total Discount Header")
    var
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
    begin
        if NPRTotalDiscountHeader.Status <> NPRTotalDiscountHeader.Status::Active then
            exit;

        NPRTotalDiscountBenefit.Reset();
        NPRTotalDiscountBenefit.SetRange("Total Discount Code", NPRTotalDiscountHeader.Code);
        NPRTotalDiscountBenefit.FindFirst();
    end;

    internal procedure TestStatus(NPRTotalDiscountHeader: Record "NPR Total Discount Header")
    begin
        if NPRTotalDiscountHeader.Status <> NPRTotalDiscountHeader.Status::Active then
            exit;

        CheckDiscountLinesExist(NPRTotalDiscountHeader);
        CheckDiscountLinesWithoutNoExist(NPRTotalDiscountHeader);
        CheckTotalDiscountBenefits(NPRTotalDiscountHeader);
        TestTotalDiscountDates(NPRTotalDiscountHeader);
        CheckDiscountPriority(NPRTotalDiscountHeader);
        CheckTotalDiscountBenefitsQuantity(NPRTotalDiscountHeader);
        CheckTotalDisocountBenefitsNoPopulated(NPRTotalDiscountHeader);
    end;

    internal procedure UpdateCustDiscountFilter(var NPRTotalDiscountHeader: Record "NPR Total Discount Header")
    var
        CustomerDiscountGroup: Record "Customer Discount Group";
    begin
        NPRTotalDiscountHeader."Customer Disc. Group Filter" := UpperCase(NPRTotalDiscountHeader."Customer Disc. Group Filter");
        CustomerDiscountGroup.SetFilter(Code, NPRTotalDiscountHeader."Customer Disc. Group Filter");
        NPRTotalDiscountHeader."Customer Disc. Group Filter" := CopyStr(CustomerDiscountGroup.GetFilter(Code), 1, MaxStrLen(NPRTotalDiscountHeader."Customer Disc. Group Filter"));
    end;

    internal procedure GetLastTotalDiscountLineLineNo(NPRTotalDiscountHeader: Record "NPR Total Discount Header") LastLineNo: Integer
    var
        NPRTotalDiscountLine: Record "NPR Total Discount Line";
    begin
        NPRTotalDiscountLine.Reset();
        NPRTotalDiscountLine.SetRange("Total Discount Code", NPRTotalDiscountHeader.Code);
        if not NPRTotalDiscountLine.FindLast() then
            exit;

        LastlineNo := NPRTotalDiscountLine."Line No."
    end;

    internal procedure GetLastTotalDiscountBenefitLineNo(NPRTotalDiscountHeader: Record "NPR Total Discount Header") LastLineNo: Integer
    var
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
    begin
        NPRTotalDiscountBenefit.Reset();
        NPRTotalDiscountBenefit.SetRange("Total Discount Code", NPRTotalDiscountHeader.Code);
        if not NPRTotalDiscountBenefit.FindLast() then
            exit;

        LastLineNo := NPRTotalDiscountBenefit."Line No.";
    end;

    internal procedure GetLastLineNoTotalDiscountActiveTimeInterval(NPRTotalDiscountHeader: Record "NPR Total Discount Header") LastLineNo: Integer
    var
        NPRTotalDiscTimeInterv: Record "NPR Total Disc. Time Interv.";
    begin
        NPRTotalDiscTimeInterv.Reset();
        NPRTotalDiscTimeInterv.SetRange("Total Discount Code", NPRTotalDiscountHeader.Code);
        if not NPRTotalDiscTimeInterv.FindLast() then
            exit;

        LastLineNo := NPRTotalDiscTimeInterv."Line No.";
    end;
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    internal procedure OpenTotalDiscount(CurrErrorInfo: ErrorInfo)
    var
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
    begin
        if IsNullGuid(CurrErrorInfo.SystemId) then
            exit;

        if not NPRTotalDiscountHeader.GetBySystemId(CurrErrorInfo.SystemId) then
            exit;

        NPRTotalDiscountHeader.Validate(Status, NPRTotalDiscountHeader.Status::Pending);
        NPRTotalDiscountHeader.Modify(true);
    end;
#endif

    internal procedure CheckDiscountPriority(CurrNPRTotalDiscountHeader: Record "NPR Total Discount Header")
    var
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        PriorityErorLbl: Label 'Total Discount %1 - %2 has the same priority as the the current total discount %3 - %4.', Comment = '%1 - Discount ';
    begin
        NPRTotalDiscountHeader.Reset();
        NPRTotalDiscountHeader.SetCurrentKey(Status, Priority);
        NPRTotalDiscountHeader.SetRange(Status, NPRTotalDiscountHeader.Status::Active);
        NPRTotalDiscountHeader.SetRange(Priority, CurrNPRTotalDiscountHeader.Priority);
        if not NPRTotalDiscountHeader.FindFirst() then
            exit;

        Error(PriorityErorLbl,
              NPRTotalDiscountHeader.Code,
              NPRTotalDiscountHeader.Description,
              CurrNPRTotalDiscountHeader.Code,
              CurrNPRTotalDiscountHeader.Description);
    end;

    internal procedure CheckTotalDiscountBenefitsQuantity(CurrNPRTotalDiscountHeader: Record "NPR Total Discount Header")
    begin
        CheckTotalDiscountBenefitItemsQuantity(CurrNPRTotalDiscountHeader);
        CheckTotalDiscountBenefitItemListsQuantity(CurrNPRTotalDiscountHeader);
    end;

    local procedure CheckTotalDisocountBenefitsNoPopulated(NPRTotalDiscountHeader: Record "NPR Total Discount Header")
    var
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        EmptyNoErrorLbl: Label 'The No. field in the total discount benefits for total discount code: %1, step amount: %2 has to be populated.', Comment = '%1 - total discount code, %2 - step amount ';
    begin
        NPRTotalDiscountBenefit.Reset();
        NPRTotalDiscountBenefit.SetRange("Total Discount Code", NPRTotalDiscountHeader.Code);
        NPRTotalDiscountBenefit.SetFilter(Type, '%1|%2', NPRTotalDiscountBenefit.Type::Item, NPRTotalDiscountBenefit.Type::"Item List");
        NPRTotalDiscountBenefit.SetRange("No.", '');
        if not NPRTotalDiscountBenefit.FindFirst() then
            exit;
        Error(EmptyNoErrorLbl,
              NPRTotalDiscountBenefit."Total Discount Code",
              NPRTotalDiscountBenefit."Step Amount");
    end;

    local procedure CheckTotalDiscountBenefitItemsQuantity(CurrNPRTotalDiscountHeader: Record "NPR Total Discount Header")
    var
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        BenefitItemQtyErrorLbl: Label 'Item no.: %1 variant code: %2 for total discount code: %3, step amount: %4 has to have quantity.', Comment = '%1 - Item No, %2 - Variant Code %3 - total discount code, %3 - step amount ';
    begin
        NPRTotalDiscountBenefit.Reset();
        NPRTotalDiscountBenefit.SetRange("Total Discount Code", CurrNPRTotalDiscountHeader.Code);
        NPRTotalDiscountBenefit.SetRange(Type, NPRTotalDiscountBenefit.Type::Item);
        NPRTotalDiscountBenefit.SetRange(Quantity, 0);
        if not NPRTotalDiscountBenefit.FindFirst() then
            exit;

        Error(BenefitItemQtyErrorLbl,
              NPRTotalDiscountBenefit."No.",
              NPRTotalDiscountBenefit."Variant Code",
              NPRTotalDiscountBenefit."Total Discount Code",
              NPRTotalDiscountBenefit."Step Amount");
    end;

    local procedure CheckTotalDiscountBenefitItemListsQuantity(CurrNPRTotalDiscountHeader: Record "NPR Total Discount Header")
    var
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        NPRTotalDiscBenefitUtils: Codeunit "NPR Total Disc Benefit Utils";
    begin
        NPRTotalDiscountBenefit.Reset();
        NPRTotalDiscountBenefit.SetRange("Total Discount Code", CurrNPRTotalDiscountHeader.Code);
        NPRTotalDiscountBenefit.SetRange(Type, NPRTotalDiscountBenefit.Type::"Item List");

        NPRTotalDiscountBenefit.SetLoadFields(Type, "No.", "Step Amount");
        if not NPRTotalDiscountBenefit.FindSet(false) then
            exit;

        repeat
            NPRTotalDiscBenefitUtils.CheckTotalDiscountBenefitListQuantity(NPRTotalDiscountBenefit);
        until NPRTotalDiscountBenefit.Next() = 0;

    end;
}