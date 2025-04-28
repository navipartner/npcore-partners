#if not (BC17 or BC18 or BC19 or BC20 or BC21)
page 6184958 "NPR NPEmailWebSMTPEmailAccCard"
{
    Extensible = false;
    Editable = false;
    Caption = 'NP Email Account Card';
    ApplicationArea = NPRNPEmail;
    UsageCategory = None;
    PageType = Card;
    SourceTable = "NPR NPEmailWebSMTPEmailAccount";
    DataCaptionFields = FromName;

    layout
    {
        area(Content)
        {
            field("From Name"; Rec.FromName)
            {
                ApplicationArea = NPRNPEmail;
                ToolTip = 'Specifies the value of From Name.';
            }
            field("From E-mail Address"; Rec.FromEmailAddress)
            {
                ApplicationArea = NPRNPEmail;
                ToolTip = 'Specifies the value of From E-mail Address.';
            }
        }
    }
}
#endif