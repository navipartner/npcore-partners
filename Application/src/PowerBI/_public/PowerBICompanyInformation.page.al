page 6184600 NPRPowerBICompanyInformaion
{
    PageType = List;
    Caption = 'PowerBI Company Informaion';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Company Information";
    Editable = false;
    ObsoleteState = pending;
    ObsoleteReason = 'Page type changed to API';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the name of your company.';
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ToolTip = 'Specifies the location code that corresponds to the company''s ship-to address.';
                    ApplicationArea = All;
                }
            }
        }
    }
}