codeunit 6150976 "NPR M2 Record Change Mgt."
{
    Access = Internal;

#if not (BC17 or BC18 or BC19 or BC20)
    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterModifyEvent', '', true, true)]
    local procedure HandleItemChange(var Rec: Record Item; var xRec: Record Item)
    var
        RecordChangeLog: Record "NPR M2 Record Change Log";
    begin
        if (Rec.IsTemporary()) then
            exit;

        if (Rec."NPR Magento Item" = xRec."NPR Magento Item") then
            exit;

        case Rec."NPR Magento Item" of
            true:
                begin
                    RecordChangeLog.Init();
                    RecordChangeLog."Entry No." := 0;
                    RecordChangeLog."Type of Change" := RecordChangeLog."Type of Change"::ItemEnabled;
                    RecordChangeLog."Entity Identifier" := Rec."No.";
                    RecordChangeLog.Insert();
                end;
            false:
                begin
                    RecordChangeLog.Init();
                    RecordChangeLog."Entry No." := 0;
                    RecordChangeLog."Type of Change" := RecordChangeLog."Type of Change"::ItemDisabled;
                    RecordChangeLog."Entity Identifier" := Rec."No.";
                    RecordChangeLog.Insert();
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterDeleteEvent', '', true, true)]
    local procedure HandleItemDeletion(var Rec: Record Item)
    var
        RecordChangeLog: Record "NPR M2 Record Change Log";
    begin
        if (Rec.IsTemporary()) then
            exit;

        if (not Rec."NPR Magento Item") then
            exit;

        RecordChangeLog.Init();
        RecordChangeLog."Entry No." := 0;
        RecordChangeLog."Type of Change" := RecordChangeLog."Type of Change"::ItemDisabled;
        RecordChangeLog."Entity Identifier" := Rec."No.";
        RecordChangeLog.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterDeleteEvent', '', true, true)]
    local procedure HandleSalesLineDeletion(var Rec: Record "Sales Line")
    var
        RecordChangeLog: Record "NPR M2 Record Change Log";
        Sku: Text[250];
        Item: Record Item;
    begin
        if (Rec.IsTemporary()) then
            exit;

        // Only orders are considered in the final calculation
        if (Rec."Document Type" <> Rec."Document Type"::Order) then
            exit;

        // "Location Code" is only required for MSI integration.
        // Once we start adding more entities to this syncronization
        // then this should be converted as we may need to reegister
        // the change eitherway.
        if (Rec.Type <> Rec.Type::Item) or (Rec."Location Code" = '') then
            exit;

        Item.SetLoadFields("No.", "NPR Magento Item");
        if ((not Item.Get(Rec."No.")) or (not Item."NPR Magento Item")) then
            exit;

        Sku := Rec."No.";
        if (Rec."Variant Code" <> '') then
            Sku += ('_' + Rec."Variant Code");

        RecordChangeLog.Init();
        RecordChangeLog."Entry No." := 0;
        RecordChangeLog."Type of Change" := RecordChangeLog."Type of Change"::ResendStockData;
        RecordChangeLog."Entity Identifier" := Sku;
        RecordChangeLog."Location Code" := Rec."Location Code";
        RecordChangeLog.Insert();
    end;
#endif
}