page 6059954 "NPR MCS Faces Card"
{

    Caption = 'MCS Faces Card';
    InsertAllowed = false;
    ModifyAllowed = false;
    UsageCategory = None;
    SourceTable = "NPR MCS Faces";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(PersonId; Rec.PersonId)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Person Id field';
                }
                field(FaceId; Rec.FaceId)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Face Id field';
                }
                field(Gender; Rec.Gender)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Gender field';
                }
                field(Age; Rec.Age)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Age field';
                }
                field("Face Height"; Rec."Face Height")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Face Height field';
                }
                field("Face Width"; Rec."Face Width")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Face Width field';
                }
                field("Face Position X"; Rec."Face Position X")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Face Position X field';
                }
                field("Face Position Y"; Rec."Face Position Y")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Face Position Y field';
                }
                field(Beard; Rec.Beard)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Beard field';
                }
                field(Sideburns; Rec.Sideburns)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sideburns field';
                }
                field(Moustache; Rec.Moustache)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Moustache field';
                }
                field(IsSmiling; Rec.IsSmiling)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Is Smiling field';
                }
                field(Glasses; Rec.Glasses)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Glasses field';
                }
                field(Identified; Rec.Identified)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Identified field';
                }
                field(Created; Rec.Created)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created field';
                }
                field(Picture; Rec.Picture)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Picture field';
                }
                field("Action"; Rec.Action)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Action field';
                }
            }
        }
    }
}

