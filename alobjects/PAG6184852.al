page 6184852 "FR POS Audit Log Aux. Info"
{
    // NPR5.48/MMV /20181025 CASE 318028 Created object

    Caption = 'FR POS Audit Log Aux. Info';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "FR POS Audit Log Aux. Info";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Entry No.";"POS Entry No.")
                {
                }
                field("NPR Version";"NPR Version")
                {
                }
                field("Store Name";"Store Name")
                {
                }
                field("Store Name 2";"Store Name 2")
                {
                }
                field("Store Address";"Store Address")
                {
                }
                field("Store Address 2";"Store Address 2")
                {
                }
                field("Store Post Code";"Store Post Code")
                {
                }
                field("Store City";"Store City")
                {
                }
                field("Store Siret";"Store Siret")
                {
                }
                field(APE;APE)
                {
                }
                field("Intra-comm. VAT ID";"Intra-comm. VAT ID")
                {
                }
                field("Salesperson Name";"Salesperson Name")
                {
                }
            }
        }
    }

    actions
    {
    }
}

