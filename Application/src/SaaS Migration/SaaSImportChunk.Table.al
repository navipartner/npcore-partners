table 6059843 "NPR SaaS Import Chunk"
{
    Caption = 'SaaS Import Chunk';
    LookupPageId = "NPR Saas Import Chunk List";
    DataClassification = CustomerContent;
    Access = Internal;

    fields
    {
        field(1; ID; Integer)
        {
            AutoIncrement = true;
            Caption = 'ID';
            DataClassification = CustomerContent;
        }
        field(2; Chunk; Blob)
        {
            Caption = 'Chunk';
            DataClassification = CustomerContent;
        }
        field(3; "Error"; Boolean)
        {
            Caption = 'Error';
            DataClassification = CustomerContent;
        }
        field(4; "Error Reason"; Text[250])
        {
            Caption = 'Error Reason';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(key1; ID)
        {
        }
        key(key2; "Error")
        {
        }
    }
}