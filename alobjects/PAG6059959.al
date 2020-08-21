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
                field(PersonId; PersonId)
                {
                    ApplicationArea = All;
                }
                field(FaceId; FaceId)
                {
                    ApplicationArea = All;
                }
                field(Gender; Gender)
                {
                    ApplicationArea = All;
                }
                field(Age; Age)
                {
                    ApplicationArea = All;
                }
                field("Face Height"; "Face Height")
                {
                    ApplicationArea = All;
                }
                field("Face Width"; "Face Width")
                {
                    ApplicationArea = All;
                }
                field("Face Position X"; "Face Position X")
                {
                    ApplicationArea = All;
                }
                field("Face Position Y"; "Face Position Y")
                {
                    ApplicationArea = All;
                }
                field(Beard; Beard)
                {
                    ApplicationArea = All;
                }
                field(Sideburns; Sideburns)
                {
                    ApplicationArea = All;
                }
                field(Moustache; Moustache)
                {
                    ApplicationArea = All;
                }
                field(IsSmiling; IsSmiling)
                {
                    ApplicationArea = All;
                }
                field(Glasses; Glasses)
                {
                    ApplicationArea = All;
                }
                field(Identified; Identified)
                {
                    ApplicationArea = All;
                }
                field(Created; Created)
                {
                    ApplicationArea = All;
                }
                field(Picture; Picture)
                {
                    ApplicationArea = All;
                }
                field("Action"; Action)
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

