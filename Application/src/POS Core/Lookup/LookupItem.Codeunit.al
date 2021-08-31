codeunit 6014665 "NPR Lookup: Item" implements "NPR IPOSLookupType"
{
    EventSubscriberInstance = StaticAutomatic;

    var
        LookupType: Enum "NPR POS Lookup Type";
        LookupTypeGeneration: Record "NPR POS Lookup Type Generation";

    #region IPOSLookupType implementation

    procedure InitializeDataRead(var RecRef: RecordRef);
    var
        Rec: Record Item;
    begin
        Rec.SetLoadFields("No.", Description, "Description 2");
        RecRef.GetTable(Rec);
    end;

    procedure GetLookupEntry(RecRef: RecordRef) Row: JsonObject;
    var
        Rec: Record Item;
    begin
        RecRef.SetTable(Rec);
        Row.Add('id', Rec."No.");
        Row.Add('description', Rec.Description);
        Row.Add('description2', Rec."Description 2");
    end;

    procedure IsMatchForSearch(RecRef: RecordRef; SearchFilter: Text): Boolean;
    var
        Rec: Record Item;
        No: Text;
    begin
        RecRef.SetTable(Rec);

        if (Rec.Description.ToLower().Contains(SearchFilter)) then
            exit(true);
        if (Rec."Description 2".ToLower().Contains(SearchFilter)) then
            exit(true);

        No := Rec."No.";
        if (No.ToLower().Contains(SearchFilter)) then
            exit(true);

        exit(false);
    end;

    #endregion

    #region Generation monitoring event subscribers

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnItemInsert(var Rec: Record Item)
    begin
        if Rec.IsTemporary() then
            exit;

        LookupTypeGeneration.IncreaseGeneration(LookupType::Item);
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterModifyEvent', '', true, true)]
    local procedure OnItemModify(var Rec: Record Item; var xRec: Record Item)
    begin
        if Rec.IsTemporary() or ((Rec.Description = xRec.Description) and (Rec."Description 2" = xRec."Description 2")) then
            exit;

        LookupTypeGeneration.IncreaseGeneration(LookupType::Item);
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterRenameEvent', '', true, true)]
    local procedure OnItemRename(var Rec: Record Item)
    begin
        if Rec.IsTemporary() then
            exit;

        LookupTypeGeneration.IncreaseGeneration(LookupType::Item);
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnItemDelete(var Rec: Record Item)
    begin
        if Rec.IsTemporary() then
            exit;

        LookupTypeGeneration.IncreaseGeneration(LookupType::Item);
    end;

    #endregion

    #region Require lookup template

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0: Require", 'OnRequireLookupTemplate', '', true, true)]
    local procedure OnRequireLookupTemplate(TemplateCode: Text; Template: JsonObject; var Handled: Boolean)
    begin
        case TemplateCode of
            'Item':
                begin
                    Handled := true;
                    GetLookupTemplate_Item(Template);
                end;
        end
    end;

    local procedure GetLookupTemplate_Item(Template: JsonObject)
    var
        Rows: JsonArray;
        Row1: JsonObject;
        Controls: JsonArray;
        Control: JsonObject;
    begin
        Template.Add('className', 'item-lookup__entry');
        Template.Add('rows', Rows);

        Rows.Add(Row1);
        Row1.Add('className', 'item-lookup__entry-row');
        Row1.Add('controls', Controls);

        Controls.Add(Control);
        Control.Add('caption', 'Item No.');
        Control.Add('fieldNo', 'id');
        Control.Add('align', 'left');
        Control.Add('width', '15%');
        Control.Add('className', 'item-lookup__field');

        Clear(Control);
        Controls.Add(Control);
        Control.Add('caption', 'Description');
        Control.Add('fieldNo', 'description');
        Control.Add('align', 'left');
        Control.Add('width', '85%');
        Control.Add('className', 'item-lookup__field');
    end;

    #endregion
}
