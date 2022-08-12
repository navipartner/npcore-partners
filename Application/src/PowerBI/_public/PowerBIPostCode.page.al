page 6184619 NPRPowerBIPostCode
{
    PageType = List;
    Caption = 'PowerBI Post Code';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Post Code";
    Editable = false;
    ObsoleteState = pending;
    ObsoleteReason = 'Page type changed to API';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(City; Rec.City)
                {
                    ToolTip = 'Specifies the city linked to the postal code in the Code field.';
                    ApplicationArea = All;
                }
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the postal code that is associated with a city.';
                    ApplicationArea = All;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ToolTip = 'Specifies the country/region of the address.';
                    ApplicationArea = All;
                }
                field(County; Rec.County)
                {
                    ToolTip = 'Specifies a county name.';
                    ApplicationArea = All;
                }
                field("Search City"; Rec."Search City")
                {
                    ToolTip = 'Specifies the value of the Search City field.';
                    ApplicationArea = All;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                    ApplicationArea = All;
                }
                field(SystemModifiedBy; Rec.SystemModifiedBy)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedBy field.';
                    ApplicationArea = All;
                }
                field("Time Zone"; Rec."Time Zone")
                {
                    ToolTip = 'Specifies the time zone for the selected post code.';
                    ApplicationArea = All;
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedAt field.';
                    ApplicationArea = All;
                }
            }
        }
    }
}