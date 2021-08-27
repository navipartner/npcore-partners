page 6150632 "NPR POS Audit Profiles"
{
    Caption = 'POS Audit Profiles';
    CardPageID = "NPR POS Audit Profile";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR POS Audit Profile";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Sale Fiscal No. Series"; Rec."Sale Fiscal No. Series")
                {

                    ToolTip = 'Specifies the value of the Sale Fiscal No. Series field';
                    ApplicationArea = NPRRetail;
                }
                field("Credit Sale Fiscal No. Series"; Rec."Credit Sale Fiscal No. Series")
                {

                    ToolTip = 'Specifies the value of the Credit Sale Fiscal No. Series field';
                    ApplicationArea = NPRRetail;
                }
                field("Balancing Fiscal No. Series"; Rec."Balancing Fiscal No. Series")
                {

                    ToolTip = 'Specifies the value of the Balancing Fiscal No. Series field';
                    ApplicationArea = NPRRetail;
                }
                field("Fill Sale Fiscal No. On"; Rec."Fill Sale Fiscal No. On")
                {

                    ToolTip = 'Specifies the value of the Fill Sale Fiscal No. On field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Ticket No. Series"; Rec."Sales Ticket No. Series")
                {

                    ToolTip = 'Specifies the value of the Sales Ticket No. Series field';
                    ApplicationArea = NPRRetail;
                }
                field("Audit Log Enabled"; Rec."Audit Log Enabled")
                {

                    ToolTip = 'Specifies the value of the Audit Log Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Audit Handler"; Rec."Audit Handler")
                {

                    ToolTip = 'Specifies the value of the Audit Handler field';
                    ApplicationArea = NPRRetail;
                }
                field("Allow Zero Amount Sales"; Rec."Allow Zero Amount Sales")
                {

                    ToolTip = 'Specifies the value of the Allow Zero Amount Sales field';
                    ApplicationArea = NPRRetail;
                }
                field("Print Receipt On Sale Cancel"; Rec."Print Receipt On Sale Cancel")
                {

                    ToolTip = 'Specifies the value of the Print Receipt On Sale Cancel field';
                    ApplicationArea = NPRRetail;
                }
                field("Allow Printing Receipt Copy"; Rec."Allow Printing Receipt Copy")
                {

                    ToolTip = 'Specifies the value of the Allow Printing Receipt Copy field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Additional Setup for fiscalization.';
                ApplicationArea = NPRRetail;

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