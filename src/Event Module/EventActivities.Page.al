page 6060153 "NPR Event Activities"
{
    // NPR5.29/NPKNAV/20170127  CASE 248723 Transport NPR5.29 - 27 januar 2017
    // NPR5.31/TJ  /20170420 CASE 269162 Completelly restructured

    Caption = 'Activities';
    PageType = CardPart;
    SourceTable = "NPR Event Cue";

    layout
    {
        area(content)
        {
            cuegroup(Control6014404)
            {
                ShowCaption = false;

                actions
                {
                    action("New Event")
                    {
                        Caption = 'New Event';
                        RunObject = Page "NPR Event Card";
                        RunPageMode = Create;
                    }
                    action("New Customer")
                    {
                        Caption = 'New Customer';
                        RunObject = Page "Customer Card";
                        RunPageMode = Create;
                    }
                }
            }
            cuegroup(Control7)
            {
                ShowCaption = false;
                field("Upcoming Events"; "Upcoming Events")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        DrillDownPage(FieldNo("Upcoming Events"));
                    end;
                }
                field("Completed Events"; "Completed Events")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        DrillDownPage(FieldNo("Completed Events"));
                    end;
                }
                field("Cancelled Events"; "Cancelled Events")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        DrillDownPage(FieldNo("Cancelled Events"));
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;

        SetFilter("Date Filter", '>=%1', WorkDate);
    end;

    local procedure DrillDownPage(FieldNo2: Integer)
    var
        EventList: Page "NPR Event List";
        Job: Record Job;
    begin
        Job.SetRange("NPR Event", true);
        case FieldNo2 of
            Rec.FieldNo("Upcoming Events"):
                Job.SetFilter("Starting Date", GetFilter("Date Filter"));
            Rec.FieldNo("Completed Events"):
                Job.SetRange("NPR Event Status", Job."NPR Event Status"::Completed);
            Rec.FieldNo("Cancelled Events"):
                Job.SetRange("NPR Event Status", Job."NPR Event Status"::Cancelled);
        end;
        EventList.SetTableView(Job);
        EventList.Run;
    end;
}

