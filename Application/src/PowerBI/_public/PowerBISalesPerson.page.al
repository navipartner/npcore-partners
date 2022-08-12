page 6184620 NPRPowerBISalesPerson_Purc
{
    PageType = List;
    Caption = 'PowerBI SalesPerson/Purchaser';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Salesperson/Purchaser";
    Editable = false;
    ObsoleteState = pending;
    ObsoleteReason = 'Page type changed to API';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies a code for the salesperson or purchaser.';
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the name of the salesperson or purchaser.';
                    ApplicationArea = All;
                }
            }
        }
    }
}