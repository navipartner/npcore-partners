page 6014517 "Retail Contract Setup"
{
    // NPR5.30/MHA /20170201  CASE 264918 Object renamed from Photo - Setup to Retail Contract Setup and Unused fields deleted
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer

    Caption = 'Retail Contract Setup';
    SourceTable = "Retail Contract Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group("Number Series")
            {
                Caption = 'Number Series';
                field("Warranty No. Series"; "Warranty No. Series")
                {
                    ApplicationArea = All;
                }
                field("Repair Item No."; "Repair Item No.")
                {
                    ApplicationArea = All;
                }
                field("Used Goods Inventory Method"; "Used Goods Inventory Method")
                {
                    ApplicationArea = All;
                }
                field("Used Goods Serial No. Mgt."; "Used Goods Serial No. Mgt.")
                {
                    ApplicationArea = All;
                }
                field("Used Goods Gen. Bus. Post. Gr."; "Used Goods Gen. Bus. Post. Gr.")
                {
                    ApplicationArea = All;
                }
            }
            group(Insurance)
            {
                Caption = 'Insurance';
                field("Default Insurance Company"; "Default Insurance Company")
                {
                    ApplicationArea = All;
                }
                field("Insurance Item No."; "Insurance Item No.")
                {
                    ApplicationArea = All;
                }
                field("Print Insurance Policy"; "Print Insurance Policy")
                {
                    ApplicationArea = All;
                }
                field("Check Serial No."; "Check Serial No.")
                {
                    ApplicationArea = All;
                }
                field("Check Customer No."; "Check Customer No.")
                {
                    ApplicationArea = All;
                }
            }
            group(Contract)
            {
                Caption = 'Contract';
                field("Contract No. by"; "Contract No. by")
                {
                    ApplicationArea = All;
                }
                field("Purch. Contract"; '')
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Contract';
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Purch. Contract - Reason Code"; "Purch. Contract - Reason Code")
                {
                    ApplicationArea = All;
                }
                field("Purch. Contract - Source Code"; "Purch. Contract - Source Code")
                {
                    ApplicationArea = All;
                }
                field("Rent contract"; '')
                {
                    ApplicationArea = All;
                    Caption = 'Rent contract';
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Payout pct"; "Payout pct")
                {
                    ApplicationArea = All;
                }
                field("Rental Contract - Source Code"; "Rental Contract - Source Code")
                {
                    ApplicationArea = All;
                }
            }
            group("Used Goods")
            {
                Caption = 'Used Goods';
                field("Used Goods Item Tracking Code"; "Used Goods Item Tracking Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    var
        PictureExists: Boolean;
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        Name: Text[1024];
        TextName: Text[1024];
        i: Integer;
        Text001: Label 'This will delete the old one';
}

