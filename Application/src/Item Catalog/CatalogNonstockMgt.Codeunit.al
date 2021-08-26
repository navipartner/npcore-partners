codeunit 6060063 "NPR Catalog Nonstock Mgt."
{
    local procedure CopyNonstockAttributesToItem(var NonstockItem: Record "Nonstock Item")
    var
        NPRAttributeKey: Record "NPR Attribute Key";
        NPRAttributeValueSet: Record "NPR Attribute Value Set";
    begin
        NPRAttributeKey.SetRange("Table ID", DATABASE::"Nonstock Item");
        NPRAttributeKey.SetRange("MDR Code PK", NonstockItem."Entry No.");
        if NPRAttributeKey.FindSet() then
            repeat
                NPRAttributeValueSet.SetRange("Attribute Set ID", NPRAttributeKey."Attribute Set ID");
                if NPRAttributeValueSet.FindSet() then
                    repeat
                        UpdateItemAttribute(0, NonstockItem."Item No.", NPRAttributeValueSet."Attribute Code", NPRAttributeValueSet."Text Value");
                    until NPRAttributeValueSet.Next() = 0;
            until NPRAttributeKey.Next() = 0;
    end;

    procedure UpdateItemAttribute(Type: Option Item,Nonstocktem; ItemNo: Code[20]; AttributeCode: Code[20]; AttributeValue: Text[250])
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
        if not NPRAttributeKey.FindLast() then begin
            NPRAttributeKey.Init();
            NPRAttributeKey."Attribute Set ID" := 0;
            case Type of
                Type::Item:
                    NPRAttributeKey."Table ID" := DATABASE::Item;
                Type::Nonstocktem:
                    NPRAttributeKey."Table ID" := DATABASE::"Nonstock Item";
            end;
            NPRAttributeKey."MDR Code PK" := ItemNo;
            NPRAttributeKey.Insert();
        end;

        NPRAttributeValueSet.SetRange("Attribute Set ID", NPRAttributeKey."Attribute Set ID");
        NPRAttributeValueSet.SetRange("Attribute Code", AttributeCode);
        if not NPRAttributeValueSet.FindFirst() then begin
            NPRAttributeValueSet.Init();
            NPRAttributeValueSet."Attribute Set ID" := NPRAttributeKey."Attribute Set ID";
            NPRAttributeValueSet."Attribute Code" := AttributeCode;
            NPRAttributeValueSet.Insert();
        end;

        NPRAttributeValueSet."Text Value" := CopyStr(AttributeValue, 1, MaxStrLen(NPRAttributeValueSet."Text Value"));
        NPRAttributeValueSet.Modify(true);
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

