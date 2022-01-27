table 6059959 "NPR MCS Faces"
{
    Access = Internal;
    Caption = 'MCS Faces';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR MCS Faces";
    LookupPageID = "NPR MCS Faces Card";

    fields
    {
        field(1; PersonId; Text[50])
        {
            Caption = 'Person Id';
            DataClassification = CustomerContent;
        }
        field(2; FaceId; Text[50])
        {
            Caption = 'Face Id';
            DataClassification = CustomerContent;
        }
        field(11; Gender; Code[10])
        {
            Caption = 'Gender';
            DataClassification = CustomerContent;
        }
        field(12; Age; Decimal)
        {
            Caption = 'Age';
            DataClassification = CustomerContent;
        }
        field(13; "Face Height"; Integer)
        {
            Caption = 'Face Height';
            DataClassification = CustomerContent;
        }
        field(14; "Face Width"; Integer)
        {
            Caption = 'Face Width';
            DataClassification = CustomerContent;
        }
        field(15; "Face Position X"; Integer)
        {
            Caption = 'Face Position X';
            DataClassification = CustomerContent;
        }
        field(16; "Face Position Y"; Integer)
        {
            Caption = 'Face Position Y';
            DataClassification = CustomerContent;
        }
        field(17; Beard; Decimal)
        {
            Caption = 'Beard';
            DataClassification = CustomerContent;
        }
        field(18; Sideburns; Decimal)
        {
            Caption = 'Sideburns';
            DataClassification = CustomerContent;
        }
        field(19; Moustache; Decimal)
        {
            Caption = 'Moustache';
            DataClassification = CustomerContent;
        }
        field(20; IsSmiling; Boolean)
        {
            Caption = 'Is Smiling';
            DataClassification = CustomerContent;
        }
        field(21; Glasses; Text[50])
        {
            Caption = 'Glasses';
            DataClassification = CustomerContent;
        }
        field(22; Identified; Boolean)
        {
            Caption = 'Identified';
            DataClassification = CustomerContent;
        }
        field(23; Created; DateTime)
        {
            Caption = 'Created';
            DataClassification = CustomerContent;
        }
        field(24; Picture; BLOB)
        {
            Caption = 'Picture';
            DataClassification = CustomerContent;
            SubType = Bitmap;
            ObsoleteState = Removed;
            ObsoleteReason = 'Use Media instead of Blob type.';
        }
        field(25; "Action"; Enum "NPR MCS Faces Action")
        {
            Caption = 'Action';
            DataClassification = CustomerContent;
        }
        field(26; Image; Media)
        {
            Caption = 'Picture';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; PersonId, FaceId)
        {
        }
    }

    procedure GetImageContent(var TenantMedia: Record "Tenant Media")
    begin
        TenantMedia.Init();
        if not Rec.Image.HasValue() then
            exit;
        if TenantMedia.Get(Rec.Image.MediaId()) then
            TenantMedia.CalcFields(Content);
    end;
}

