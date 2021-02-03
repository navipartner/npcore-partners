codeunit 6014445 "NPR Event Subscriber (Sales)"
{
    var
        SalesHeaderFetched: Boolean;
        SalesHeader: Record "Sales Header";

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Prices Including VAT', false, false)]
    local procedure SalesHeaderPricesIncludingVATOnAfterValidate(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    var
        SalesLine: Record "Sales Line";
    begin
        if Rec."Prices Including VAT" <> xRec."Prices Including VAT" then begin
            SalesHeaderFetched := true;
            SalesHeader := Rec;
            SalesLine.SetRange("Document Type", Rec."Document Type");
            SalesLine.SetRange("Document No.", Rec."No.");
            SalesLine.SetRange(Type, SalesLine.Type::Item);
            if SalesLine.FindSet then
                repeat
                    if CalcItemGroupUnitCost(SalesLine) then
                        SalesLine.Modify;
                until SalesLine.Next = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'Unit Price', false, false)]
    local procedure SalesLineUnitPriceOnAfterValidate(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        CalcItemGroupUnitCost(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'VAT Prod. Posting Group', false, false)]
    local procedure SalesLineVATProdPostingGroupOnAfterValidate(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        CalcItemGroupUnitCost(Rec);
    end;

    local procedure CalcItemGroupUnitCost(var Rec: Record "Sales Line"): Boolean
    var
        Item: Record Item;
        VATPercent: Decimal;
    begin
        if (Rec.Type <> Rec.Type::Item) or (Rec."Profit %" = 0) then
            exit(false);

        Item.Get(Rec."No.");
        if not (Item."NPR Group sale" or (Item."Unit Cost" = 0)) then
            exit(false);

        if not SalesHeaderFetched then
            SalesHeader.Get(Rec."Document Type", Rec."Document No.");

        if SalesHeader."Prices Including VAT" then
            VATPercent := Rec."VAT %";
        Rec.Validate("Unit Cost (LCY)", ((1 - Rec."Profit %" / 100) * Rec."Unit Price" / (1 + VATPercent / 100)) * Rec."Qty. per Unit of Measure");
        exit(true);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order", 'OnAfterActionEvent', 'NPR PrintShippingLabel', false, false)]
    local procedure SalesOrderOnAfterActionEventPrintShippingLabel(var Rec: Record "Sales Header")
    var
        LabelLibrary: Codeunit "NPR Label Library";
        RecRef: RecordRef;
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader := Rec;
        SalesHeader.SetRecFilter;
        RecRef.GetTable(SalesHeader);
        LabelLibrary.PrintCustomShippingLabel(RecRef, '');
    end;
}

