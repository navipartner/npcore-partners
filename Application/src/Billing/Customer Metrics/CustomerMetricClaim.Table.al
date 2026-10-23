/// <summary>
/// Shared by the companies of an environment: the company that inserts a tenant metric's business date sends the value for it.
/// </summary>
table 6060068 "NPR Customer Metric Claim"
{
    Access = Internal;
    Caption = 'Customer Metric Claim';
    DataClassification = CustomerContent;
    DataPerCompany = false;
    Extensible = false;

    fields
    {
        field(1; Metric; Enum "NPR Customer Metric")
        {
            Caption = 'Metric';
            DataClassification = CustomerContent;
        }
        field(2; "Business Date"; Date)
        {
            Caption = 'Business Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Metric, "Business Date")
        {
            Clustered = true;
        }
    }
}
