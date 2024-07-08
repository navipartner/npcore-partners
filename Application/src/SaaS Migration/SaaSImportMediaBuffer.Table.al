table 6059893 "NPR SaaS Import Media Buffer"
{
    Access = Internal;
    DataClassification = CustomerContent;

    fields
    {
        field(1; PK; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2; "Media Buffer"; Media)
        {
            DataClassification = CustomerContent;
        }
        field(3; "Media Set Buffer"; MediaSet)
        {
            DataClassification = CustomerContent;
        }
    }
}