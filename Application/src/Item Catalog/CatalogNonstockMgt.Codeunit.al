codeunit 6060063 "NPR Catalog Nonstock Mgt."
{
    // NPR5.39/BR  /20180122  CASE 295322 Object Created
    // NPR5.45/RA  /20180802  CASE 295322 Added get of Item Material that will be used to find Item group
    // NPR5.45/RA  /20180827  CASE 325023 Getting categori in a new way


    trigger OnRun()
    begin
    end;

    local procedure CopyNonstockAttributesToItem(var NonstockItem: Record "Nonstock Item")
    var
        NPRAttributeKey: Record "NPR Attribute Key";
        NPRAttributeValueSet: Record "NPR Attribute Value Set";
    begin
        NPRAttributeKey.SetRange("Table ID", DATABASE::"Nonstock Item");
        NPRAttributeKey.SetRange("MDR Code PK", NonstockItem."Entry No.");
        if NPRAttributeKey.FindSet then
            repeat
                NPRAttributeValueSet.SetRange("Attribute Set ID", NPRAttributeKey."Attribute Set ID");
                if NPRAttributeValueSet.FindFirst then
                    repeat
                        UpdateItemAttribute(0, NonstockItem."Item No.", NPRAttributeValueSet."Attribute Code", NPRAttributeValueSet."Text Value");
                    until NPRAttributeValueSet.Next = 0;
            until NPRAttributeKey.Next = 0;
    end;

    procedure UpdateItemAttribute(Type: Option Item,Nonstocktem; ItemNo: Code[20]; AttributeCode: Code[20]; AttributeValue: Text)
    var
        NPRAttributeKey: Record "NPR Attribute Key";
        NPRAttributeValueSet: Record "NPR Attribute Value Set";
    begin
        if AttributeValue = '' then
            exit;
        case Type of
            Type::Item:
                NPRAttributeKey.SetRange("Table ID", DATABASE::Item);
            Type::Nonstocktem:
                NPRAttributeKey.SetRange("Table ID", DATABASE::"Nonstock Item");
        end;
        NPRAttributeKey.SetRange("MDR Code PK", ItemNo);
        if not NPRAttributeKey.FindLast then begin
            NPRAttributeKey.Init;
            NPRAttributeKey."Attribute Set ID" := 0;
            case Type of
                Type::Item:
                    NPRAttributeKey."Table ID" := DATABASE::Item;
                Type::Nonstocktem:
                    NPRAttributeKey."Table ID" := DATABASE::"Nonstock Item";
            end;
            NPRAttributeKey."MDR Code PK" := ItemNo;
            NPRAttributeKey.Insert;
        end;

        NPRAttributeValueSet.SetRange("Attribute Set ID", NPRAttributeKey."Attribute Set ID");
        NPRAttributeValueSet.SetRange("Attribute Code", AttributeCode);
        if not NPRAttributeValueSet.FindFirst then begin
            NPRAttributeValueSet.Init;
            NPRAttributeValueSet."Attribute Set ID" := NPRAttributeKey."Attribute Set ID";
            NPRAttributeValueSet."Attribute Code" := AttributeCode;
            NPRAttributeValueSet.Insert;
        end;

        NPRAttributeValueSet."Text Value" := AttributeValue;
        NPRAttributeValueSet.Modify(true);
    end;

    local procedure "--- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertItemFillItemGroup(var Rec: Record Item; RunTrigger: Boolean)
    var
        ItemGroup: Record "NPR Item Group";
        ItemCategoryMapping: Record "NPR Item Category Mapping";
    begin
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsertItemvalidateItemGroup(var Rec: Record Item; RunTrigger: Boolean)
    var
        ItemGroup: Record "NPR Item Group";
        ItemCategoryMapping: Record "NPR Item Category Mapping";
        NonstockItemMaterial: Record "NPR Nonstock Item Material";
        NonstockItem: Record "Nonstock Item";
    begin
        if not Rec."Created From Nonstock Item" then
            exit;
        if Rec."NPR Item Group" <> '' then
            exit;
        if Rec."Item Category Code" = '' then
            exit;

        //-325023
        if Rec."Created From Nonstock Item" then begin
            NonstockItem.SetRange("Vendor No.", Rec."Vendor No.");
            NonstockItem.SetRange("Vendor Item No.", Rec."Vendor Item No.");
            //+325023
            //-NPR5.45
            //IF ItemCategoryMapping.GET(Rec."Item Category Code") THEN
            //NonstockItem.SETRANGE("Item No.", Rec."No.");
            if NonstockItem.FindFirst then begin
                if NonstockItemMaterial.Get(NonstockItem."Entry No.") then
                    //-NPR5.45
                    //IF ItemCategoryMapping.GET(Rec."Item Category Code", NonstockItemMaterial."Item Material") THEN
                    if not ItemCategoryMapping.Get(Rec."Item Category Code", NonstockItemMaterial."Item Material", NonstockItemMaterial."Item Material Density") then
                        if not ItemCategoryMapping.Get(Rec."Item Category Code", NonstockItemMaterial."Item Material") then
                            if not ItemCategoryMapping.Get(Rec."Item Category Code") then;
                //+NPR5.45
                if ItemCategoryMapping."Item Group" <> '' then
                    //+NPR5.45
                    Rec.Validate("NPR Item Group", ItemCategoryMapping."Item Group");
                //-NPR5.45
            end;
            //+NPR5.45
            Rec.Modify;
            //-325023
        end;
        //+325023
    end;

    [EventSubscriber(ObjectType::Table, 5718, 'OnAfterModifyEvent', '', true, true)]
    local procedure OnModifyItemNoUpdateAttributes(var Rec: Record "Nonstock Item"; var xRec: Record "Nonstock Item"; RunTrigger: Boolean)
    begin
        if Rec."Item No." = '' then
            exit;
        if Rec.IsTemporary then
            exit;
        CopyNonstockAttributesToItem(Rec);
    end;
}

