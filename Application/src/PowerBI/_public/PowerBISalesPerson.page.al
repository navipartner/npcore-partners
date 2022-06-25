page 6184620 NPRPowerBISalesPerson_Purc
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Salesperson/Purchaser";
    Editable = false;

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