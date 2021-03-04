page 6150626 "NPR POS Audit Profile"
{
    Caption = 'POS Audit Profile';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR POS Audit Profile";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Sales Ticket No. Series"; Rec."Sales Ticket No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket No. Series field';
                }
                field("Sale Fiscal No. Series"; Rec."Sale Fiscal No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sale Fiscal No. Series field';
                }
                field("Credit Sale Fiscal No. Series"; Rec."Credit Sale Fiscal No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Credit Sale Fiscal No. Series field';
                }
                field("Balancing Fiscal No. Series"; Rec."Balancing Fiscal No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balancing Fiscal No. Series field';
                }
                field("Fill Sale Fiscal No. On"; Rec."Fill Sale Fiscal No. On")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Fill Sale Fiscal No. On field';
                }
                field("Audit Log Enabled"; Rec."Audit Log Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Audit Log Enabled field';
                }
                field("Audit Handler"; Rec."Audit Handler")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Audit Handler field';
                }
                field("Allow Zero Amount Sales"; Rec."Allow Zero Amount Sales")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow Zero Amount Sales field';
                }
                field("Print Receipt On Sale Cancel"; Rec."Print Receipt On Sale Cancel")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Print Receipt On Sale Cancel field';
                }
                field("Allow Printing Receipt Copy"; Rec."Allow Printing Receipt Copy")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow Printing Receipt Copy field';
                }
                field("Do Not Print Receipt on Sale"; Rec."Do Not Print Receipt on Sale")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Do Not Print Receipt on Sale field';
                }
            }
        }
    }
}