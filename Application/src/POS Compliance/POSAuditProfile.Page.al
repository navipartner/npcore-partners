page 6150626 "NPR POS Audit Profile"
{
    // NPR5.54/BHR /20200228 CASE 393305 Created Card Page

    Caption = 'POS Audit Profile';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Audit Profile";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Sale Fiscal No. Series"; "Sale Fiscal No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sale Fiscal No. Series field';
                }
                field("Credit Sale Fiscal No. Series"; "Credit Sale Fiscal No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Credit Sale Fiscal No. Series field';
                }
                field("Balancing Fiscal No. Series"; "Balancing Fiscal No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balancing Fiscal No. Series field';
                }
                field("Fill Sale Fiscal No. On"; "Fill Sale Fiscal No. On")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Fill Sale Fiscal No. On field';
                }
                field("Audit Log Enabled"; "Audit Log Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Audit Log Enabled field';
                }
                field("Audit Handler"; "Audit Handler")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Audit Handler field';
                }
                field("Allow Zero Amount Sales"; "Allow Zero Amount Sales")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow Zero Amount Sales field';
                }
                field("Print Receipt On Sale Cancel"; "Print Receipt On Sale Cancel")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print Receipt On Sale Cancel field';
                }
                field("Allow Printing Receipt Copy"; "Allow Printing Receipt Copy")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow Printing Receipt Copy field';
                }
                field("Do Not Print Receipt on Sale"; "Do Not Print Receipt on Sale")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Do Not Print Receipt on Sale field';
                }
                field("Sales Ticket No. Series"; "Sales Ticket No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket No. Series field';
                }
            }
        }
    }

    actions
    {
    }
}

