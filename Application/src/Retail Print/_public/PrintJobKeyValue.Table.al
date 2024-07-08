table 6150783 "NPR Print Job Key Value"
{

    DataClassification = CustomerContent;

    fields
    {
        field(1; "Print Key"; Guid)
        {
            Caption = 'Print Key';
            DataClassification = CustomerContent;
        }
        field(2; "Print Job"; BLOB)
        {
            Caption = 'Print Job';
            DataClassification = CustomerContent;
        }
        field(3; "Printer HTTP Endpoint"; Text[250])
        {
            Caption = 'Printer HTTP Endpoint';
            DataClassification = CustomerContent;
        }
    }
}