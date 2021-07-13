page 6060153 "NPR Event Activities"
{
    Caption = 'Activities';
    PageType = CardPart;
    UsageCategory = Administration;

    SourceTable = "NPR Event Cue";
    ApplicationArea = NPRRetail;

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

                        Image = TileNew;
                        ToolTip = 'Creates a new event';
                        ApplicationArea = NPRRetail;
                    }
                    action("New Customer")
                    {
                        Caption = 'New Customer';
                        RunObject = Page "Customer Card";
                        RunPageMode = Create;

                        Image = TilePeople;
                        ToolTip = 'Creates a new customer';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            cuegroup(Control7)
            {
                ShowCaption = false;
                field("Upcoming Events"; Rec."Upcoming Events")
                {

                    ToolTip = 'Specifies the value of the Upcoming Events field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        DrillDownPage(Rec.FieldNo("Upcoming Events"));
                    end;
                }
                field("Completed Events"; Rec."Completed Events")
                {

                    ToolTip = 'Specifies the value of the Completed Events field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        DrillDownPage(Rec.FieldNo("Completed Events"));
                    end;
                }
                field("Cancelled Events"; Rec."Cancelled Events")
                {

                    ToolTip = 'Specifies the value of the Cancelled Events field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        DrillDownPage(Rec.FieldNo("Cancelled Events"));
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;

        Rec.SetFilter("Date Filter", '>=%1', WorkDate());
    end;

    local procedure DrillDownPage(FieldNo2: Integer)
    var
        EventList: Page "NPR Event List";
        Job: Record Job;
    begin
        Job.SetRange("NPR Event", true);
        case FieldNo2 of
            Rec.FieldNo("Upcoming Events"):
                Job.SetFilter("Starting Date", Rec.GetFilter("Date Filter"));
            Rec.FieldNo("Completed Events"):
                Job.SetRange("NPR Event Status", Job."NPR Event Status"::Completed);
            Rec.FieldNo("Cancelled Events"):
                Job.SetRange("NPR Event Status", Job."NPR Event Status"::Cancelled);
        end;
        EventList.SetTableView(Job);
        EventList.Run();
    end;
}

