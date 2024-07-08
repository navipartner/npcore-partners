codeunit 6151078 "NPR Total Disc. Line Utils"
{
    Access = Internal;

    internal procedure UpdateHaderModifyInformation(NPRTotalDiscountLine: Record "NPR Total Discount Line")
    var
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
    begin
        if not NPRTotalDiscountHeader.Get(NPRTotalDiscountLine."Total Discount Code") then
            Clear(NPRTotalDiscountHeader);

        NPRTotalDiscountHeader."Last Date Modified" := Today;
        NPRTotalDiscountHeader.Modify();
    end;

    internal procedure UpdateLineWithHeaderInformation(var NPRTotalDiscountLine: Record "NPR Total Discount Line")
    var
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
    begin
        if not NPRTotalDiscountHeader.Get(NPRTotalDiscountLine."Total Discount Code") then
            exit;

        NPRTotalDiscountLine."Starting Date" := NPRTotalDiscountHeader."Starting date";
        NPRTotalDiscountLine."Ending Date" := NPRTotalDiscountHeader."Ending date";
        NPRTotalDiscountLine.Status := NPRTotalDiscountHeader.Status;
        NPRTotalDiscountLine."Starting Time" := NPRTotalDiscountHeader."Starting time";
        NPRTotalDiscountLine."Ending Time" := NPRTotalDiscountHeader."Ending time";
    end;

    internal procedure UpdateLineNoInformation(var NPRTotalDiscountLine: Record "NPR Total Discount Line")
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ItemCategory: Record "Item Category";
        Vendor: Record Vendor;
    begin
        case NPRTotalDiscountLine."Type" of
            NPRTotalDiscountLine."Type"::Item:
                begin
                    if not Item.Get(NPRTotalDiscountLine."No.") then
                        Clear(Item);

                    NPRTotalDiscountLine.Description := Item.Description;
                    NPRTotalDiscountLine."Description 2" := Item."Description 2";
                    if not ItemVariant.Get(NPRTotalDiscountLine."No.",
                                           NPRTotalDiscountLine."Variant Code")
                    then
                        Clear(ItemVariant);

                    if ItemVariant.Description <> '' then
                        NPRTotalDiscountLine."Description 2" := CopyStr(ItemVariant.Description, 1, MaxStrLen(NPRTotalDiscountLine."Description 2"));

                    NPRTotalDiscountLine."Vendor No." := Item."Vendor No.";
                    NPRTotalDiscountLine."Vendor Item No." := Item."Vendor Item No.";
                end;
            NPRTotalDiscountLine."Type"::"Item Category":
                begin
                    if not ItemCategory.Get(NPRTotalDiscountLine."No.") then
                        Clear(ItemCategory);
                    NPRTotalDiscountLine.Description := ItemCategory.Description;
                end;
            NPRTotalDiscountLine."Type"::"Vendor":
                begin
                    if not Vendor.Get(NPRTotalDiscountLine."No.") then
                        Clear(Vendor);

                    NPRTotalDiscountLine.Description := Vendor.Name;
                end;
        end;
    end;

    internal procedure CheckIfTotalDiscountEditable(NPRTotalDiscountLine: Record "NPR Total Discount Line")
    var
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
        NPRTotalDiscHeaderUtils: Codeunit "NPR Total Disc. Header Utils";
    begin
        if not NPRTotalDiscountHeader.Get(NPRTotalDiscountLine."Total Discount Code") then
            exit;

        NPRTotalDiscHeaderUtils.CheckIfTotalDiscountEditable(NPRTotalDiscountHeader);

    end;

    internal procedure ClearTypeRelatedFields(var NPRTotalDiscountLine: Record "NPR Total Discount Line")
    begin
        NPRTotalDiscountLine."No." := '';
        NPRTotalDiscountLine."Variant Code" := '';
        NPRTotalDiscountLine."Unit Of Measure Code" := '';
        NPRTotalDiscountLine.Description := '';
        NPRTotalDiscountLine."Description 2" := '';
        NPRTotalDiscountLine."Vendor No." := '';
        NPRTotalDiscountLine."Vendor Item No." := '';
    end;

    internal procedure OpenTotalDiscount(NPRTotalDiscountLine: Record "NPR Total Discount Line")
    var
        NPRTotalDiscountHeader: Record "NPR Total Discount Header";
    begin
        if not NPRTotalDiscountHeader.Get(NPRTotalDiscountLine."Total Discount Code") then
            Clear(NPRTotalDiscountHeader);

        NPRTotalDiscountHeader.SetRecFilter();

        Page.Run(Page::"NPR Total Discount Card", NPRTotalDiscountHeader);
    end;
}