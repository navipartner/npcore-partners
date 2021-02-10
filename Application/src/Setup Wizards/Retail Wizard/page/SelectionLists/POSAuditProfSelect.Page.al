page 6059779 "NPR POS Audit Prof. Select"
{
    Caption = 'POS Audit Profiles';
    PageType = List;
    SourceTable = "NPR POS Audit Profile";
    SourceTableTemporary = true;
    DelayedInsert = true;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = All;
                }
                field("Sale Fiscal No. Series"; "Sale Fiscal No. Series")
                {
                    ToolTip = 'Specifies the value of the Sale Fiscal No. Series field';
                    ApplicationArea = All;
                }
                field("Credit Sale Fiscal No. Series"; "Credit Sale Fiscal No. Series")
                {
                    ToolTip = 'Specifies the value of the Credit Sale Fiscal No. Series field';
                    ApplicationArea = All;
                }
                field("Balancing Fiscal No. Series"; "Balancing Fiscal No. Series")
                {
                    ToolTip = 'Specifies the value of the Balancing Fiscal No. Series field';
                    ApplicationArea = All;
                }
                field("Fill Sale Fiscal No. On"; "Fill Sale Fiscal No. On")
                {
                    ToolTip = 'Specifies the value of the Fill Sale Fiscal No. On field';
                    ApplicationArea = All;
                }
                field("Sales Ticket No. Series"; "Sales Ticket No. Series")
                {
                    ToolTip = 'Specifies the value of the Sales Ticket No. Series field';
                    ApplicationArea = All;
                }
                field("Audit Log Enabled"; "Audit Log Enabled")
                {
                    ToolTip = 'Specifies the value of the Audit Log Enabled field';
                    ApplicationArea = All;
                }
                field("Audit Handler"; "Audit Handler")
                {
                    ToolTip = 'Specifies the value of the Audit Handler field';
                    ApplicationArea = All;
                }
                field("Allow Zero Amount Sales"; "Allow Zero Amount Sales")
                {
                    ToolTip = 'Specifies the value of the Allow Zero Amount Sales field';
                    ApplicationArea = All;
                }
                field("Print Receipt On Sale Cancel"; "Print Receipt On Sale Cancel")
                {
                    ToolTip = 'Specifies the value of the Print Receipt On Sale Cancel field';
                    ApplicationArea = All;
                }
                field("Do Not Print Receipt on Sale"; "Do Not Print Receipt on Sale")
                {
                    ToolTip = 'Specifies the value of the Do Not Print Receipt on Sale field';
                    ApplicationArea = All;
                }
                field("Allow Printing Receipt Copy"; "Allow Printing Receipt Copy")
                {
                    ToolTip = 'Specifies the value of the Allow Printing Receipt Copy field';
                    ApplicationArea = All;
                }
            }
        }
    }
    procedure SetRec(var TempPOSAuditProfile: Record "NPR POS Audit Profile")
    begin
        if TempPOSAuditProfile.FindSet() then
            repeat
                Rec.Copy(TempPOSAuditProfile);
                Rec.Insert();
            until TempPOSAuditProfile.Next() = 0;

        if Rec.FindSet() then;
    end;
}