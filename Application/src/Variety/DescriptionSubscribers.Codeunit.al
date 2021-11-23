codeunit 6059969 "NPR Description Subscribers"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Reference Management", 'OnAfterSalesItemItemRefNotFound', '', true, true)]
    local procedure ItemReferenceManagementOnAfterSalesItemItemRefNotFound(var SalesLine: Record "Sales Line"; var ItemVariant: Record "Item Variant")
    var
        ItemTranslation: Record "Item Translation";
        SalesHeader: Record "Sales Header";
        Item: Record Item;
        NPRVarietySetup: Record "NPR Variety Setup";
    begin
        if NPRVarietySetup.Get() then
            if not NPRVarietySetup."Custom Descriptions" then
                exit;

        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        if ItemTranslation.Get(SalesLine."No.", SalesLine."Variant Code", SalesHeader."Language Code") then
            exit;

        if ItemVariant.Code <> '' then begin
            Item.Get(SalesLine."No.");
            SalesLine.Description := Item.Description;
            SalesLine."Description 2" := ItemVariant.Description;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Reference Management", 'OnAfterPurchItemItemRefNotFound', '', true, true)]
    local procedure ItemReferenceManagementOnAfterPurchItemItemRefNotFound(var PurchaseLine: Record "Purchase Line"; var ItemVariant: Record "Item Variant")
    var
        ItemTranslation: Record "Item Translation";
        PurchaseHeader: Record "Purchase Header";
        Item: Record Item;
        NPRVarietySetup: Record "NPR Variety Setup";
    begin
        if NPRVarietySetup.Get() then
            if not NPRVarietySetup."Custom Descriptions" then
                exit;

        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        if ItemTranslation.Get(PurchaseLine."No.", PurchaseLine."Variant Code", PurchaseHeader."Language Code") then
            exit;

        if ItemVariant.Code <> '' then begin
            Item.Get(PurchaseLine."No.");
            PurchaseLine.Description := Item.Description;
            PurchaseLine."Description 2" := ItemVariant.Description;
        end;
    end;
}