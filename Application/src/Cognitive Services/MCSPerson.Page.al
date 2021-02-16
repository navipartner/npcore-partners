page 6059958 "NPR MCS Person"
{

    Caption = 'MCS Person';
    PageType = List;
    SourceTable = "NPR MCS Person";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(PersonId; Rec.PersonId)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Person Id field';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(UserData; Rec.UserData)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User Data field';
                }
                field(PersonGroupId; Rec.PersonGroupId)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Person Group Id field';
                }
                field(Faces; Rec.Faces)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Faces field';
                }
            }
        }
    }
}

