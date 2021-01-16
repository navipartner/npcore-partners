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
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the POS Entry No. field';
                }
                field("NPR Version"; "NPR Version")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NPR Version field';
                }
                field("Store Name"; "Store Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Name field';
                }
                field("Store Name 2"; "Store Name 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Name 2 field';
                }
                field("Store Address"; "Store Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Address field';
                }
                field("Store Address 2"; "Store Address 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Address 2 field';
                }
                field("Store Post Code"; "Store Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Post Code field';
                }
                field("Store City"; "Store City")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store City field';
                }
                field("Store Siret"; "Store Siret")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Siret field';
                }
                field(APE; APE)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the APE field';
                }
                field("Intra-comm. VAT ID"; "Intra-comm. VAT ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Intra-comm. VAT ID field';
                }
                field("Salesperson Name"; "Salesperson Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Name field';
                }
            }
        }
    }

    actions
    {
    }
}

