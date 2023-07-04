table 6059842 "NPR SaaS Import Bgn. Session"
{
    Access = Internal;
    Caption = 'Saas Import Background Session';
    DataClassification = CustomerContent;
    LookupPageId = "NPR SaaS Import Bgn.Sess. List";

    fields
    {
        field(1; ChunkId; Integer)
        {
            Caption = 'Chunk ID';
            DataClassification = CustomerContent;
        }
        field(2; ServiceInstance; Integer)
        {
            Caption = 'Service Instance ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(pk; ChunkId)
        {
            Clustered = true;
        }
        key(key2; ServiceInstance)
        {
        }
    }
}