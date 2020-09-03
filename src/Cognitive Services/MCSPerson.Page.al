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
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field(UserData; UserData)
                {
                    ApplicationArea = All;
                }
                field(PersonGroupId; PersonGroupId)
                {
                    ApplicationArea = All;
                }
                field(Faces; Faces)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

