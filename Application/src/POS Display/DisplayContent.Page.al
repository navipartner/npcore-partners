page 6059951 "NPR Display Content"
{
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

    Caption = 'Display Content';
    PageType = List;
    UsageCategory = Administration;
    RefreshOnActivate = true;
    SourceTable = "NPR Display Content";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Content Lines"; "Content Lines")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Content Lines field';
                }
            }
        }
    }

    actions
    {
    }
}

