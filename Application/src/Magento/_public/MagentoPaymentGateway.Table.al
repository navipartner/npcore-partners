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
        #region Removed fields
        field(5; "Api Url"; Text[250])
        {
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Moved in custom integration table M2PGxxxx';
            Caption = 'Api Url';
            DataClassification = CustomerContent;
        }
        field(6; "Api Username"; Text[100])
        {
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Moved in custom integration table M2PGxxxx';
            Caption = 'Api Username';
            DataClassification = CustomerContent;
        }
        field(7; "Api Password"; Text[250])
        {
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'IsolatedStorage is in use.';
            Caption = 'Api Password';
            DataClassification = CustomerContent;
        }
        field(8; Token; Text[250])
        {
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Moved in custom integration table M2PGxxxx';
            Caption = 'Token';
            DataClassification = CustomerContent;
            Description = 'MAG3.00';
        }
        field(9; "Api Password Key"; Guid)
        {
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Moved in custom integration table M2PGxxxx';
            Caption = 'Api Password Key';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(10; "Merchant ID"; Code[20])
        {
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Moved in custom integration table M2PGxxxx';
            Caption = 'Merchant Id';
            DataClassification = CustomerContent;
        }
        field(15; "Merchant Name"; Text[50])
        {
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Moved in custom integration table M2PGxxxx';
            Caption = 'Merchant Name';
            DataClassification = CustomerContent;
        }
        field(20; "Currency Code"; Code[10])
        {
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Moved in custom integration table M2PGxxxx';
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            InitValue = '208';
        }
        field(25; "Capture Codeunit Id"; Integer)
        {
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Moved in custom integration table M2PGxxxx and replaced with boolean field [Enable Capture]';
            BlankZero = true;
            Caption = 'Capture codeunit-id';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(Codeunit));
        }
        field(30; "Refund Codeunit Id"; Integer)
        {
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Moved in custom integration table M2PGxxxx and replaced with boolean field [Enable Refund]';
            BlankZero = true;
            Caption = 'Refund codeunit-id';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(Codeunit));
        }
        field(35; "Cancel Codeunit Id"; Integer)
        {
            ObsoleteState = Removed;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Moved in custom integration table M2PGxxxx and replaced with boolean field [Enable Cancel]';
            BlankZero = true;
            Caption = 'Cancel Codeunit Id';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(Codeunit));
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

    internal procedure EnsureIntegrationTypeSelected()
    begin
        if (Rec."Integration Type".AsInteger() <= 0) then
            Error(IntegrationTypeIsNotSelectedErr, Rec.Code);
    end;
}
