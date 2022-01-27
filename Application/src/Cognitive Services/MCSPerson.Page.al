page 6059958 "NPR MCS Person"
{
    Extensible = False;

    Caption = 'MCS Person';
    PageType = List;
    SourceTable = "NPR MCS Person";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(PersonId; Rec.PersonId)
                {

                    ToolTip = 'Specifies the value of the Person Id field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field(UserData; Rec.UserData)
                {

                    ToolTip = 'Specifies the value of the User Data field';
                    ApplicationArea = NPRRetail;
                }
                field(PersonGroupId; Rec.PersonGroupId)
                {

                    ToolTip = 'Specifies the value of the Person Group Id field';
                    ApplicationArea = NPRRetail;
                }
                field(Faces; Rec.Faces)
                {

                    ToolTip = 'Specifies the value of the Faces field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

