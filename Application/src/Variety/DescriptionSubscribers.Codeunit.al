codeunit 6059969 "NPR Description Subscribers"
{
    Access = Internal;

    local procedure UseCustomDescription(): Boolean
    var
        NPRVarietySetup: Record "NPR Variety Setup";
    begin
        NPRVarietySetup.SetLoadFields("Custom Descriptions");
        if not NPRVarietySetup.Get() then
            exit(false);
        exit(NPRVarietySetup."Custom Descriptions");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Reference Management", 'OnAfterSalesItemItemRefNotFound', '', true, true)]
    local procedure ItemReferenceManagementOnAfterSalesItemItemRefNotFound(var SalesLine: Record "Sales Line"; var ItemVariant: Record "Item Variant")
    var
        ItemTranslation: Record "Item Translation";
        SalesHeader: Record "Sales Header";
        Item: Record Item;
    begin
        if not UseCustomDescription() then
            exit;
        if SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.") then
            if ItemTranslation.Get(SalesLine."No.", SalesLine."Variant Code", SalesHeader."Language Code") then
                exit;

        if ItemVariant.Code <> '' then begin
            Item.Get(SalesLine."No.");
            SalesLine.Description := Item.Description;
            SalesLine."Description 2" := CopyStr(ItemVariant.Description, 1, MaxStrLen(SalesLine."Description 2"));
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Reference Management", 'OnAfterPurchItemItemRefNotFound', '', true, true)]
    local procedure ItemReferenceManagementOnAfterPurchItemItemRefNotFound(var PurchaseLine: Record "Purchase Line"; var ItemVariant: Record "Item Variant")
    var
        ItemTranslation: Record "Item Translation";
        PurchaseHeader: Record "Purchase Header";
        Item: Record Item;
    begin
        if not UseCustomDescription() then
            exit;

        if PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.") then
            if ItemTranslation.Get(PurchaseLine."No.", PurchaseLine."Variant Code", PurchaseHeader."Language Code") then
                exit;

        if ItemVariant.Code <> '' then begin
            Item.Get(PurchaseLine."No.");
            PurchaseLine.Description := Item.Description;
            PurchaseLine."Description 2" := CopyStr(ItemVariant.Description, 1, MaxStrLen(PurchaseLine."Description 2"));
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Line", 'OnAfterValidateEvent', 'Variant Code', true, true)]
    local procedure TransferLineOnAfterValidateVariantCode(var Rec: Record "Transfer Line")
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
    begin
        if not UseCustomDescription() then
            exit;
        if Item.Get(Rec."Item No.") and ItemVariant.Get(Rec."Item No.", Rec."Variant Code") then begin
            Rec.Description := Item.Description;
            Rec."Description 2" := CopyStr(ItemVariant.Description, 1, MaxStrLen(Rec."Description 2"));
        end;
    end;
}
