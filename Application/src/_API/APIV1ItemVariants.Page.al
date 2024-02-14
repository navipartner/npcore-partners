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
                    Caption = 'Id', Locked = true;
                    Editable = false;
                }
                field(itemId; Rec."Item Id")
                {
                    Caption = 'Item Id', Locked = true;

                    trigger OnValidate()
                    begin
                        if not IsNullGuid(Item.SystemId) then
                            if Item.SystemId <> Rec."Item Id" then
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
                    Caption = 'Item No.', Locked = true;

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
                    Caption = 'Code', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }

                field(description2; Rec."Description 2")
                {
                    Caption = 'Description 2', Locked = true;
                }
                field(variety1; Rec."NPR Variety 1")
                {
                    Caption = 'Variety 1', Locked = true;
                }

                field(variety1Table; Rec."NPR Variety 1 Table")
                {
                    Caption = 'Variety 1 Table', Locked = true;
                }

                field(variety1Value; Rec."NPR Variety 1 Value")
                {
                    Caption = 'Variety 1 Value', Locked = true;
                }

                field(variety2; Rec."NPR Variety 2")
                {
                    Caption = 'Variety 2', Locked = true;
                }

                field(variety2Table; Rec."NPR Variety 2 Table")
                {
                    Caption = 'Variety 2 Table', Locked = true;
                }

                field(variety2Value; Rec."NPR Variety 2 Value")
                {
                    Caption = 'Variety 2 Value', Locked = true;
                }

                field(variety3; Rec."NPR Variety 3")
                {
                    Caption = 'Variety 3', Locked = true;
                }

                field(variety3Table; Rec."NPR Variety 3 Table")
                {
                    Caption = 'Variety 3 Table', Locked = true;
                }

                field(variety3Value; Rec."NPR Variety 3 Value")
                {
                    Caption = 'Variety 3 Value', Locked = true;
                }

                field(variety4; Rec."NPR Variety 4")
                {
                    Caption = 'Variety 4', Locked = true;
                }

                field(variety4Table; Rec."NPR Variety 4 Table")
                {
                    Caption = 'Variety 4 Table', Locked = true;
                }

                field(variety4Value; Rec."NPR Variety 4 Value")
                {
                    Caption = 'Variety 4 Value', Locked = true;
                }
#IF (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
                field(blocked; Rec."NPR Blocked")
                {
                    Caption = 'Blocked', Locked = true;
                }
#ELSE
                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked', Locked = true;
                }
#ENDIF
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
                }
                field(replicationCounter; Rec."NPR Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                    ObsoleteState = Pending;
                    ObsoleteTag = 'NPR23.0';
                    ObsoleteReason = 'Replaced by SystemRowVersion';
                }
#IF NOT (BC17 or BC18 or BC19 or BC20)
                field(systemRowVersion; Rec.SystemRowVersion)
                {
                    Caption = 'systemRowVersion', Locked = true;
                }
#ENDIF

            }
        }

    }

    actions
    {
    }

    trigger OnInit()
    begin
#IF (BC17 OR BC18 OR BC19 OR BC20 OR BC21)
        CurrentTransactionType := TransactionType::Update;
#ELSE
        Rec.ReadIsolation := IsolationLevel::ReadCommitted;
#ENDIF
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
