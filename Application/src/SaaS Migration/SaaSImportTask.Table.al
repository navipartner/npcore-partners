table 6059845 "NPR SaaS Import Task"
{
    DataClassification = CustomerContent;
    LookupPageId = "NPR SaaS Import Task List";
    Caption = 'SaaS Import Task';
    Access = Internal;

    fields
    {
        field(1; ChunkId; Integer)
        {
            Caption = 'Chunk ID';
            DataClassification = CustomerContent;
        }
    }
}