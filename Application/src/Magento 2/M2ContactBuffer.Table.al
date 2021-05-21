table 6014572 "NPR M2 Contact Buffer"
{
    Caption = 'Magento Contact Buffer';
    DataClassification = CustomerContent;


    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(10; "Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(11; "Customer Name"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(20; "Contact No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(21; "Contact Name"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(22; "Contact Email"; Text[80])
        {
            DataClassification = CustomerContent;
        }
        field(30; "Magento Store Code"; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(31; "Magento Contact"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(40; "Password Reset"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(41; "Error Message"; Text[250])
        {
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }
}