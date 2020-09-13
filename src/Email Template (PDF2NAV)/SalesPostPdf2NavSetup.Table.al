table 6014469 "NPR SalesPost Pdf2Nav Setup"
{
    // NPR5.36/THRO/20170908 CASE 285645 Setup for Pdf2Nav Posting

    Caption = 'Sales-Post and Pdf2Nav Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(10; "Post and Send"; Option)
        {
            Caption = 'Post and Send';
            OptionCaption = 'Both Std. NAV and Pdf2Nav,Std. NAV Only,Pdf2Nav Only';
            OptionMembers = "Both Std. NAV and Pdf2Nav","Std. NAV Only","Pdf2Nav Only";
            DataClassification = CustomerContent;
        }
        field(20; "Always Print Ship"; Boolean)
        {
            Caption = 'Always Print Sales Shipment';
            InitValue = true;
            DataClassification = CustomerContent;
        }
        field(21; "Always Print Receive"; Boolean)
        {
            Caption = 'Always Print Sales Return Receipt';
            InitValue = true;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }
}

