table 6059952 "NPR Display Content Lines"
{
    Access = Internal;
    Caption = 'Display Content Lines';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Display Content Lines";
    LookupPageID = "NPR Display Content Lines";

    fields
    {
        field(1; "Content Code"; Code[10])
        {
            Caption = 'Content Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Display Content".Code;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(11; Url; Text[250])
        {
            Caption = 'Url';
            DataClassification = CustomerContent;
        }
        field(12; Image; BLOB)
        {
            Caption = 'Image';
            DataClassification = CustomerContent;
            SubType = Bitmap;
            ObsoleteState = Removed;
            ObsoleteReason = 'Use Media instead of Blob type.';
        }
        field(13; Picture; Media)
        {
            Caption = 'Image';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Content Code", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure GetImageContent(var TenantMedia: Record "Tenant Media")
    begin
        TenantMedia.Init();
        if not Rec.Picture.HasValue() then
            exit;
        if TenantMedia.Get(Rec.Picture.MediaId()) then
            TenantMedia.CalcFields(Content);
    end;
}

