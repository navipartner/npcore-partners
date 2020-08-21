page 6059825 "Transactional Email Log"
{
    // NPR5.38/THRO/20171018 CASE 286713 Object created
    // NPR5.55/THRO/20200511 CASE 343266 Added Provider and "Status Message"

    Caption = 'Transactional Email Log';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Transactional Email Log";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field(Provider; Provider)
                {
                    ApplicationArea = All;
                }
                field("Message ID"; "Message ID")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Status Message"; "Status Message")
                {
                    ApplicationArea = All;
                }
                field(Recipient; Recipient)
                {
                    ApplicationArea = All;
                }
                field(Subject; Subject)
                {
                    ApplicationArea = All;
                }
                field("Smart Email ID"; "Smart Email ID")
                {
                    ApplicationArea = All;
                }
                field("Sent At"; "Sent At")
                {
                    ApplicationArea = All;
                }
                field("Total Opens"; "Total Opens")
                {
                    ApplicationArea = All;
                }
                field("Total Clicks"; "Total Clicks")
                {
                    ApplicationArea = All;
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

                trigger OnAction()
                var
                    LogEntry: Record "Transactional Email Log";
                    TransactionalEmailMgt: Codeunit "Transactional Email Mgt.";
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

