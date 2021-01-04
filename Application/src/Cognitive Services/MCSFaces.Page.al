page 6059959 "NPR MCS Faces"
{
    // NPR5.48/JDH /20181109 CASE 334163 Added object caption

    Caption = 'MCS Faces';
    CardPageID = "NPR MCS Faces Card";
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "NPR MCS Faces";
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
                field(FaceId; FaceId)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Face Id field';
                }
                field(Gender; Gender)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gender field';
                }
                field(Age; Age)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Age field';
                }
                field("Face Height"; "Face Height")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Face Height field';
                }
                field("Face Width"; "Face Width")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Face Width field';
                }
                field("Face Position X"; "Face Position X")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Face Position X field';
                }
                field("Face Position Y"; "Face Position Y")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Face Position Y field';
                }
                field(Beard; Beard)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Beard field';
                }
                field(Sideburns; Sideburns)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sideburns field';
                }
                field(Moustache; Moustache)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Moustache field';
                }
                field(IsSmiling; IsSmiling)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Is Smiling field';
                }
                field(Glasses; Glasses)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Glasses field';
                }
                field(Identified; Identified)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Identified field';
                }
                field(Created; Created)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created field';
                }
                field(Picture; Picture)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Picture field';
                }
                field("Action"; Action)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Action field';
                }
            }
        }
    }

    actions
    {
    }
}

