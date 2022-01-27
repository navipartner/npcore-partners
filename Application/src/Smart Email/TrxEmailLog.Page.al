page 6059825 "NPR Trx Email Log"
{
    Extensible = False;
    Caption = 'Transactional Email Log';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR Trx Email Log";
    UsageCategory = History;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Provider; Rec.Provider)
                {

                    ToolTip = 'Specifies the value of the Provider field';
                    ApplicationArea = NPRRetail;
                }
                field("Message ID"; Rec."Message ID")
                {

                    ToolTip = 'Specifies the value of the Message ID field';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Status Message"; Rec."Status Message")
                {

                    ToolTip = 'Specifies the value of the Status Message field';
                    ApplicationArea = NPRRetail;
                }
                field(Recipient; Rec.Recipient)
                {

                    ToolTip = 'Specifies the value of the Recipient field';
                    ApplicationArea = NPRRetail;
                }
                field(Subject; Rec.Subject)
                {

                    ToolTip = 'Specifies the value of the Subject field';
                    ApplicationArea = NPRRetail;
                }
                field("Smart Email ID"; Rec."Smart Email ID")
                {

                    ToolTip = 'Specifies the value of the Smart Email ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Sent At"; Rec."Sent At")
                {

                    ToolTip = 'Specifies the value of the Sent At field';
                    ApplicationArea = NPRRetail;
                }
                field("Total Opens"; Rec."Total Opens")
                {

                    ToolTip = 'Specifies the value of the Total Opens field';
                    ApplicationArea = NPRRetail;
                }
                field("Total Clicks"; Rec."Total Clicks")
                {

                    ToolTip = 'Specifies the value of the Total Clicks field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Update Details")
            {
                Caption = 'Update Details';
                Image = Process;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                ToolTip = 'Executes the Update Details action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    LogEntry: Record "NPR Trx Email Log";
                    TransactionalEmailMgt: Codeunit "NPR Transactional Email Mgt.";
                begin
                    CurrPage.SetSelectionFilter(LogEntry);
                    if LogEntry.FindSet() then
                        repeat
                            TransactionalEmailMgt.GetMessageDetails(LogEntry);
                        until LogEntry.Next() = 0;
                end;
            }
        }
    }
}

