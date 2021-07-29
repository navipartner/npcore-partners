page 6014506 "NPR APIV1 - Item Variants"
{
    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    DelayedInsert = true;
    EntityCaption = 'Item Variant';
    EntitySetCaption = 'Item Variants';
    EntityName = 'itemVariant';
    EntitySetName = 'itemVariants';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Item Variant";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(itemId; Rec."Item Id")
                {
                    Caption = 'Item Id';

                    trigger OnValidate()
                    begin
                        if not IsNullGuid(Item.SystemId) then
                            if Item.SystemId <> "Item Id" then
                                Error(ItemValuesDontMatchErr);

                        if Rec.GetFilter("Item Id") <> '' then
                            if Rec."Item Id" <> Rec.GetFilter("Item Id") then
                                Error(ItemValuesDontMatchErr);

                        if Rec."Item Id" = BlankGuid then
                            Rec."Item No." := ''
                        else
                            if not Item.GetBySystemId(Rec."Item Id") then
                                Error(ItemIdDoesNotMatchAnEmployeeErr);
                    end;
                }
                field(itemNumber; Rec."Item No.")
                {
                    Caption = 'Item No.';

                    trigger OnValidate()
                    begin
                        if Rec."Item No." = '' then
                            Rec."Item Id" := BlankGuid
                        else
                            if not Item.Get(Rec."Item No.") then
                                Error(ItemNumberDoesNotMatchAnEmployeeErr);

                        if Rec.GetFilter("Item Id") <> '' then
                            if Item.SystemId <> Rec.GetFilter("Item Id") then
                                Error(ItemValuesDontMatchErr);
                    end;
                }
                field("code"; Rec.Code)
                {
                    Caption = 'Code';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }

                field(description2; Rec."Description 2")
                {
                    Caption = 'Description 2';
                }
                field(variety1; Rec."NPR Variety 1")
                {
                    Caption = 'Variety 1';
                }

                field(variety1Table; Rec."NPR Variety 1 Table")
                {
                    Caption = 'Variety 1 Table';
                }

                field(variety1Value; Rec."NPR Variety 1 Value")
                {
                    Caption = 'Variety 1 Value';
                }

                field(variety2; Rec."NPR Variety 2")
                {
                    Caption = 'Variety 2';
                }

                field(variety2Table; Rec."NPR Variety 2 Table")
                {
                    Caption = 'Variety 2 Table';
                }

                field(variety2Value; Rec."NPR Variety 2 Value")
                {
                    Caption = 'Variety 2 Value';
                }

                field(variety3; Rec."NPR Variety 3")
                {
                    Caption = 'Variety 3';
                }

                field(variety3Table; Rec."NPR Variety 3 Table")
                {
                    Caption = 'Variety 3 Table';
                }

                field(variety3Value; Rec."NPR Variety 3 Value")
                {
                    Caption = 'Variety 3 Value';
                }

                field(variety4; Rec."NPR Variety 4")
                {
                    Caption = 'Variety 4';
                }

                field(variety4Table; Rec."NPR Variety 4 Table")
                {
                    Caption = 'Variety 4 Table';
                }

                field(variety4Value; Rec."NPR Variety 4 Value")
                {
                    Caption = 'Variety 4 Value';
                }
                field(blocked; Rec."NPR Blocked")
                {
                    Caption = 'Blocked';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
                }

                field(replicationCounter; Rec."NPR Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                }

            }
        }

    }

    actions
    {
    }

    trigger OnInit()
    begin
        CurrentTransactionType := TransactionType::Update;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if Rec.HasFilter() then
            Rec.Validate("Item Id", Rec.GetFilter("Item Id"));
    end;

    trigger OnModifyRecord(): Boolean
    var
        ItemVariant: Record "Item Variant";
    begin
        ItemVariant.GetBySystemId(Rec.SystemId);

        if Rec."Item No." = ItemVariant."Item No." then
            Rec.Modify(true)
        else begin
            ItemVariant.TransferFields(Rec, false);
            ItemVariant.Rename(Rec."Item No.", Rec."Code");
            Rec.TransferFields(ItemVariant, true);
        end;
        exit(false);
    end;

    var
        Item: Record Item;
        ItemIdDoesNotMatchAnEmployeeErr: Label 'The "itemId" does not match to an Item.', Comment = 'itemId is a field name and should not be translated.';
        ItemNumberDoesNotMatchAnEmployeeErr: Label 'The "itemNumber" does not match to an Item.', Comment = 'itemNumber is a field name and should not be translated.';
        ItemValuesDontMatchErr: Label 'The item values do not match to a specific Item.';
        BlankGuid: Guid;
}