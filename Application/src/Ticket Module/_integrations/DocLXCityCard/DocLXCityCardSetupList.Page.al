page 6184579 "NPR DocLXCityCardSetupList"
{
    Caption = 'DocLX City Card Setup';
    Extensible = false;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR DocLXCityCardSetup";


    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the code of the City Card Setup.';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the City field.';
                }
                field(Environment; Rec.Environment)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Environment field.';
                }
            }
        }
    }

}