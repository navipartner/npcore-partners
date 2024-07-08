codeunit 6151080 "NPR Total Disc Benefit Utils"
{
    Access = Internal;

    internal procedure CheckNoEmpty(NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit")
    begin
        if (NPRTotalDiscountBenefit."No." = '') or
           (NPRTotalDiscountBenefit.Type <> NPRTotalDiscountBenefit.Type::Discount)
        then
            exit;

        NPRTotalDiscountBenefit.TestField("No.", '');
    end;

    internal procedure CheckVariantCodeEmpty(NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit")
    begin
        if (NPRTotalDiscountBenefit."Variant Code" = '') or
           (NPRTotalDiscountBenefit.Type = NPRTotalDiscountBenefit.Type::Item)
        then
            exit;

        NPRTotalDiscountBenefit.TestField("Variant Code", '');
    end;

    internal procedure UpdateDescription(var NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit")
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        NPRItemBenefitListHeader: Record "NPR Item Benefit List Header";
    begin
        case NPRTotalDiscountBenefit.Type of

            NPRTotalDiscountBenefit.Type::Item:
                begin
                    if not Item.Get(NPRTotalDiscountBenefit."No.") then
                        Clear(Item);

                    NPRTotalDiscountBenefit.Description := Item.Description;

                    if not ItemVariant.Get(NPRTotalDiscountBenefit."No.",
                                           NPRTotalDiscountBenefit."Variant Code")
                    then
                        Clear(ItemVariant);

                    if ItemVariant.Description <> '' then
                        NPRTotalDiscountBenefit.Description := CopyStr(CopyStr(ItemVariant.Description, 1, 30) + ' ' + ItemVariant."Description 2", 1, MaxStrLen(NPRTotalDiscountBenefit.Description));
                end;
            NPRTotalDiscountBenefit.Type::"Item List":
                begin
                    if not NPRItemBenefitListHeader.Get(NPRTotalDiscountBenefit."No.") then
                        Clear(NPRItemBenefitListHeader);

                    NPRTotalDiscountBenefit.Description := NPRItemBenefitListHeader.Description;
                end;
        end;
    end;

    internal procedure CheckValueType(NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit")
    var
        ValueTypeErrorLbl: Label '%1 ''%2'' cannot be selected for Type ''%3''';
    begin
        case NPRTotalDiscountBenefit."Value Type" of

            NPRTotalDiscountBenefit."Value Type"::Percent:
                if NPRTotalDiscountBenefit.Type <> NPRTotalDiscountBenefit.Type::Discount then
                    Error(ValueTypeErrorLbl,
                          NPRTotalDiscountBenefit.FieldName("Value Type"),
                          Format(NPRTotalDiscountBenefit."Value Type"),
                          Format(NPRTotalDiscountBenefit.Type));

            NPRTotalDiscountBenefit."Value Type"::Amount:
                if not (NPRTotalDiscountBenefit.Type in [NPRTotalDiscountBenefit.Type::Discount,
                                                         NPRTotalDiscountBenefit.Type::Item])
                then
                    Error(ValueTypeErrorLbl,
                          NPRTotalDiscountBenefit.FieldName("Value Type"),
                          Format(NPRTotalDiscountBenefit."Value Type"),
                          Format(NPRTotalDiscountBenefit.Type));
            else
                NPRTotalDiscountBenefit.TestField(Type);
        end;

    end;

    internal procedure CheckValue(NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit")
    var
        NegativeValueErrorLbl: Label 'Negative value is not accepted.';
        DiscountPercentageErrorLbl: Label 'The Discount Percentage can not be greater than 100%.';
    begin
        if NPRTotalDiscountBenefit.Value < 0 then
            Error(NegativeValueErrorLbl);

        if (NPRTotalDiscountBenefit.Type = NPRTotalDiscountBenefit.Type::Discount) and
           (NPRTotalDiscountBenefit."Value Type" = NPRTotalDiscountBenefit."Value Type"::Percent)
        then
            if NPRTotalDiscountBenefit.Value > 100 then
                Error(DiscountPercentageErrorLbl);
    end;

    internal procedure CheckIfTotalDiscountEditable(NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit")
    var
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscHeaderUtils: Codeunit "NPR Total Disc. Header Utils";
    begin
        if not NPRTotalDiscountHeader.Get(NPRTotalDiscountBenefit."Total Discount Code") then
            exit;

        NPRTotalDiscHeaderUtils.CheckIfTotalDiscountEditable(NPRTotalDiscountHeader);

    end;

    internal procedure CheckQuantity(NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit")
    var
        NegativeQuantityErrorLbl: Label 'Quantity in %1 has to be positive. Current value: %2', Comment = '%1 - RecordID, %2 - Quantity';
    begin
        NPRTotalDiscountBenefit.TestField(Type, NPRTotalDiscountBenefit.Type::Item);

        if NPRTotalDiscountBenefit.Quantity < 0 then
            Error(NegativeQuantityErrorLbl,
                  Format(NPRTotalDiscountBenefit.RecordId),
                  NPRTotalDiscountBenefit.Quantity);
    end;

    internal procedure ClearFields(var CurrNPRTotalDiscountBenefit: Record "NPR Total Discount Benefit")
    begin
        CurrNPRTotalDiscountBenefit."No." := '';
        CurrNPRTotalDiscountBenefit."Variant Code" := '';
        CurrNPRTotalDiscountBenefit.Description := '';
        CurrNPRTotalDiscountBenefit.Quantity := 0;
        CurrNPRTotalDiscountBenefit."Value Type" := CurrNPRTotalDiscountBenefit."Value Type"::Amount;
        CurrNPRTotalDiscountBenefit.Value := 0;
        CurrNPRTotalDiscountBenefit."No Input Needed" := false;
    end;

    internal procedure CheckNoInput(CurrNPRTotalDiscountBenefit: Record "NPR Total Discount Benefit")
    var
        LineTypeErrorLbl: Label 'The type of %1 has to be %2 or %3. Current type is %4.', Comment = '%1 - Record Id, %2 - Type1, %3 - Type2, %4 - type4';
    begin
        if not CurrNPRTotalDiscountBenefit."No Input Needed" then
            exit;

        if CurrNPRTotalDiscountBenefit.type in [CurrNPRTotalDiscountBenefit.Type::Item,
                                                CurrNPRTotalDiscountBenefit.Type::"Item List"]
        then
            exit;

        Error(LineTypeErrorLbl,
              Format(CurrNPRTotalDiscountBenefit.RecordId),
                     CurrNPRTotalDiscountBenefit.Type::Item,
                     CurrNPRTotalDiscountBenefit.Type::"Item List",
                     CurrNPRTotalDiscountBenefit.Type);
    end;

    #region CheckIfDiscountTypeAlreadyAssignedToStep
    internal procedure CheckIfDiscountTypeAlreadyAssignedToStep(CurrNPRTotalDiscountBenefit: Record "NPR Total Discount Benefit")
    var
        NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit";
        DiscountTypeErrorLbl: Label 'Discount benefit already assigned for %1 %2.';
    begin
        if CurrNPRTotalDiscountBenefit.Type <> CurrNPRTotalDiscountBenefit.Type::Discount then
            exit;

        NPRTotalDiscountBenefit.Reset();
        NPRTotalDiscountBenefit.SetCurrentKey("Total Discount Code", "Step Amount", Type);

        NPRTotalDiscountBenefit.SetRange("Total Discount Code", CurrNPRTotalDiscountBenefit."Total Discount Code");
        NPRTotalDiscountBenefit.SetRange("Step Amount", CurrNPRTotalDiscountBenefit."Step Amount");
        NPRTotalDiscountBenefit.SetRange(Type, NPRTotalDiscountBenefit.Type::Discount);
        NPRTotalDiscountBenefit.SetFilter("Line No.", '<>%1', CurrNPRTotalDiscountBenefit."Line No.");
        if not NPRTotalDiscountBenefit.FindFirst() then
            exit;

        Error(DiscountTypeErrorLbl,
              NPRTotalDiscountBenefit."Total Discount Code",
              NPRTotalDiscountBenefit."Step Amount");

    end;
    #endregion CheckIfDiscountTypeAlreadyAssignedToStep

    internal procedure CheckTotalDiscountBenefitListQuantity(NPRTotalDiscountBenefit: Record "NPR Total Discount Benefit")
    var
        NPRItemBenefitListLine: Record "NPR Item Benefit List Line";
        ItemBenefitListQuantityErrorLbl: Label 'Item no.: %1 variant code: %2 form item benefit list: %3 must have quantity.', Comment = '%1 - Item No., %2 - Variant Code, %3 - Item Benefit List';
    begin
        NPRItemBenefitListLine.Reset();
        NPRItemBenefitListLine.SetRange("List Code", NPRTotalDiscountBenefit."No.");
        NPRItemBenefitListLine.SetRange(Quantity, 0);

        NPRItemBenefitListLine.SetLoadFields("List Code", Quantity, "No.", "Variant Code");
        if not NPRItemBenefitListLine.FindFirst() then
            exit;

        Error(ItemBenefitListQuantityErrorLbl,
              NPRItemBenefitListLine."No.",
              NPRItemBenefitListLine."Variant Code",
              NPRItemBenefitListLine."List Code");
    end;
}