page 6059959 "MCS Faces"
{
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

    Caption = 'MCS Faces';
    CardPageID = "MCS Faces Card";
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "MCS Faces";
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
                field(FaceId;FaceId)
                {
                }
                field(Gender;Gender)
                {
                }
                field(Age;Age)
                {
                }
                field("Face Height";"Face Height")
                {
                }
                field("Face Width";"Face Width")
                {
                }
                field("Face Position X";"Face Position X")
                {
                }
                field("Face Position Y";"Face Position Y")
                {
                }
                field(Beard;Beard)
                {
                }
                field(Sideburns;Sideburns)
                {
                }
                field(Moustache;Moustache)
                {
                }
                field(IsSmiling;IsSmiling)
                {
                }
                field(Glasses;Glasses)
                {
                }
                field(Identified;Identified)
                {
                }
                field(Created;Created)
                {
                }
                field(Picture;Picture)
                {
                }
                field("Action";Action)
                {
                }
            }
        }
    }

    actions
    {
    }
}

