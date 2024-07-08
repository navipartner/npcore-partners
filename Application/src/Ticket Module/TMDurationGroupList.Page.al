page 6060149 "NPR TM DurationGroupList"
{
    Extensible = False;
    PageType = List;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    UsageCategory = Administration;
    SourceTable = "NPR TM DurationGroup";
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/intro/';
    Editable = true;
    Caption = 'Ticket Duration Group';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                Caption = 'Duration Groups';
                field("Code"; Rec.Code)
                {
                    ToolTip = 'This field specifies the Duration Group Code.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'This field specifies the intended usage of this duration group.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(DurationMinutes; Rec.DurationMinutes)
                {
                    ToolTip = 'Specifies a duration in minutes for which this ticket admission should be valid. Duration can extend validity beyond the scheduled time slot.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(SynchronizedActivation; Rec.SynchronizedActivation)
                {
                    ToolTip = 'Specifies how other admissions on this ticket is effected by arrival on this admissions.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(AlignmentSource; Rec.AlignmentSource)
                {
                    ToolTip = 'Determines which admission schedule will be used when fetching start time and end time.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(AlignEarlyArrivalOn; Rec.AlignEarlyArrivalOn)
                {
                    ToolTip = 'Specifies how the start time of duration is calculated when you arrive before scheduled start time.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(AlignLateArrivalOn; Rec.AlignLateArrivalOn)
                {
                    ToolTip = 'Specifies how the start time of duration is calculated when you arrive after scheduled end time.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(CapOnEndTime; Rec.CapOnEndTime)
                {
                    ToolTip = 'Specifies if the duration should be capped by schedule end time.';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
            }
        }
    }
}