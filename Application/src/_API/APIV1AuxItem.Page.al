page 6059858 "NPR APIV1 - Aux Item"
{
    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'AuxItems';
    DelayedInsert = true;
    EntityName = 'auxItem';
    EntitySetName = 'auxItems';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR Auxiliary Item";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemID)
                {
                    Caption = 'Id', Locked = true;
                }
                field(itemAddonNo; Rec."Item Addon No.")
                {
                    Caption = 'Item AddOn No.', Locked = true;
                }
                field(magentoBrand; Rec."Magento Brand")
                {
                    Caption = 'Magento Brand', Locked = true;
                }
                field(varietyGroup; Rec."Variety Group")
                {
                    Caption = 'Variety Group', Locked = true;
                }
                field(npreItemRoutingProfile; Rec."NPRE Item Routing Profile")
                {
                    Caption = 'NPRE Item Routing Profile', Locked = true;
                }
                field(attributeSetId; Rec."Attribute Set ID")
                {
                    Caption = 'NPR Attribute Set ID', Locked = true;
                }
                field(tmTicketType; Rec."TM Ticket Type")
                {
                    Caption = 'Ticket Type', Locked = true;
                }
                field(itemStatus; Rec."Item Status")
                {
                    Caption = 'Item Status', Locked = true;
                }
                field(variety1; Rec."Variety 1")
                {
                    Caption = 'Variety 1', Locked = true;
                }
                field(variety2; Rec."Variety 2")
                {
                    Caption = 'Variety 2', Locked = true;
                }
                field(variety3; Rec."Variety 3")
                {
                    Caption = 'Variety 3', Locked = true;
                }
                field(variety4; Rec."Variety 4")
                {
                    Caption = 'Variety 4', Locked = true;
                }
                field(variety1Table; Rec."Variety 1 Table")
                {
                    Caption = 'Variety 1 Table', Locked = true;
                }
                field(variety2Table; Rec."Variety 2 Table")
                {
                    Caption = 'Variety 2 Table', Locked = true;
                }
                field(variety3Table; Rec."Variety 3 Table")
                {
                    Caption = 'Variety 3 Table', Locked = true;
                }
                field(variety4Table; Rec."Variety 4 Table")
                {
                    Caption = 'Variety 4 Table', Locked = true;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date', Locked = true;
                }
                field(replicationCounter; Rec."Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                }
            }
        }
    }

    trigger OnInit()
    begin
        CurrentTransactionType := TransactionType::Update;
    end;

}
