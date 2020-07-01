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
                }
                field("Repair Item No."; "Repair Item No.")
                {
                }
                field("Used Goods Inventory Method"; "Used Goods Inventory Method")
                {
                }
                field("Used Goods Serial No. Mgt."; "Used Goods Serial No. Mgt.")
                {
                }
                field("Used Goods Gen. Bus. Post. Gr."; "Used Goods Gen. Bus. Post. Gr.")
                {
                }
            }
            group(Insurance)
            {
                Caption = 'Insurance';
                field("Default Insurance Company"; "Default Insurance Company")
                {
                }
                field("Insurance Item No."; "Insurance Item No.")
                {
                }
                field("Print Insurance Policy"; "Print Insurance Policy")
                {
                }
                field("Check Serial No."; "Check Serial No.")
                {
                }
                field("Check Customer No."; "Check Customer No.")
                {
                }
            }
            group(Contract)
            {
                Caption = 'Contract';
                field("Contract No. by"; "Contract No. by")
                {
                }
                field("Purch. Contract"; '')
                {
                    Caption = 'Purch. Contract';
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Purch. Contract - Reason Code"; "Purch. Contract - Reason Code")
                {
                }
                field("Purch. Contract - Source Code"; "Purch. Contract - Source Code")
                {
                }
                field("Rent contract"; '')
                {
                    Caption = 'Rent contract';
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Payout pct"; "Payout pct")
                {
                }
                field("Rental Contract - Source Code"; "Rental Contract - Source Code")
                {
                }
            }
            group("Used Goods")
            {
                Caption = 'Used Goods';
                field("Used Goods Item Tracking Code"; "Used Goods Item Tracking Code")
                {
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

