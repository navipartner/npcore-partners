table 6151407 "Magento Order Status"
{
    // MAG1.02/HSK/20150202 CASE 201683 Object created - Contains NaviConnect Order Status
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.17/JDH /20181112 CASE 334163 Added Caption to Object and field Status
    // MAG2.18/JDH /20181112 CASE 334163 Added Caption to Object (Again)

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
        field(20; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionCaption = 'Processing,Complete,Cancelled';
            OptionMembers = Processing,Complete,Cancelled;
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

    fieldgroups
    {
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

