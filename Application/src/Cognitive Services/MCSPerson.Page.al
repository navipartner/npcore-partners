page 6059958 "NPR MCS Person"
{
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

    Caption = 'MCS Person';
    PageType = List;
    SourceTable = "NPR MCS Person";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(PersonId; PersonId)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Person Id field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(UserData; UserData)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User Data field';
                }
                field(PersonGroupId; PersonGroupId)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Person Group Id field';
                }
                field(Faces; Faces)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Faces field';
                }
            }
        }
    }

    actions
    {
    }
}

