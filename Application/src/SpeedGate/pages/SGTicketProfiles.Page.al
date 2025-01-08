page 6184894 "NPR SG TicketProfiles"
{
    Extensible = false;
    PageType = List;
    UsageCategory = None;
    Editable = false;
    SourceTable = "NPR SG TicketProfile";
    CardPageId = "NPR SG TicketProfile";
    Caption = 'Speedgate Ticket Profiles';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the value of the Code field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(ListBias; Rec.ValidationMode)
                {
                    ToolTip = 'Specifies the value of the ListBias field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}