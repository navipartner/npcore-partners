table 6059960 "MCS Webcam Argument Table"
{
    // NPR5.29/CLVA/20170125 CASE 264333 Added field "Image Orientation"
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj -field 12

    Caption = 'MCS Webcam Argument Table';

    fields
    {
        field(1;"Key";RecordID)
        {
            Caption = 'Key';
        }
        field(2;Name;Text[250])
        {
            Caption = 'Name';
        }
        field(3;Picture;BLOB)
        {
            Caption = 'Picture';
        }
        field(4;"Person Group Id";Text[50])
        {
            Caption = 'Person Group Id';
        }
        field(5;"Person Id";Text[50])
        {
            Caption = 'Person Id';
        }
        field(6;"Allow Saving On Identifyed";Boolean)
        {
            Caption = 'Allow Saving On Identifyed';
        }
        field(7;"Action";Option)
        {
            Caption = 'Action';
            OptionCaption = 'Capture Image,Capture And Identify Faces,Identify Faces';
            OptionMembers = CaptureImage,CaptureAndIdentifyFaces,IdentifyFaces;
        }
        field(8;"API Key 1";Text[50])
        {
            Caption = 'API Key 1';
        }
        field(9;"API Key 2";Text[50])
        {
            Caption = 'API Key 2';
        }
        field(11;"Is Identified";Boolean)
        {
            Caption = 'Is Identified';
        }
        field(12;"Table Id";Integer)
        {
            Caption = 'Table Id';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Table));
        }
        field(13;"Image Orientation";Option)
        {
            Caption = 'Image Orientation';
            OptionCaption = 'Landscape,Portrait';
            OptionMembers = Landscape,Portrait;
        }
    }

    keys
    {
        key(Key1;"Key")
        {
        }
    }

    fieldgroups
    {
    }
}

