page 6059825 "NPR Trx Email Log"
{
    Caption = 'Transactional Email Log';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR Trx Email Log";
    UsageCategory = History;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field(Provider; Rec.Provider)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Provider field';
                }
                field("Message ID"; Rec."Message ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Message ID field';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Status Message"; Rec."Status Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status Message field';
                }
                field(Recipient; Rec.Recipient)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Recipient field';
                }
                field(Subject; Rec.Subject)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Subject field';
                }
                field("Smart Email ID"; Rec."Smart Email ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Smart Email ID field';
                }
                field("Sent At"; Rec."Sent At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sent At field';
                }
                field("Total Opens"; Rec."Total Opens")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Total Opens field';
                }
                field("Total Clicks"; Rec."Total Clicks")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Total Clicks field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Update Details action';

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

