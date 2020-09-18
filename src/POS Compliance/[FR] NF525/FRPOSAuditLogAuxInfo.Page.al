page 6184852 "NPR FR POS Audit Log Aux. Info"
{
    // NPR5.48/MMV /20181025 CASE 318028 Created object

    Caption = 'FR POS Audit Log Aux. Info';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR FR POS Audit Log Aux. Info";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Entry No."; "POS Entry No.")
                {
                    ApplicationArea = All;
                }
                field("NPR Version"; "NPR Version")
                {
                    ApplicationArea = All;
                }
                field("Store Name"; "Store Name")
                {
                    ApplicationArea = All;
                }
                field("Store Name 2"; "Store Name 2")
                {
                    ApplicationArea = All;
                }
                field("Store Address"; "Store Address")
                {
                    ApplicationArea = All;
                }
                field("Store Address 2"; "Store Address 2")
                {
                    ApplicationArea = All;
                }
                field("Store Post Code"; "Store Post Code")
                {
                    ApplicationArea = All;
                }
                field("Store City"; "Store City")
                {
                    ApplicationArea = All;
                }
                field("Store Siret"; "Store Siret")
                {
                    ApplicationArea = All;
                }
                field(APE; APE)
                {
                    ApplicationArea = All;
                }
                field("Intra-comm. VAT ID"; "Intra-comm. VAT ID")
                {
                    ApplicationArea = All;
                }
                field("Salesperson Name"; "Salesperson Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

