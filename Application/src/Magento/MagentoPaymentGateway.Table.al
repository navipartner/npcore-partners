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
        }
        field(6; "Api Username"; Text[100])
        {
            Caption = 'Api Username';
            DataClassification = CustomerContent;
        }
        field(7; "Api Password"; Text[250])
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'IsolatedStorage is in use.';
            Caption = 'Api Password';
            DataClassification = CustomerContent;
        }
        field(8; Token; Text[250])
        {
            Caption = 'Token';
            DataClassification = CustomerContent;
            Description = 'MAG3.00';
        }
        field(9; "Api Password Key"; Guid)
        {
            Caption = 'Api Password Key';
            Editable = false;
            DataClassification = CustomerContent;
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
            end;
        }
        field(30; "Refund Codeunit Id"; Integer)
        {
            BlankZero = true;
            Caption = 'Refund codeunit-id';
            DataClassification = CustomerContent;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit));

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR Magento Pmt. Mgt.");
                EventSubscription.SetRange("Published Function", 'RefundPaymentEvent');
                if PAGE.RunModal(PAGE::"Event Subscriptions", EventSubscription) <> ACTION::LookupOK then
                    exit;

                Validate("Refund Codeunit Id", EventSubscription."Subscriber Codeunit ID");
            end;
        }
        field(35; "Cancel Codeunit Id"; Integer)
        {
            BlankZero = true;
            Caption = 'Cancel Codeunit Id';
            DataClassification = CustomerContent;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit));

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR Magento Pmt. Mgt.");
                EventSubscription.SetRange("Published Function", 'CancelPaymentEvent');
                if PAGE.RunModal(PAGE::"Event Subscriptions", EventSubscription) <> ACTION::LookupOK then
                    exit;

                Validate("Cancel Codeunit Id", EventSubscription."Subscriber Codeunit ID");
            end;
        }
    }

    [NonDebuggable]
    procedure SetApiPassword(NewPassword: Text)
    begin
        if IsNullGuid("Api Password Key") then
            "Api Password Key" := CreateGuid();
        IsolatedStorage.Set("Api Password Key", NewPassword, DataScope::Company);
    end;

    [NonDebuggable]
    procedure GetApiPassword(): Text
    Var
        PasswordValue: Text;
    begin
        IsolatedStorage.Get("Api Password Key", DataScope::Company, PasswordValue);
    end;

    [NonDebuggable]
    procedure HasApiPassword(): Boolean
    begin
        exit(GetApiPassword() <> '');
    end;

    procedure RemoveApiPassword()
    begin
        IsolatedStorage.Delete("Api Password Key", DataScope::Company);
        Clear("Api Password Key");
    end;
}