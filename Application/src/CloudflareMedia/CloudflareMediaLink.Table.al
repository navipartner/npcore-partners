table 6151234 "NPR CloudflareMediaLink"
{
    Extensible = false;
    Access = Internal;
    Caption = 'NPR Cloudflare Media Link';
    DataClassification = CustomerContent;

    fields
    {
        field(1; TableNumber; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Table Number';
        }
        field(2; "RecordId"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Record ID';
        }
        field(3; MediaSelector; Enum "NPR CloudflareMediaSelector")
        {
            DataClassification = CustomerContent;
            Caption = 'Media Selector';
        }
        field(4; MediaKey; Text[200])
        {
            DataClassification = CustomerContent;
            Caption = 'Media Key';
        }

        field(10; PublicId; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Public ID';
        }
    }

    keys
    {
        key(Key1; TableNumber, RecordId, MediaSelector)
        {
            Clustered = true;
        }

        key(Key2; MediaKey)
        {
        }
        key(Key3; PublicId)
        {
        }
    }


}