codeunit 6014432 "NPR Quantity Discount Mgt."
{
    trigger OnRun()
    begin
    end;

    procedure ApplyQuantityDiscounts(SalePOS: Record "NPR Sale POS"; var TempSaleLinePOS: Record "NPR Sale Line POS" temporary; Rec: Record "NPR Sale Line POS"; RecalculateAllLines: Boolean): Boolean
    var
        TempQuantityDiscountLine: Record "NPR Quantity Discount Line" temporary;
        TempQuantityDiscountHeader: Record "NPR Quantity Discount Header" temporary;
        ItemQuantity: Decimal;
        DiscountPercent: Decimal;
    begin

        if TempSaleLinePOS."Customer Price Group" <> '' then
            exit;

        Clear(TempSaleLinePOS);

        if not RecalculateAllLines then
            TempSaleLinePOS.SetRange("No.", Rec."No.");
        TempSaleLinePOS.SetRange("Discount Type", TempSaleLinePOS."Discount Type"::" ");

        if TempSaleLinePOS.IsEmpty then
            exit;

        GetQuantityDiscounts(TempSaleLinePOS, TempQuantityDiscountHeader, TempQuantityDiscountLine);
        if TempQuantityDiscountHeader.IsEmpty then
            exit;
        TempQuantityDiscountHeader.FindSet;
        repeat
            ItemQuantity := 0;
            TempSaleLinePOS.SetRange("No.", TempQuantityDiscountHeader."Item No.");
            if TempSaleLinePOS.FindSet then
                repeat
                    ItemQuantity += TempSaleLinePOS.Quantity;
                until TempSaleLinePOS.Next = 0;

            TempQuantityDiscountLine.SetRange("Main no.", TempQuantityDiscountHeader."Main No.");
            TempQuantityDiscountLine.SetRange("Item No.", TempQuantityDiscountHeader."Item No.");
            TempQuantityDiscountLine.SetFilter(Quantity, '>%1&<=%2', 0, Abs(ItemQuantity));

            if TempQuantityDiscountLine.FindLast then begin
                TempSaleLinePOS.SetRange("No.", TempQuantityDiscountLine."Item No.");
                if TempSaleLinePOS.FindSet then
                    repeat
                        TempQuantityDiscountLine.CalcFields("Price Includes VAT");
                        DiscountPercent := 0;
                        if (TempSaleLinePOS."Unit Price" <> 0) then begin

                            if (TempQuantityDiscountLine."Price Includes VAT" = TempSaleLinePOS."Price Includes VAT") then begin
                                DiscountPercent := 100 - TempQuantityDiscountLine."Unit Price" / TempSaleLinePOS."Unit Price" * 100;

                            end else begin
                                if (TempSaleLinePOS."Price Includes VAT") then
                                    DiscountPercent := 100 - (TempQuantityDiscountLine."Unit Price" * (100 + TempSaleLinePOS."VAT %") / 100) / TempSaleLinePOS."Unit Price" * 100;

                                if (TempQuantityDiscountLine."Price Includes VAT") then
                                    DiscountPercent := 100 - (TempQuantityDiscountLine."Unit Price" / (TempSaleLinePOS."Unit Price" * (100 + TempSaleLinePOS."VAT %") / 100) * 100);
                            end;

                        end;

                        TempSaleLinePOS."Discount %" := DiscountPercent;
                        TempSaleLinePOS."Discount Type" := TempSaleLinePOS."Discount Type"::Quantity;
                        TempSaleLinePOS."Discount Code" := TempQuantityDiscountLine."Main no.";
                        TempSaleLinePOS."FP Anvendt" := true;

                        if (DiscountPercent >= 0) then
                            TempSaleLinePOS.Modify;

                    until TempSaleLinePOS.Next = 0;
            end;
        until TempQuantityDiscountHeader.Next = 0;
    end;

    procedure GetQuantityDiscounts(var TempSaleLinePOS: Record "NPR Sale Line POS" temporary; var TempQuantityDiscountHeader: Record "NPR Quantity Discount Header" temporary; var TempQuantityDiscountLine: Record "NPR Quantity Discount Line")
    var
        QuantityDiscountLine: Record "NPR Quantity Discount Line";
        QuantityDiscountHeader: Record "NPR Quantity Discount Header";
    begin
        if TempSaleLinePOS.FindSet then
            repeat
                QuantityDiscountHeader.SetCurrentKey("Item No.", Status, "Starting Date", "Closing Date");
                QuantityDiscountHeader.SetRange("Item No.", TempSaleLinePOS."No.");
                QuantityDiscountHeader.SetRange(Status, QuantityDiscountHeader.Status::Active);
                QuantityDiscountHeader.SetFilter("Starting Date", '<=%1|=%2', Today, 0D);
                QuantityDiscountHeader.SetFilter("Closing Date", '>=%1|=%2', Today, 0D);
                QuantityDiscountHeader.SetFilter("Starting Time", '<=%1|=%2', Time, 0T);
                QuantityDiscountHeader.SetFilter("Closing Time", '>=%1|=%2', Time, 0T);
                QuantityDiscountHeader.SetFilter("Global Dimension 1 Code", '=%1|=%2', TempSaleLinePOS."Shortcut Dimension 1 Code", '');
                QuantityDiscountHeader.SetFilter("Global Dimension 2 Code", '=%1|=%2', TempSaleLinePOS."Shortcut Dimension 2 Code", '');

                if QuantityDiscountHeader.FindSet then begin
                    TempSaleLinePOS."Discount Calculated" := true;
                    TempSaleLinePOS.Modify;
                    repeat
                        QuantityDiscountLine.SetRange("Main no.", QuantityDiscountHeader."Main No.");
                        QuantityDiscountLine.SetRange("Item No.", QuantityDiscountHeader."Item No.");

                        TempQuantityDiscountHeader.Init;
                        TempQuantityDiscountHeader.TransferFields(QuantityDiscountHeader);

                        if TempQuantityDiscountHeader.Insert then begin
                            if QuantityDiscountLine.FindSet then
                                repeat
                                    TempQuantityDiscountLine.Init;
                                    TempQuantityDiscountLine.TransferFields(QuantityDiscountLine);
                                    TempQuantityDiscountLine.Insert;
                                until QuantityDiscountLine.Next = 0;
                        end;
                    until QuantityDiscountHeader.Next = 0;
                end;
            until TempSaleLinePOS.Next = 0;
    end;

    procedure GetOrInit(var DiscountPriority: Record "NPR Discount Priority")
    begin
        if DiscountPriority.Get(DiscSourceTableId()) then
            exit;

        DiscountPriority.Init;
        DiscountPriority."Table ID" := DiscSourceTableId();
        DiscountPriority.Priority := 4;
        DiscountPriority.Disabled := false;
        DiscountPriority."Discount Calc. Codeunit ID" := DiscCalcCodeunitId();
        DiscountPriority."Cross Line Calculation" := true;
        DiscountPriority.Insert(true);
    end;

    procedure GetNoSeries(): Code[10]
    var
        DiscountPriority: Record "NPR Discount Priority";
        NoSeriesCodeTok: Label 'QTY-DISC', Locked = true;
        NoSeriesDescriptionTok: Label 'Quantity Discount No. Series';
    begin
        GetOrInit(DiscountPriority);
        if DiscountPriority."Discount No. Series" = '' then // if not initialized via upgrade codeunit
            DiscountPriority.CreateNoSeries(NoSeriesCodeTok, NoSeriesDescriptionTok, false);

        exit(DiscountPriority."Discount No. Series");
    end;

    local procedure "--- Subscription"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014455, 'InitDiscountPriority', '', true, true)]
    local procedure OnInitDiscountPriority(var DiscountPriority: Record "NPR Discount Priority")
    begin
        GetOrInit(DiscountPriority);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014455, 'ApplyDiscount', '', true, true)]
    local procedure OnApplyDiscount(DiscountPriority: Record "NPR Discount Priority"; SalePOS: Record "NPR Sale POS"; var TempSaleLinePOS: Record "NPR Sale Line POS" temporary; Rec: Record "NPR Sale Line POS"; xRec: Record "NPR Sale Line POS"; LineOperation: Option Insert,Modify,Delete; RecalculateAllLines: Boolean)
    begin
        if not IsSubscribedDiscount(DiscountPriority) then
            exit;

        ApplyQuantityDiscounts(SalePOS, TempSaleLinePOS, Rec, RecalculateAllLines);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014455, 'OnFindActiveSaleLineDiscounts', '', false, false)]
    local procedure OnFindActiveSaleLineDiscounts(var tmpDiscountPriority: Record "NPR Discount Priority" temporary; Rec: Record "NPR Sale Line POS"; xRec: Record "NPR Sale Line POS"; LineOperation: Option Insert,Modify,Delete)
    var
        QuantityDiscountHeader: Record "NPR Quantity Discount Header";
        IsActive: Boolean;
        DiscountPriority: Record "NPR Discount Priority";
    begin
        if not DiscountPriority.Get(DiscSourceTableId()) then
            exit;
        if not IsSubscribedDiscount(DiscountPriority) then
            exit;
        if not IsValidLineOperation(Rec, xRec, LineOperation) then
            exit;

        QuantityDiscountHeader.SetCurrentKey("Item No.", Status, "Starting Date", "Closing Date");
        QuantityDiscountHeader.SetRange("Item No.", Rec."No.");
        QuantityDiscountHeader.SetRange(Status, QuantityDiscountHeader.Status::Active);
        QuantityDiscountHeader.SetFilter("Starting Date", '<=%1|=%2', Today, 0D);
        QuantityDiscountHeader.SetFilter("Closing Date", '>=%1|=%2', Today, 0D);
        if not QuantityDiscountHeader.IsEmpty then begin
            tmpDiscountPriority.Init;
            tmpDiscountPriority := DiscountPriority;
            tmpDiscountPriority.Insert;
        end;
    end;

    local procedure IsValidLineOperation(Rec: Record "NPR Sale Line POS"; xRec: Record "NPR Sale Line POS"; LineOperation: Option Insert,Modify,Delete): Boolean
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        exit(true);
    end;

    local procedure IsSubscribedDiscount(DiscountPriority: Record "NPR Discount Priority"): Boolean
    begin
        if DiscountPriority.Disabled then
            exit(false);
        if DiscountPriority."Table ID" <> DiscSourceTableId() then
            exit(false);
        if (DiscountPriority."Discount Calc. Codeunit ID" <> 0) and (DiscountPriority."Discount Calc. Codeunit ID" <> DiscCalcCodeunitId()) then
            exit(false);

        exit(true);
    end;

    local procedure DiscSourceTableId(): Integer
    begin
        exit(DATABASE::"NPR Quantity Discount Header");
    end;

    local procedure DiscCalcCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR Quantity Discount Mgt.");
    end;

    local procedure DiscountActiveNow(var QuantityDiscountHeader: Record "NPR Quantity Discount Header"): Boolean
    var
        CurrDate: Date;
        CurrTime: Time;
    begin
        if QuantityDiscountHeader.IsTemporary then
            exit(false);

        if QuantityDiscountHeader.Status <> QuantityDiscountHeader.Status::Active then
            exit(false);
        if QuantityDiscountHeader."Starting Date" = 0D then
            exit(false);
        if QuantityDiscountHeader."Closing Date" = 0D then
            exit(false);

        CurrDate := Today;
        CurrTime := Time;
        if QuantityDiscountHeader."Starting Date" > CurrDate then
            exit(false);
        if QuantityDiscountHeader."Closing Date" < CurrDate then
            exit(false);
        if (QuantityDiscountHeader."Starting Date" = CurrDate) and (QuantityDiscountHeader."Starting Time" > CurrTime) then
            exit(false);
        if (QuantityDiscountHeader."Closing Date" = CurrDate) and (QuantityDiscountHeader."Closing Time" < CurrTime) then
            exit(false);

        exit(true);
    end;

    local procedure DiscountLineActiveNow(var QuantityDiscountLine: Record "NPR Quantity Discount Line"): Boolean
    var
        QuantityDiscountHeader: Record "NPR Quantity Discount Header";
    begin
        if QuantityDiscountLine.IsTemporary then
            exit(false);

        if not QuantityDiscountHeader.Get(QuantityDiscountLine."Item No.", QuantityDiscountLine."Main no.") then
            exit(false);

        exit(DiscountActiveNow(QuantityDiscountHeader));
    end;
}