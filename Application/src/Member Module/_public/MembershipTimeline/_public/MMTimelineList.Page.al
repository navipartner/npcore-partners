page 6150952 "NPR MMTimelineList"
{
    Caption = 'Membership Timeline';
    Extensible = true;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR MMTimelineEventBuffer";
    SourceTableView = Sorting(EventDateTime) Order(Descending);
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {


                field(EntryNo; Rec.EntryNo)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Entry No field.';
                    Visible = false;
                }
                field(EventType; Rec.EventType)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Event Type field.';
                    Visible = false;
                }
                field(EventDateTime; Rec.EventDateTime)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Event Date Time field.';
                }
                field(Title; Rec.Title)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Title field.';
                }
                field(Details; Rec.Details)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Details field.';
                }
                field(EventCreatedBy; Rec.EventCreatedBy)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Event Created By field.';
                }
                field(SourceSystemId; Rec.SourceSystemId)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Source System Id field.';
                    Visible = false;
                }
                field(SourceTableId; Rec.SourceTableId)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Source Table Id field.';
                    Visible = false;
                }
            }
        }
    }

    internal procedure TransferData(var TimelineEvents: Record "NPR MMTimelineEventBuffer")
    begin
        Rec.Copy(TimelineEvents, true);
        Rec.Reset();
    end;
}