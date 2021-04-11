page 6150632 "NPR POS Audit Profiles"
{
    Caption = 'POS Audit Profiles';
    CardPageID = "NPR POS Audit Profile";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Audit Profile";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
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
                field("Sales Ticket No. Series"; Rec."Sales Ticket No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Ticket No. Series field';
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
                field("Do Not Print Receipt on Sale"; Rec."Do Not Print Receipt on Sale")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Do Not Print Receipt on Sale field';
                }
                field("Allow Printing Receipt Copy"; Rec."Allow Printing Receipt Copy")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Allow Printing Receipt Copy field';
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(Setup)
            {
                Caption = 'Additional Setup';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Additional Setup for fiscalization.';

                trigger OnAction()
                begin
                    OnHandlePOSAuditProfileAdditionalSetup(Rec);
                end;
            }
        }
    }

    [IntegrationEvent(false, false)]
    local procedure OnHandlePOSAuditProfileAdditionalSetup(POSAuditProfile: Record "NPR POS Audit Profile")
    begin
    end;
}