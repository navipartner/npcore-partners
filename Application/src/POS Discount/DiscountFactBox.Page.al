﻿page 6014614 "NPR Discount FactBox"
{
    Extensible = False;
    Caption = 'Discount FactBox';
    InsertAllowed = false;
    PageType = CardPart;
    UsageCategory = None;
    SourceTable = Item;


    layout
    {
        area(content)
        {
            field("Mix Discount"; MixDiscount)
            {

                Caption = 'Mix Discount';
                ToolTip = 'Specifies the value of the Mix Discount field';
                ApplicationArea = NPRRetail;
                DrillDown = true;

                trigger OnDrillDown()
                var
                    MixedDiscountLines: Page "NPR Mixed Discount Lines";
                    MixedDiscountLine: Record "NPR Mixed Discount Line";
                begin
                    MixedDiscountLines.Editable(false);
                    MixedDiscountLine.Reset();
                    MixedDiscountLine.SetRange("No.", Rec."No.");
                    MixedDiscountLines.SetTableView(MixedDiscountLine);
                    MixedDiscountLines.RunModal();
                end;
            }
            field("Period Discount"; PeriodDiscount)
            {

                Caption = 'Period Discount';
                ToolTip = 'Specifies the value of the Period Discount field';
                ApplicationArea = NPRRetail;
                DrillDown = true;

                trigger OnDrillDown()
                var
                    CampaignDiscountLines: Page "NPR Campaign Discount Lines";
                    PeriodDiscountLine: Record "NPR Period Discount Line";
                begin
                    CampaignDiscountLines.Editable(false);
                    PeriodDiscountLine.Reset();
                    PeriodDiscountLine.SetRange("Item No.", Rec."No.");
                    CampaignDiscountLines.SetTableView(PeriodDiscountLine);
                    CampaignDiscountLines.RunModal();
                end;
            }
            field("Multiple Unit Price"; MultipleUnitPrice)
            {

                Caption = 'Multiple Unit Price';
                ToolTip = 'Specifies the value of the Multiple Unit Price field';
                ApplicationArea = NPRRetail;
                DrillDown = true;

                trigger OnDrillDown()
                var
                    QuantityDiscountHeader: Record "NPR Quantity Discount Header";
                    QuantityDiscountCard: Page "NPR Quantity Discount Card";
                begin
                    QuantityDiscountCard.Editable(false);
                    QuantityDiscountHeader.Reset();
                    QuantityDiscountHeader.SetFilter("Item No.", Rec."No.");
                    QuantityDiscountCard.SetTableView(QuantityDiscountHeader);
                    QuantityDiscountCard.RunModal();
                end;
            }

            field("Total Discount"; TotalDiscount)
            {

                Caption = 'Total Discount';
                ToolTip = 'Specifies the value of the Total Discount field.';
                ApplicationArea = NPRRetail;
                DrillDown = true;

                trigger OnDrillDown()
                begin
                    LookUpTotalDiscountLines(Rec);
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        HasDiscounts();
        HasMultipleUnitPrice();
        HasTotalDiscount(Rec,
                        TotalDiscount)
    end;

    var
        MixDiscount: Boolean;
        PeriodDiscount: Boolean;
        MultipleUnitPrice: Boolean;
        TotalDiscount: Boolean;

    internal procedure HasDiscounts()
    var
        PeriodDiscountLine: Record "NPR Period Discount Line";
        MixDiscountLine: Record "NPR Mixed Discount Line";
        MixDiscountHeader: Record "NPR Mixed Discount";
    begin
        MixDiscount := false;
        PeriodDiscount := false;
        PeriodDiscountLine.SetRange(PeriodDiscountLine.Status, PeriodDiscountLine.Status::Active);
        PeriodDiscountLine.SetFilter(PeriodDiscountLine."Starting Date", '<=%1', Today);
        PeriodDiscountLine.SetFilter(PeriodDiscountLine."Ending Date", '>=%1', Today);
        PeriodDiscountLine.SetFilter(PeriodDiscountLine."Item No.", Rec."No.");
        if PeriodDiscountLine.FindFirst() then
            PeriodDiscount := true;

        PeriodDiscountLine.Reset();
        PeriodDiscountLine.SetRange(PeriodDiscountLine.Status, PeriodDiscountLine.Status::Active);
        PeriodDiscountLine.SetFilter(PeriodDiscountLine."Starting Date", '>%1', Today);
        PeriodDiscountLine.SetFilter(PeriodDiscountLine."Item No.", Rec."No.");
        if PeriodDiscountLine.FindFirst() then
            PeriodDiscount := true;

        MixDiscountLine.Reset();
        MixDiscountLine.SetFilter(MixDiscountLine."No.", Rec."No.");
        if MixDiscountLine.FindSet() then
            repeat
                MixDiscountHeader.Reset();
                if MixDiscountHeader.Get(MixDiscountLine.Code) and ((MixDiscountHeader."Starting date" <= Today) and
                  (MixDiscountHeader."Ending date" >= Today)) and (MixDiscountHeader.Status = MixDiscountHeader.Status::Active) then begin
                    MixDiscount := true;
                end;
            until MixDiscountLine.Next() = 0;

        if not MixDiscount then begin
            MixDiscountLine.Reset();
            MixDiscountLine.SetFilter(MixDiscountLine."No.", Rec."No.");
            if MixDiscountLine.FindSet() then
                repeat
                    MixDiscountHeader.Reset();
                    if MixDiscountHeader.Get(MixDiscountLine.Code) and (MixDiscountHeader."Starting date" > Today) and
                      (MixDiscountHeader.Status = MixDiscountHeader.Status::Active) then begin
                        MixDiscount := true;
                    end;
                until MixDiscountLine.Next() = 0;
        end;
    end;

    local procedure HasMultipleUnitPrice()
    var
        QuantityDiscountHeader: Record "NPR Quantity Discount Header";
    begin
        MultipleUnitPrice := false;
        QuantityDiscountHeader.SetFilter("Item No.", Rec."No.");
        QuantityDiscountHeader.SetRange(Status, QuantityDiscountHeader.Status::Active);
        if QuantityDiscountHeader.FindFirst() then
            MultipleUnitPrice := true;
    end;

    local procedure HasTotalDiscount(Item: Record Item;
                                     var TotalDiscountExists: Boolean)
    var
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
    begin
        NPRTotalDiscountManagement.CheckIfItemHasTotalDiscount(Item,
                                                               TotalDiscountExists);

    end;

    local procedure LookUpTotalDiscountLines(Item: Record Item)
    var
        NPRTotalDiscountManagement: Codeunit "NPR Total Discount Management";
        TempNPRTotalDiscountLine: Record "NPR Total Discount Line" temporary;
    begin
        NPRTotalDiscountManagement.LookUpTotalDiscountLines(Item,
                                                            TempNPRTotalDiscountLine);
    end;
}

