codeunit 85234 "NPR Library - POS Discount"
{
    internal procedure CreateTotalDiscountPct(Item: Record Item; TotalDiscPct: Decimal; TotalAmtExclTax: Boolean): Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
        DiscPct: Decimal;
    begin
        DiscPct := CreateTotalDiscountPctHeader(MixedDiscount, TotalDiscPct, TotalAmtExclTax);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);
        exit(DiscPct);
    end;

    internal procedure CreateTotalDiscountPctWithUOM(Item: Record Item; TotalDiscPct: Decimal; TotalAmtExclTax: Boolean; UOM: Code[10]; var DiscountCode: Code[20]): Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
        DiscPct: Decimal;
    begin
        DiscPct := CreateTotalDiscountPctHeader(MixedDiscount, TotalDiscPct, TotalAmtExclTax);
        CreateDiscountLineWithUOM(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item, UOM);
        DiscountCode := MixedDiscount.Code;
        MixedDiscount.Modify();
        exit(DiscPct);
    end;

    internal procedure CreateTotalDiscountPctWithUOMTwoItems(Item: Record Item; SecondItem: Record Item; TotalDiscPct: Decimal; TotalAmtExclTax: Boolean; FirstUOM: Code[10]; SecondUOM: Code[10]; var DiscountCode: Code[20]): Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
        DiscPct: Decimal;
    begin
        DiscPct := CreateTotalDiscountPctHeader(MixedDiscount, TotalDiscPct, TotalAmtExclTax);
        CreateDiscountLineWithUOM(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item, FirstUOM);
        CreateDiscountLineWithUOM(MixedDiscount, SecondItem, "NPR Disc. Grouping Type"::Item, SecondUOM);
        DiscountCode := MixedDiscount.Code;
        MixedDiscount.Modify();
        exit(DiscPct);
    end;

    internal procedure CreateTotalDiscountAmountTotalDiscountAmtPerMinQty(Item: Record Item; TotalDiscountAmount: Decimal; TotalAmountExclTax: Boolean): Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
        DiscountAmount: Decimal;
    begin
        DiscountAmount := CreateTotalDiscountAmountHeader(MixedDiscount, TotalDiscountAmount, TotalAmountExclTax);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);
        exit(DiscountAmount);
    end;

    internal procedure CreateTotalDiscountAmountTotalAmtPerMinQty(Item: Record Item; TotalDiscountAmount: Decimal; TotalAmountExclTax: Boolean): Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
        DiscountAmount: Decimal;
    begin
        DiscountAmount := CreateTotalAmountHeader(MixedDiscount, TotalDiscountAmount, TotalAmountExclTax);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);
        exit(DiscountAmount);
    end;

    internal procedure CreateMultipleDiscountLevels(Item: Record Item; FirstLevelQty: Integer; SecondLevelQty: Integer; FirstLevelAmount: Decimal; SecondLevelAmount: Decimal; TotalAmountExclTax: Boolean): Code[20]
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        CreateMultipleDiscountLevelsHeader(MixedDiscount, TotalAmountExclTax);
        CreateDiscountLine(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item);
        CreateMixDiscountLevels(MixedDiscount, FirstLevelQty, SecondLevelQty, FirstLevelAmount, SecondLevelAmount);
        exit(MixedDiscount.Code);
    end;

    internal procedure CreateTotalDiscountAmountTotalAmtPerMinQtyWithUOM(Item: Record Item; TotalDiscountAmount: Decimal; TotalAmountExclTax: Boolean; UOM: Code[10]; var DiscountCode: Code[20]): Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
        DiscountAmount: Decimal;
    begin
        DiscountAmount := CreateTotalAmountHeader(MixedDiscount, TotalDiscountAmount, TotalAmountExclTax);
        CreateDiscountLineWithUOM(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item, UOM);
        DiscountCode := MixedDiscount.Code;
        exit(DiscountAmount);
    end;

    internal procedure CreateTotalDiscountAmountTotalDiscountAmtPerMinQtyWithUOM(Item: Record Item; TotalDiscountAmount: Decimal; TotalAmountExclTax: Boolean; UOM: Code[10]; var DiscountCode: Code[20]): Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
        DiscountAmount: Decimal;
    begin
        DiscountAmount := CreateTotalDiscountAmountHeader(MixedDiscount, TotalDiscountAmount, TotalAmountExclTax);
        CreateDiscountLineWithUOM(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item, UOM);
        DiscountCode := MixedDiscount.Code;
        exit(DiscountAmount);
    end;

    internal procedure CreateTotalDiscountAmountTotalDiscountAmtPerMinQtyWithUOMTwoItems(Item: Record Item; SecondItem: Record Item; TotalDiscountAmount: Decimal; TotalAmountExclTax: Boolean; FirstUOM: Code[10]; SecondUOM: Code[10]; var DiscountCode: Code[20]): Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
        DiscountAmount: Decimal;
    begin
        DiscountAmount := CreateTotalDiscountAmountHeader(MixedDiscount, TotalDiscountAmount, TotalAmountExclTax);
        CreateDiscountLineWithUOM(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item, FirstUOM);
        CreateDiscountLineWithUOM(MixedDiscount, SecondItem, "NPR Disc. Grouping Type"::Item, SecondUOM);
        DiscountCode := MixedDiscount.Code;
        exit(DiscountAmount);
    end;

    internal procedure CreateTotalDiscountAmountTotalAmtPerMinQtyWithUOMTwoItems(Item: Record Item; SecondItem: Record Item; TotalDiscountAmount: Decimal; TotalAmountExclTax: Boolean; FirstUOM: Code[10]; SecondUOM: Code[10]; var DiscountCode: Code[20]): Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
        DiscountAmount: Decimal;
    begin
        DiscountAmount := CreateTotalAmountHeader(MixedDiscount, TotalDiscountAmount, TotalAmountExclTax);
        CreateDiscountLineWithUOM(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item, FirstUOM);
        CreateDiscountLineWithUOM(MixedDiscount, SecondItem, "NPR Disc. Grouping Type"::Item, SecondUOM);
        DiscountCode := MixedDiscount.Code;
        exit(DiscountAmount);
    end;

    internal procedure CreateTotalDiscountPctHeader(var MixedDiscount: Record "NPR Mixed Discount"; TotalDiscPct: Decimal; TotalAmtExclTax: Boolean): Decimal
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        MixedDiscount.Code := LibraryUtility.GenerateRandomCode(MixedDiscount.FieldNo(Code), MixDiscountSourceTableId());
        MixedDiscount.Init();
        MixedDiscount.Status := MixedDiscount.Status::Active;
        MixedDiscount."Starting date" := Today() - 7;
        MixedDiscount."Ending date" := Today() + 7;
        MixedDiscount."Discount Type" := MixedDiscount."Discount Type"::"Total Discount %";
        MixedDiscount."Total Discount %" := TotalDiscPct;
        MixedDiscount."Total Amount Excl. VAT" := TotalAmtExclTax;
        MixedDiscount."Min. Quantity" := 1;
        MixedDiscount.Insert();
        exit(MixedDiscount."Total Discount %");
    end;

    internal procedure CreateTotalDiscountAmountHeader(var MixedDiscount: Record "NPR Mixed Discount"; TotalDiscountAmount: Decimal; TotalAmtExclTax: Boolean): Decimal
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        MixedDiscount.Code := LibraryUtility.GenerateRandomCode(MixedDiscount.FieldNo(Code), MixDiscountSourceTableId());
        MixedDiscount.Init();
        MixedDiscount.Status := MixedDiscount.Status::Active;
        MixedDiscount."Starting date" := Today() - 7;
        MixedDiscount."Ending date" := Today() + 7;
        MixedDiscount."Discount Type" := MixedDiscount."Discount Type"::"Total Discount Amt. per Min. Qty.";
        MixedDiscount."Total Discount Amount" := TotalDiscountAmount;
        MixedDiscount."Total Amount Excl. VAT" := TotalAmtExclTax;
        MixedDiscount."Min. Quantity" := 1;
        MixedDiscount.Insert();
        exit(MixedDiscount."Total Discount Amount");
    end;

    internal procedure CreateTotalAmountHeader(var MixedDiscount: Record "NPR Mixed Discount"; TotalDiscountAmount: Decimal; TotalAmtExclTax: Boolean): Decimal
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        MixedDiscount.Code := LibraryUtility.GenerateRandomCode(MixedDiscount.FieldNo(Code), MixDiscountSourceTableId());
        MixedDiscount.Init();
        MixedDiscount.Status := MixedDiscount.Status::Active;
        MixedDiscount."Starting date" := Today() - 7;
        MixedDiscount."Ending date" := Today() + 7;
        MixedDiscount."Discount Type" := MixedDiscount."Discount Type"::"Total Amount per Min. Qty.";
        MixedDiscount."Total Amount" := TotalDiscountAmount;
        MixedDiscount."Total Amount Excl. VAT" := TotalAmtExclTax;
        MixedDiscount."Min. Quantity" := 1;
        MixedDiscount.Insert();
        exit(MixedDiscount."Total Amount");
    end;

    internal procedure CreateMultipleDiscountLevelsHeader(var MixedDiscount: Record "NPR Mixed Discount"; TotalAmtExclTax: Boolean)
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        MixedDiscount.Code := LibraryUtility.GenerateRandomCode(MixedDiscount.FieldNo(Code), MixDiscountSourceTableId());
        MixedDiscount.Init();
        MixedDiscount.Status := MixedDiscount.Status::Active;
        MixedDiscount."Starting date" := Today() - 7;
        MixedDiscount."Ending date" := Today() + 7;
        MixedDiscount."Discount Type" := MixedDiscount."Discount Type"::"Multiple Discount Levels";
        MixedDiscount."Total Amount Excl. VAT" := TotalAmtExclTax;
        MixedDiscount."Min. Quantity" := 1;
        MixedDiscount.Insert();
    end;

    internal procedure CreateMixDiscountLevels(MixedDiscount: Record "NPR Mixed Discount"; FirstLevelQty: Integer; SecondLevelQty: Integer; FirstLevelAmount: Decimal; SecondLevelAmount: Decimal)
    var
        MixedDiscountLevel: Record "NPR Mixed Discount Level";
    begin
        MixedDiscountLevel.Init();
        MixedDiscountLevel."Mixed Discount Code" := MixedDiscount.Code;
        MixedDiscountLevel.Quantity := FirstLevelQty;
        MixedDiscountLevel."Discount Amount" := FirstLevelAmount;
        MixedDiscountLevel.Insert();

        MixedDiscountLevel.Init();
        MixedDiscountLevel."Mixed Discount Code" := MixedDiscount.Code;
        MixedDiscountLevel.Quantity := SecondLevelQty;
        MixedDiscountLevel."Discount Amount" := SecondLevelAmount;
        MixedDiscountLevel.Insert();
    end;

    internal procedure CreateDiscountLine(MixedDiscount: Record "NPR Mixed Discount"; Item: Record Item; DiscGroupType: Enum "NPR Disc. Grouping Type")
    var
        MixedDiscountLine: Record "NPR Mixed Discount Line";
    begin
        MixedDiscountLine.Code := MixedDiscount.Code;
        MixedDiscountLine."Disc. Grouping Type" := DiscGroupType;
        MixedDiscountLine."No." := Item."No.";
        MixedDiscountLine."Variant Code" := '';
        MixedDiscountLine.Init();
        MixedDiscountLine.Status := MixedDiscount.Status;
        MixedDiscountLine."Starting date" := MixedDiscount."Starting date";
        MixedDiscountLine."Ending Date" := MixedDiscount."Ending date";
        MixedDiscountLine.Insert();
    end;

    internal procedure CreateDiscountLineWithUOM(MixedDiscount: Record "NPR Mixed Discount"; Item: Record Item; DiscGroupType: Enum "NPR Disc. Grouping Type"; UOM: Code[10])
    var
        MixedDiscountLine: Record "NPR Mixed Discount Line";
    begin
        MixedDiscountLine.Code := MixedDiscount.Code;
        MixedDiscountLine."Disc. Grouping Type" := DiscGroupType;
        MixedDiscountLine."No." := Item."No.";
        MixedDiscountLine."Variant Code" := '';
        MixedDiscountLine.Init();
        MixedDiscountLine.Status := MixedDiscount.Status;
        MixedDiscountLine."Unit of Measure Code" := UOM;
        MixedDiscountLine."Starting date" := MixedDiscount."Starting date";
        MixedDiscountLine."Ending Date" := MixedDiscount."Ending date";
        MixedDiscountLine.Insert();
    end;

    internal procedure CreateTotalDiscountPctLotEnabled(Item: Record Item; TotalDiscPct: Decimal; TotalAmtExclTax: Boolean; ItemQty: Integer; var DiscountCode: Code[20]): Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
        DiscPct: Decimal;
    begin
        DiscPct := CreateTotalDiscountPctHeader(MixedDiscount, TotalDiscPct, TotalAmtExclTax);
        CreateDiscountLineWithQty(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item, ItemQty);
        MixedDiscount.Lot := true;
        DiscountCode := MixedDiscount.Code;
        MixedDiscount.Modify();
        exit(DiscPct);
    end;

    internal procedure CreateTotalDiscountAmountTotalDiscountPctLotEnabledTwoItems(Item: Record Item; Item2: Record Item; TotalDiscountAmount: Decimal; TotalAmountExclTax: Boolean; FirstItemQty: Integer; SecondItemQty: Integer; var DiscountCode: Code[20]) DiscountAmount: Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        DiscountAmount := CreateTotalDiscountPctHeader(MixedDiscount, TotalDiscountAmount, TotalAmountExclTax);
        MixedDiscount.Lot := true;
        CreateDiscountLineWithQty(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item, FirstItemQty);
        CreateDiscountLineWithQty(MixedDiscount, Item2, "NPR Disc. Grouping Type"::Item, SecondItemQty);
        DiscountCode := MixedDiscount.Code;
        MixedDiscount.Modify();
    end;

    internal procedure CreateTotalDiscountAmountTotalAmtPerMinQtyLotEnabled(Item: Record Item; TotalDiscountAmount: Decimal; TotalAmountExclTax: Boolean; ItemQty: Integer; var DiscountCode: Code[20]) DiscountAmount: Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        DiscountAmount := CreateTotalAmountHeader(MixedDiscount, TotalDiscountAmount, TotalAmountExclTax);
        CreateDiscountLineWithQty(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item, ItemQty);
        MixedDiscount.Lot := true;
        DiscountCode := MixedDiscount.Code;
        MixedDiscount.Modify();
    end;

    internal procedure CreateTotalDiscountAmountTotalDiscountAmtPerMinQtyLotEnabled(Item: Record Item; TotalDiscountAmount: Decimal; TotalAmountExclTax: Boolean; ItemQty: Integer; var DiscountCode: Code[20]) DiscountAmount: Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        CreateTotalDiscountAmountHeader(MixedDiscount, TotalDiscountAmount, TotalAmountExclTax);
        CreateDiscountLineWithQty(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item, ItemQty);
        MixedDiscount.Lot := true;
        DiscountCode := MixedDiscount.Code;
        MixedDiscount.Modify();
        DiscountAmount := MixedDiscount."Total Discount Amount";
    end;

    internal procedure CreateTotalDiscountAmountTotalAmtPerMinQtyLotEnabledTwoItems(Item: Record Item; Item2: Record Item; TotalDiscountAmount: Decimal; TotalAmountExclTax: Boolean; FirstItemQty: Integer; SecondItemQty: Integer; var DiscountCode: Code[20]) DiscountAmount: Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        DiscountAmount := CreateTotalAmountHeader(MixedDiscount, TotalDiscountAmount, TotalAmountExclTax);
        MixedDiscount.Lot := true;
        CreateDiscountLineWithQty(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item, FirstItemQty);
        CreateDiscountLineWithQty(MixedDiscount, Item2, "NPR Disc. Grouping Type"::Item, SecondItemQty);
        DiscountCode := MixedDiscount.Code;
        MixedDiscount.Modify();
    end;

    internal procedure CreateTotalDiscountAmountTotalDiscountAmtPerMinQtyLotEnabledTwoItems(Item: Record Item; Item2: Record Item; TotalDiscountAmount: Decimal; TotalAmountExclTax: Boolean; FirstItemQty: Integer; SecondItemQty: Integer; var DiscountCode: Code[20]) DiscountAmount: Decimal
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        CreateTotalDiscountAmountHeader(MixedDiscount, TotalDiscountAmount, TotalAmountExclTax);
        MixedDiscount.Lot := true;
        CreateDiscountLineWithQty(MixedDiscount, Item, "NPR Disc. Grouping Type"::Item, FirstItemQty);
        CreateDiscountLineWithQty(MixedDiscount, Item2, "NPR Disc. Grouping Type"::Item, SecondItemQty);
        DiscountCode := MixedDiscount.Code;
        MixedDiscount.Modify();
        DiscountAmount := MixedDiscount."Total Discount Amount";
    end;

    internal procedure CreateDiscountLineWithQty(MixedDiscount: Record "NPR Mixed Discount"; Item: Record Item; DiscGroupType: Enum "NPR Disc. Grouping Type"; Quantity: Integer)
    var
        MixedDiscountLine: Record "NPR Mixed Discount Line";
    begin
        MixedDiscountLine.Code := MixedDiscount.Code;
        MixedDiscountLine."Disc. Grouping Type" := DiscGroupType;
        MixedDiscountLine."No." := Item."No.";
        MixedDiscountLine."Variant Code" := '';
        MixedDiscountLine.Init();
        MixedDiscountLine.Status := MixedDiscount.Status;
        MixedDiscountLine."Starting date" := MixedDiscount."Starting date";
        MixedDiscountLine.Quantity := Quantity;
        MixedDiscountLine."Ending Date" := MixedDiscount."Ending date";
        MixedDiscountLine.Insert();
    end;

    internal procedure CreateMixDiscountTimeInterval(MixedDiscount: Record "NPR Mixed Discount"; var MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv."; StartTime: Time; EndTime: Time)
    begin
        MixedDiscTimeInterv.Init();
        MixedDiscTimeInterv."Mix Code" := MixedDiscount.Code;
        MixedDiscTimeInterv."Line No." := 10000;
        MixedDiscTimeInterv."Start Time" := StartTime;
        MixedDiscTimeInterv."End Time" := EndTime;
        MixedDiscTimeInterv."Period Type" := MixedDiscTimeInterv."Period Type"::"Every Day";
        MixedDiscTimeInterv.Insert();
    end;

    internal procedure GetDayAndSetToMixedDiscTimeInterval(var MixedDiscTimeInterv: Record "NPR Mixed Disc. Time Interv."; DayDirection: Option Today,Future,Past)
    var
        DayInteger: Integer;
        DaysOfWeek: Option Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday;
    begin
        MixedDiscTimeInterv."Period Type" := MixedDiscTimeInterv."Period Type"::Weekly;
        DayInteger := Date2DWY(Today(), 1) - 1;
        case DayDirection of
            DayDirection::Future:
                DayInteger := (DayInteger + 1) mod 7;
            DayDirection::Past:
                DayInteger := ((DayInteger + 6) mod 7);
        end;

        DaysOfWeek := DayInteger;
        case DaysOfWeek of
            DaysOfWeek::Monday:
                MixedDiscTimeInterv.Monday := true;
            DaysOfWeek::Tuesday:
                MixedDiscTimeInterv.Tuesday := true;
            DaysOfWeek::Wednesday:
                MixedDiscTimeInterv.Wednesday := true;
            DaysOfWeek::Thursday:
                MixedDiscTimeInterv.Thursday := true;
            DaysOfWeek::Friday:
                MixedDiscTimeInterv.Friday := true;
            DaysOfWeek::Saturday:
                MixedDiscTimeInterv.Saturday := true;
            DaysOfWeek::Sunday:
                MixedDiscTimeInterv.Sunday := true;
        end;
        MixedDiscTimeInterv.Modify(true);
    end;

    internal procedure MixDiscountSourceTableId(): Integer
    begin
        exit(DATABASE::"NPR Mixed Discount");
    end;
}