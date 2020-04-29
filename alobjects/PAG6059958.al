page 6059958 "MCS Person"
{
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

    Caption = 'MCS Person';
    PageType = List;
    SourceTable = "MCS Person";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(PersonId;PersonId)
                {
                }
                field(Name;Name)
                {
                }
                field(UserData;UserData)
                {
                }
                field(PersonGroupId;PersonGroupId)
                {
                }
                field(Faces;Faces)
                {
                }
            }
        }
    }

    actions
    {
    }
}

