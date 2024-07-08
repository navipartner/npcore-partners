table 6151407 "NPR Magento Order Status"
{
    Access = Internal;
    Caption = 'Magento Order Status';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Order No."; Code[20])
        {
            Caption = 'Order No.';
            DataClassification = CustomerContent;
        }
        field(10; "External Order No."; Code[20])
        {
            Caption = 'External Order No.';
            DataClassification = CustomerContent;
        }
        field(20; Status; Enum "NPR Magento Order Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(30; "Last Modified Date"; DateTime)
        {
            Caption = 'Last Modified Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Order No.")
        {
        }
    }
    trigger OnInsert()
    begin
        "Last Modified Date" := CurrentDateTime;
    end;

    trigger OnModify()
    begin
        "Last Modified Date" := CurrentDateTime;
    end;
}
