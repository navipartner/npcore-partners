table 6150656 "NPR POS Pricing Profile"
{
    Caption = 'POS Pricing Profile';
    DataClassification = CustomerContent;
    LookupPageID = "NPR POS Pricing Profiles";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(325; "Customer Disc. Group"; Code[20])
        {
            Caption = 'Customer Discount Group';
            DataClassification = CustomerContent;
            TableRelation = "Customer Discount Group";
        }
        field(328; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            DataClassification = CustomerContent;
            TableRelation = "Customer Price Group";
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }
}
