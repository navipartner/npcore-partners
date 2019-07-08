page 6059825 "Transactional Email Log"
{
    // NPR5.38/THRO/20171018 CASE 286713 Object created

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
                field("Entry No.";"Entry No.")
                {
                }
                field("Message ID";"Message ID")
                {
                }
                field(Status;Status)
                {
                }
                field(Recipient;Recipient)
                {
                }
                field(Subject;Subject)
                {
                }
                field("Smart Email ID";"Smart Email ID")
                {
                }
                field("Sent At";"Sent At")
                {
                }
                field("Total Opens";"Total Opens")
                {
                }
                field("Total Clicks";"Total Clicks")
                {
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
                    CampaignMonitorMgt: Codeunit "CampaignMonitor Mgt.";
                begin
                    CurrPage.SetSelectionFilter(LogEntry);
                    if LogEntry.FindSet then
                      repeat
                        CampaignMonitorMgt.GetMessageDetails(LogEntry);
                      until LogEntry.Next = 0;
                end;
            }
        }
    }
}

