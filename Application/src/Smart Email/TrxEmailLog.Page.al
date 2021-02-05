page 6059825 "NPR Trx Email Log"
{
    // NPR5.38/THRO/20171018 CASE 286713 Object created
    // NPR5.55/THRO/20200511 CASE 343266 Added Provider and "Status Message"

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
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field(Provider; Provider)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Provider field';
                }
                field("Message ID"; "Message ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Message ID field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Status Message"; "Status Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status Message field';
                }
                field(Recipient; Recipient)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Recipient field';
                }
                field(Subject; Subject)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Subject field';
                }
                field("Smart Email ID"; "Smart Email ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Smart Email ID field';
                }
                field("Sent At"; "Sent At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sent At field';
                }
                field("Total Opens"; "Total Opens")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Total Opens field';
                }
                field("Total Clicks"; "Total Clicks")
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
                    if LogEntry.FindSet then
                        repeat
                            //-NPR5.55 [343266]
                            TransactionalEmailMgt.GetMessageDetails(LogEntry);
                        //-NPR5.55 [343266]
                        until LogEntry.Next = 0;
                end;
            }
        }
    }
}

