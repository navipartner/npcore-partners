page 6059954 "NPR MCS Faces Card"
{
    Caption = 'MCS Faces Card';
    InsertAllowed = false;
    ModifyAllowed = false;
    UsageCategory = None;
    SourceTable = "NPR MCS Faces";
    PageType = Card;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(PersonId; Rec.PersonId)
                {

                    ToolTip = 'Specifies the value of the Person Id field';
                    ApplicationArea = NPRRetail;
                }
                field(FaceId; Rec.FaceId)
                {

                    ToolTip = 'Specifies the value of the Face Id field';
                    ApplicationArea = NPRRetail;
                }
                field(Gender; Rec.Gender)
                {

                    ToolTip = 'Specifies the value of the Gender field';
                    ApplicationArea = NPRRetail;
                }
                field(Age; Rec.Age)
                {

                    ToolTip = 'Specifies the value of the Age field';
                    ApplicationArea = NPRRetail;
                }
                field("Face Height"; Rec."Face Height")
                {

                    ToolTip = 'Specifies the value of the Face Height field';
                    ApplicationArea = NPRRetail;
                }
                field("Face Width"; Rec."Face Width")
                {

                    ToolTip = 'Specifies the value of the Face Width field';
                    ApplicationArea = NPRRetail;
                }
                field("Face Position X"; Rec."Face Position X")
                {

                    ToolTip = 'Specifies the value of the Face Position X field';
                    ApplicationArea = NPRRetail;
                }
                field("Face Position Y"; Rec."Face Position Y")
                {

                    ToolTip = 'Specifies the value of the Face Position Y field';
                    ApplicationArea = NPRRetail;
                }
                field(Beard; Rec.Beard)
                {

                    ToolTip = 'Specifies the value of the Beard field';
                    ApplicationArea = NPRRetail;
                }
                field(Sideburns; Rec.Sideburns)
                {

                    ToolTip = 'Specifies the value of the Sideburns field';
                    ApplicationArea = NPRRetail;
                }
                field(Moustache; Rec.Moustache)
                {

                    ToolTip = 'Specifies the value of the Moustache field';
                    ApplicationArea = NPRRetail;
                }
                field(IsSmiling; Rec.IsSmiling)
                {

                    ToolTip = 'Specifies the value of the Is Smiling field';
                    ApplicationArea = NPRRetail;
                }
                field(Glasses; Rec.Glasses)
                {

                    ToolTip = 'Specifies the value of the Glasses field';
                    ApplicationArea = NPRRetail;
                }
                field(Identified; Rec.Identified)
                {

                    ToolTip = 'Specifies the value of the Identified field';
                    ApplicationArea = NPRRetail;
                }
                field(Created; Rec.Created)
                {

                    ToolTip = 'Specifies the value of the Created field';
                    ApplicationArea = NPRRetail;
                }
                field("Action"; Rec.Action)
                {

                    ToolTip = 'Specifies the value of the Action field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(factboxes)
        {
            part(MCSFacesImage; "NPR MCS Faces Image")
            {

                Caption = 'Image';
                SubPageLink = PersonId = field(PersonId),
                                FaceId = Field(FaceId);
                ApplicationArea = NPRRetail;
            }
        }
    }
}

