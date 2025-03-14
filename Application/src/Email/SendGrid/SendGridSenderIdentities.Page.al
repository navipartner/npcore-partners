#if not (BC17 or BC18 or BC19 or BC20 or BC21)
page 6184952 "NPR SendGrid Sender Identities"
{
    Extensible = false;
    Caption = 'SendGrid Sender Identities';
    ApplicationArea = NPRNPEmail;
    UsageCategory = None;
    PageType = List;
    DataCaptionFields = Nickname;
    SourceTable = "NPR SendGrid Sender Identity";

    layout
    {
        area(Content)
        {
            repeater(IdentityRepeater)
            {
                field(Id; Rec.Id)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the id';
                }
                field(Nickname; Rec.Nickname)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the nickname';
                }
                field("From E-mail Address"; Rec.FromEmailAddress)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the from e-mail address';
                }
                field(Verified; Rec.Verified)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the verified';
                }
            }
        }
    }
}
#endif