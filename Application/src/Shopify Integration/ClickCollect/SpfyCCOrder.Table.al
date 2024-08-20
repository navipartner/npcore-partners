#if not BC17
table 6150814 "NPR Spfy C&C Order"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Shopify CC Order';
    ObsoleteState = Pending;
    ObsoleteTag = '2023-08-18';
    ObsoleteReason = 'Moved to a PTE as it was a customization for a specific customer.';

    fields
    {
        field(1; "Order ID"; Code[20])
        {
            Caption = 'Order ID';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "Order No."; Integer)
        {
            Caption = 'Order No.';
            DataClassification = CustomerContent;
        }
        field(10; "Shopify Store Code"; Code[20])
        {
            Caption = 'Shopify Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Spfy Store".Code;
        }
        field(20; "Collect in Store Code"; Code[20])
        {
            Caption = 'Collect in Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpCs Store".Code;
        }
        field(25; "Collect in Store Shopify ID"; Text[30])
        {
            Caption = 'Collect in Store Shopify ID';
            DataClassification = CustomerContent;
        }
        field(30; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(31; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
        }
        field(32; "Customer E-Mail"; Text[80])
        {
            Caption = 'Customer Email';
            ExtendedDatatype = EMail;
            DataClassification = CustomerContent;
        }
        field(33; "Customer Phone No."; Text[30])
        {
            Caption = 'Customer Phone No.';
            ExtendedDatatype = PhoneNo;
            DataClassification = CustomerContent;
        }
        field(40; "Np Ec Store Code"; Code[20])
        {
            Caption = 'Np E-commerce Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpEc Store".Code;
        }
        field(50; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(100; "Order Lines"; Blob)
        {
            Caption = 'Order Lines';
            DataClassification = CustomerContent;
        }
        field(200; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionMembers = " ",New,"In-Process","Order Created",Error,Deleted;
            OptionCaption = ' ,New,In-Process,Order Created,Error,Deleted';
        }
        field(210; "Last Error Message"; Blob)
        {
            Caption = 'Last Error Message';
            DataClassification = CustomerContent;
        }
        field(220; "Received from Shopify at"; DateTime)
        {
            Caption = 'Received from Shopify at';
            DataClassification = CustomerContent;
        }
        field(230; "C&C Order Created at"; DateTime)
        {
            Caption = 'CC Order Created at';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Order ID")
        {
            Clustered = true;
        }
        key(Sec1; "Order No.") { }
    }
}
#endif