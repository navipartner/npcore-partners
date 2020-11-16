table 6151413 "NPR Magento Payment Gateway"
{
    // MAG1.20/MHA /20150826  CASE 219645 Object created
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.01/MHA /20160928  CASE 250694 Added Field 30 "Refund Codeunit Id" and 35 "Cancel Codeunit Id"
    // MAG2.01/TR  /20160710  CASE 254565 Removed InitValue for "Api Url"
    // MAG2.17/JDH /20181112  CASE 334163 Added Caption to Object
    // MAG2.20/MHA /20190502  CASE 352184 Added field 15 "Merchant Name"
    // MAG2.24/MHA /20191202  CASE 377969 Extended length for field 7 "Api Password" from 100 to 250

    Caption = 'Magento Payment Gateway';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(5; "Api Url"; Text[250])
        {
            Caption = 'Api Url';
            DataClassification = CustomerContent;
            Description = 'MAG2.01';
        }
        field(6; "Api Username"; Text[100])
        {
            Caption = 'Api Username';
            DataClassification = CustomerContent;
        }
        field(7; "Api Password"; Text[250])
        {
            Caption = 'Api Password';
            DataClassification = CustomerContent;
            Description = 'MAG2.24';
        }
        field(10; "Merchant ID"; Code[20])
        {
            Caption = 'Merchant Id';
            DataClassification = CustomerContent;
        }
        field(15; "Merchant Name"; Text[50])
        {
            Caption = 'Merchant Name';
            DataClassification = CustomerContent;
            Description = 'MAG2.20';
        }
        field(20; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            InitValue = '208';
        }
        field(25; "Capture Codeunit Id"; Integer)
        {
            BlankZero = true;
            Caption = 'Capture codeunit-id';
            DataClassification = CustomerContent;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit));

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                //-MAG2.01 [250694]
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR Magento Pmt. Mgt.");
                EventSubscription.SetRange("Published Function", 'CapturePaymentEvent');
                if PAGE.RunModal(PAGE::"Event Subscriptions", EventSubscription) <> ACTION::LookupOK then
                    exit;

                Validate("Capture Codeunit Id", EventSubscription."Subscriber Codeunit ID");
                //-MAG2.01 [250694]
            end;
        }
        field(30; "Refund Codeunit Id"; Integer)
        {
            BlankZero = true;
            Caption = 'Refund codeunit-id';
            DataClassification = CustomerContent;
            Description = 'MAG2.01';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit));

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                //-MAG2.01 [250694]
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR Magento Pmt. Mgt.");
                EventSubscription.SetRange("Published Function", 'RefundPaymentEvent');
                if PAGE.RunModal(PAGE::"Event Subscriptions", EventSubscription) <> ACTION::LookupOK then
                    exit;

                Validate("Refund Codeunit Id", EventSubscription."Subscriber Codeunit ID");
                //-MAG2.01 [250694]
            end;
        }
        field(35; "Cancel Codeunit Id"; Integer)
        {
            BlankZero = true;
            Caption = 'Cancel Codeunit Id';
            DataClassification = CustomerContent;
            Description = 'MAG2.01';
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit));

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                //-MAG2.01 [250694]
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR Magento Pmt. Mgt.");
                EventSubscription.SetRange("Published Function", 'CancelPaymentEvent');
                if PAGE.RunModal(PAGE::"Event Subscriptions", EventSubscription) <> ACTION::LookupOK then
                    exit;

                Validate("Cancel Codeunit Id", EventSubscription."Subscriber Codeunit ID");
                //-MAG2.01 [250694]
            end;
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

