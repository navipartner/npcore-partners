table 6151413 "NPR Magento Payment Gateway"
{
    Access = Public;
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
        field(2; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Integration Type"; Enum "NPR PG Integrations")
        {
            Caption = 'Integration Type';
            DataClassification = CustomerContent;
        }
        field(11; "Enable Capture"; Boolean)
        {
            Caption = 'Enable Capture';
            DataClassification = CustomerContent;
            InitValue = false;
        }
        field(12; "Enable Refund"; Boolean)
        {
            Caption = 'Enable Refund';
            DataClassification = CustomerContent;
            InitValue = false;
        }
        field(13; "Enable Cancel"; Boolean)
        {
            Caption = 'Enable Cancel';
            DataClassification = CustomerContent;
            InitValue = false;
        }
        #region To be deleted
        field(5; "Api Url"; Text[250])
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'Moved in custom integration table M2PGxxxx';
            Caption = 'Api Url';
            DataClassification = CustomerContent;
        }
        field(6; "Api Username"; Text[100])
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'Moved in custom integration table M2PGxxxx';
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
            ObsoleteState = Pending;
            ObsoleteReason = 'Moved in custom integration table M2PGxxxx';
            Caption = 'Token';
            DataClassification = CustomerContent;
            Description = 'MAG3.00';
        }
        field(9; "Api Password Key"; Guid)
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'Moved in custom integration table M2PGxxxx';
            Caption = 'Api Password Key';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(10; "Merchant ID"; Code[20])
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'Moved in custom integration table M2PGxxxx';
            Caption = 'Merchant Id';
            DataClassification = CustomerContent;
        }
        field(15; "Merchant Name"; Text[50])
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'Moved in custom integration table M2PGxxxx';
            Caption = 'Merchant Name';
            DataClassification = CustomerContent;
        }
        field(20; "Currency Code"; Code[10])
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'Moved in custom integration table M2PGxxxx';
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            InitValue = '208';
        }
        field(25; "Capture Codeunit Id"; Integer)
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'Moved in custom integration table M2PGxxxx and replaced with boolean field [Enable Capture]';
            BlankZero = true;
            Caption = 'Capture codeunit-id';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(Codeunit));

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
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
            ObsoleteState = Pending;
            ObsoleteReason = 'Moved in custom integration table M2PGxxxx and replaced with boolean field [Enable Refund]';
            BlankZero = true;
            Caption = 'Refund codeunit-id';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(Codeunit));

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
            ObsoleteState = Pending;
            ObsoleteReason = 'Moved in custom integration table M2PGxxxx and replaced with boolean field [Enable Cancel]';
            BlankZero = true;
            Caption = 'Cancel Codeunit Id';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(Codeunit));

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
        #endregion
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    var
        IntegrationTypeIsNotSelectedErr: Label 'Integration Type is not selected for Payment Gateway "%1". This is required to perform the selected action!', Comment = '%1 = payment gateway code';

    [NonDebuggable]
    [Obsolete('Migrating to interface and individual setup tables for integrations. Move your secret management there')]
    internal procedure SetApiPassword(NewPassword: Text)
    begin
        if IsNullGuid("Api Password Key") then
            "Api Password Key" := CreateGuid();

        if not EncryptionEnabled() then
            IsolatedStorage.Set("Api Password Key", NewPassword, DataScope::Company)
        else
            IsolatedStorage.SetEncrypted("Api Password Key", NewPassword, DataScope::Company);
    end;

    [NonDebuggable]
    [Obsolete('Migrating to interface and individual setup tables for integrations. Move your secret management there')]
    internal procedure GetApiPassword() PasswordValue: Text
    begin
        if (IsNullGuid(Rec."Api Password Key")) then
            exit('');

        IsolatedStorage.Get("Api Password Key", DataScope::Company, PasswordValue);
    end;

    [NonDebuggable]
    [Obsolete('Migrating to interface and individual setup tables for integrations. Move your secret management there')]
    internal procedure HasApiPassword(): Boolean
    begin
        if (not IsolatedStorage.Contains(Rec."Api Password Key", DataScope::Company)) then
            exit(false);

        exit(GetApiPassword() <> '');
    end;

    [Obsolete('Migrating to interface and individual setup tables for integrations. Move your secret management there')]
    internal procedure RemoveApiPassword()
    begin
        IsolatedStorage.Delete("Api Password Key", DataScope::Company);
        Clear("Api Password Key");
    end;

    internal procedure EnsureIntegrationTypeSelected()
    begin
        if (Rec."Integration Type".AsInteger() <= 0) and
            (Rec."Capture Codeunit Id" = 0) and
            (Rec."Refund Codeunit Id" = 0) and
            (Rec."Cancel Codeunit Id" = 0)
        then
            Error(IntegrationTypeIsNotSelectedErr, Rec.Code);
    end;
}
