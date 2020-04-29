table 6059959 "MCS Faces"
{
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to object

    Caption = 'MCS Faces';
    DrillDownPageID = "MCS Faces";
    LookupPageID = "MCS Faces Card";

    fields
    {
        field(1;PersonId;Text[50])
        {
            Caption = 'Person Id';
        }
        field(2;FaceId;Text[50])
        {
            Caption = 'Face Id';
        }
        field(11;Gender;Code[10])
        {
            Caption = 'Gender';
        }
        field(12;Age;Decimal)
        {
            Caption = 'Age';
        }
        field(13;"Face Height";Integer)
        {
            Caption = 'Face Height';
        }
        field(14;"Face Width";Integer)
        {
            Caption = 'Face Width';
        }
        field(15;"Face Position X";Integer)
        {
            Caption = 'Face Position X';
        }
        field(16;"Face Position Y";Integer)
        {
            Caption = 'Face Position Y';
        }
        field(17;Beard;Decimal)
        {
            Caption = 'Beard';
        }
        field(18;Sideburns;Decimal)
        {
            Caption = 'Sideburns';
        }
        field(19;Moustache;Decimal)
        {
            Caption = 'Moustache';
        }
        field(20;IsSmiling;Boolean)
        {
            Caption = 'Is Smiling';
        }
        field(21;Glasses;Text[50])
        {
            Caption = 'Glasses';
        }
        field(22;Identified;Boolean)
        {
            Caption = 'Identified';
        }
        field(23;Created;DateTime)
        {
            Caption = 'Created';
        }
        field(24;Picture;BLOB)
        {
            Caption = 'Picture';
            SubType = Bitmap;
        }
        field(25;"Action";Option)
        {
            Caption = 'Action';
            OptionCaption = 'Capture Image,Capture And Identify Faces,Identify Faces';
            OptionMembers = CaptureImage,CaptureAndIdentifyFaces,IdentifyFaces;
        }
    }

    keys
    {
        key(Key1;PersonId,FaceId)
        {
        }
    }

    fieldgroups
    {
    }
}

