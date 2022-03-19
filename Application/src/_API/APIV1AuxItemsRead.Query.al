query 6014409 "NPR APIV1 - Aux Items Read"
{
    Access = Internal;
    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    EntityName = 'auxItemRead';
    EntitySetName = 'auxItemsRead';
    OrderBy = ascending(replicationCounter);
    QueryType = API;
    ReadState = ReadShared;

    elements
    {
        dataitem(auxItem; "NPR Auxiliary Item")
        {
            column(id; SystemID)
            {
                Caption = 'Id', Locked = true;
            }
            column(itemAddonNo; "Item Addon No.")
            {
                Caption = 'Item AddOn No.', Locked = true;
            }
            column(magentoBrand; "Magento Brand")
            {
                Caption = 'Magento Brand', Locked = true;
            }
            column(varietyGroup; "Variety Group")
            {
                Caption = 'Variety Group', Locked = true;
            }
            column(npreItemRoutingProfile; "NPRE Item Routing Profile")
            {
                Caption = 'NPRE Item Routing Profile', Locked = true;
            }
            column(attributeSetId; "Attribute Set ID")
            {
                Caption = 'Attribute Set ID', Locked = true;
            }
            column(tmTicketType; "TM Ticket Type")
            {
                Caption = 'Ticket Type', Locked = true;
            }
            column(itemStatus; "Item Status")
            {
                Caption = 'Item Status', Locked = true;
            }
            column(variety1; "Variety 1")
            {
                Caption = 'Variety 1', Locked = true;
            }
            column(variety2; "Variety 2")
            {
                Caption = 'Variety 2', Locked = true;
            }
            column(variety3; "Variety 3")
            {
                Caption = 'Variety 3', Locked = true;
            }
            column(variety4; "Variety 4")
            {
                Caption = 'Variety 4', Locked = true;
            }
            column(variety1Table; "Variety 1 Table")
            {
                Caption = 'Variety 1 Table', Locked = true;
            }
            column(variety2Table; "Variety 2 Table")
            {
                Caption = 'Variety 2 Table', Locked = true;
            }
            column(variety3Table; "Variety 3 Table")
            {
                Caption = 'Variety 3 Table', Locked = true;
            }
            column(variety4Table; "Variety 4 Table")
            {
                Caption = 'Variety 4 Table', Locked = true;
            }
            column(lastModifiedDateTime; SystemModifiedAt)
            {
                Caption = 'Last Modified Date', Locked = true;
            }
            column(replicationCounter; "Replication Counter")
            {
                Caption = 'replicationCounter', Locked = true;
            }
        }
    }
}
