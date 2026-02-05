page 6060153 "NPR Event Activities"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Extensible = False;
    Caption = 'Activities';
    PageType = CardPart;
    UsageCategory = None;
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
                field("Event List"; Rec."Event List")
                {

                    ToolTip = 'Specifies the number of the events. By clicking you can view the list of events.';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        DrillDownPage(Rec.FieldNo("Event List"));
                    end;
                }
                field("Completed Events"; Rec."Completed Events")
                {

                    ToolTip = 'Specifies the number of the Completed Events. By clicking you can view the list of Completed Events.';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        DrillDownPage(Rec.FieldNo("Completed Events"));
                    end;
                }
                field("Cancelled Events"; Rec."Cancelled Events")
                {

                    ToolTip = 'Specifies the number of the Cancelled Events. By clicking you can view the list of Cancelled Events.';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        DrillDownPage(Rec.FieldNo("Cancelled Events"));
                    end;
                }
                field("Upcoming Events"; Rec."Upcoming Events")
                {
                    Caption = 'Upcoming  Events';
                    ToolTip = 'Specifies the number of the Upcoming Events. By clicking you can view the list of Upcoming Events.';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        DrillDownPage(Rec.FieldNo("Upcoming Events"));
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;

        Rec.SetFilter("Date Filter", '>=%1', WorkDate());
        ConfPersonalizationMgt.RaiseOnOpenRoleCenterEvent();
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

