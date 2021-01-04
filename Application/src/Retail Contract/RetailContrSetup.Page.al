page 6014517 "NPR Retail Contr. Setup"
{
    // NPR5.30/MHA /20170201  CASE 264918 Object renamed from Photo - Setup to Retail Contract Setup and Unused fields deleted
    // NPR5.41/TS  /20180105 CASE 300893 Removed Caption on ActionContainer

    Caption = 'Retail Contract Setup';
    SourceTable = "NPR Retail Contr. Setup";
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
                    ToolTip = 'Specifies the value of the Warranty No. Series field';
                }
                field("Repair Item No."; "Repair Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Repair Item No. field';
                }
                field("Used Goods Inventory Method"; "Used Goods Inventory Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Used Goods Inventory Method field';
                }
                field("Used Goods Serial No. Mgt."; "Used Goods Serial No. Mgt.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Used Goods Serial No. Management field';
                }
                field("Used Goods Gen. Bus. Post. Gr."; "Used Goods Gen. Bus. Post. Gr.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Used Goods Gen. Bus. Posting Group field';
                }
            }
            group(Insurance)
            {
                Caption = 'Insurance';
                field("Default Insurance Company"; "Default Insurance Company")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Insurance Company field';
                }
                field("Insurance Item No."; "Insurance Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Insurance Item No. field';
                }
                field("Print Insurance Policy"; "Print Insurance Policy")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print Insurance Policy field';
                }
                field("Check Serial No."; "Check Serial No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Check Serial No. field';
                }
                field("Check Customer No."; "Check Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Check Customer No. field';
                }
            }
            group(Contract)
            {
                Caption = 'Contract';
                field("Contract No. by"; "Contract No. by")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contract no. by field';
                }
                field("Purch. Contract"; '')
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Contract';
                    Style = Strong;
                    StyleExpr = TRUE;
                    ToolTip = 'Specifies the value of the Purch. Contract field';
                }
                field("Purch. Contract - Reason Code"; "Purch. Contract - Reason Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reason Code field';
                }
                field("Purch. Contract - Source Code"; "Purch. Contract - Source Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source Code field';
                }
                field("Rent contract"; '')
                {
                    ApplicationArea = All;
                    Caption = 'Rent contract';
                    Style = Strong;
                    StyleExpr = TRUE;
                    ToolTip = 'Specifies the value of the Rent contract field';
                }
                field("Payout pct"; "Payout pct")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payout pct field';
                }
                field("Rental Contract - Source Code"; "Rental Contract - Source Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source Code field';
                }
            }
            group("Used Goods")
            {
                Caption = 'Used Goods';
                field("Used Goods Item Tracking Code"; "Used Goods Item Tracking Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Used Goods Item Tracking Code field';
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

