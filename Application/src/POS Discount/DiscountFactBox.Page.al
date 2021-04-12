page 6014614 "NPR Discount FactBox"
{

    Caption = 'Discount FactBox';
    InsertAllowed = false;
    PageType = CardPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = Item;

    layout
    {
        area(content)
        {
            field("Mix Discount"; MixDiscount)
            {
                ApplicationArea = All;
                Caption = 'Mix Discount';
                ToolTip = 'Specifies the value of the Mix Discount field';

                trigger OnAssistEdit()
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
                ApplicationArea = All;
                Caption = 'Period Discount';
                ToolTip = 'Specifies the value of the Period Discount field';

                trigger OnAssistEdit()
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
                ApplicationArea = All;
                Caption = 'Multiple Unit Price';
                ToolTip = 'Specifies the value of the Multiple Unit Price field';

                trigger OnAssistEdit()
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
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        HasDiscounts();
        HasMultipleUnitPrice();
    end;

    var
        MixDiscount: Boolean;
        PeriodDiscount: Boolean;
        MultipleUnitPrice: Boolean;

    procedure HasDiscounts()
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
        if MixDiscountLine.FindFirst() then
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
            if MixDiscountLine.FindFirst() then
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
}

