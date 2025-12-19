table 6151252 "NPR CloudflareMigrationJobLine"
{
    Extensible = false;
    Access = Internal;
    Caption = 'NPR Cloudflare Migration Job Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; JobId; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Job Id';
        }
        field(2; PublicId; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Public Id';
        }
        field(3; BatchId; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Batch Id';
        }
        field(10; Status; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Status';
            OptionMembers = PENDING,QUEUED,SUCCESS,FAILED,FINALIZED;
            OptionCaption = 'Pending,Queued,Success,Failed,Finalized';
            InitValue = Pending;
        }

        field(20; ImageUrl; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Image Url';
        }
        field(25; ContentType; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Content Type';
        }

        field(26; FileSize; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'File Size';
        }
        field(30; MediaKey; Text[200])
        {
            DataClassification = CustomerContent;
            Caption = 'Media Key';
        }

        field(45; Reason; Text[200])
        {
            DataClassification = CustomerContent;
            Caption = 'Reason';
        }
    }



    keys
    {
        key(Key1; JobId, PublicId)
        {
            Clustered = true;
        }

        key(Key2; BatchId) { }
    }




}