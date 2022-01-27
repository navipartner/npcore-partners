table 6150707 "NPR POS Setup"
{
    Caption = 'POS Named Actions Profile';
    DataClassification = CustomerContent;
    LookupPageID = "NPR POS Named Actions Profiles";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(100; "Login Action Code"; Code[20])
        {
            Caption = 'Login Action Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Action";

            trigger OnLookup()
            begin
                if ActionMgt.LookupAction("Login Action Code") then
                    Validate("Login Action Code");
            end;

            trigger OnValidate()
            begin
                ParamMgt.ClearParametersForRecord(RecordId, FieldNo("Login Action Code"));
                ParamMgt.CopyFromActionToField("Login Action Code", RecordId, FieldNo("Login Action Code"));
            end;
        }
        field(101; "Text Enter Action Code"; Code[20])
        {
            Caption = 'Text Enter Action Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Action";

            trigger OnLookup()
            begin
                if ActionMgt.LookupAction("Text Enter Action Code") then
                    Validate("Text Enter Action Code");
            end;

            trigger OnValidate()
            begin
                ParamMgt.ClearParametersForRecord(RecordId, FieldNo("Text Enter Action Code"));
                ParamMgt.CopyFromActionToField("Text Enter Action Code", RecordId, FieldNo("Text Enter Action Code"));
            end;
        }
        field(102; "Item Insert Action Code"; Code[20])
        {
            Caption = 'Item Insert Action Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Action";

            trigger OnLookup()
            begin
                if ActionMgt.LookupAction("Item Insert Action Code") then
                    Validate("Item Insert Action Code");
            end;

            trigger OnValidate()
            begin
                ParamMgt.ClearParametersForRecord(RecordId, FieldNo("Item Insert Action Code"));
                ParamMgt.CopyFromActionToField("Item Insert Action Code", RecordId, FieldNo("Item Insert Action Code"));
            end;
        }
        field(103; "Payment Action Code"; Code[20])
        {
            Caption = 'Payment Action Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Action";

            trigger OnLookup()
            begin
                if ActionMgt.LookupAction("Payment Action Code") then
                    Validate("Payment Action Code");
            end;

            trigger OnValidate()
            begin
                ParamMgt.ClearParametersForRecord(RecordId, FieldNo("Payment Action Code"));
                ParamMgt.CopyFromActionToField("Payment Action Code", RecordId, FieldNo("Payment Action Code"));
            end;
        }
        field(104; "Customer Action Code"; Code[20])
        {
            Caption = 'Customer Action Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Action";

            trigger OnLookup()
            begin
                if ActionMgt.LookupAction("Customer Action Code") then
                    Validate("Customer Action Code");
            end;

            trigger OnValidate()
            begin
                ParamMgt.ClearParametersForRecord(RecordId, FieldNo("Customer Action Code"));
                ParamMgt.CopyFromActionToField("Customer Action Code", RecordId, FieldNo("Customer Action Code"));
            end;
        }
        field(110; "Lock POS Action Code"; Code[20])
        {
            Caption = 'Lock POS Action Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Action";

            trigger OnLookup()
            begin
                if ActionMgt.LookupAction("Lock POS Action Code") then
                    Validate("Lock POS Action Code");
            end;

            trigger OnValidate()
            begin
                ParamMgt.ClearParametersForRecord(RecordId, FieldNo("Lock POS Action Code"));
                ParamMgt.CopyFromActionToField("Lock POS Action Code", RecordId, FieldNo("Lock POS Action Code"));
            end;
        }
        field(120; "Unlock POS Action Code"; Code[20])
        {
            Caption = 'Unlock POS Action Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Action";

            trigger OnLookup()
            begin
                if ActionMgt.LookupAction("Unlock POS Action Code") then
                    Validate("Unlock POS Action Code");
            end;

            trigger OnValidate()
            begin
                ParamMgt.ClearParametersForRecord(RecordId, FieldNo("Unlock POS Action Code"));
                ParamMgt.CopyFromActionToField("Unlock POS Action Code", RecordId, FieldNo("Unlock POS Action Code"));
            end;
        }
        field(130; "OnBeforePaymentView Action"; Code[20])
        {
            Caption = 'On Before Payment View Action Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Action";

            trigger OnLookup()
            begin
                if ActionMgt.LookupAction("OnBeforePaymentView Action") then
                    Validate("OnBeforePaymentView Action");
            end;

            trigger OnValidate()
            begin
                ParamMgt.ClearParametersForRecord(RecordId, FieldNo("OnBeforePaymentView Action"));
                ParamMgt.CopyFromActionToField("OnBeforePaymentView Action", RecordId, FieldNo("OnBeforePaymentView Action"));
            end;
        }
        field(140; "Idle Timeout Action Code"; Code[20])
        {
            Caption = 'Idle Timeout Action Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Action";

            trigger OnLookup()
            begin
                if ActionMgt.LookupAction("Idle Timeout Action Code") then
                    Validate("Idle Timeout Action Code");
            end;

            trigger OnValidate()
            begin
                ParamMgt.ClearParametersForRecord(RecordId, FieldNo("Idle Timeout Action Code"));
                ParamMgt.CopyFromActionToField("Idle Timeout Action Code", RecordId, FieldNo("Lock POS Action Code"));
            end;
        }
        field(150; "Admin Menu Action Code"; Code[20])
        {
            Caption = 'Admin Menu Action Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Action";

            trigger OnLookup()
            begin
                if ActionMgt.LookupAction("Admin Menu Action Code") then
                    Validate("Admin Menu Action Code");
            end;

            trigger OnValidate()
            begin
                ParamMgt.ClearParametersForRecord(RecordId, FieldNo("Admin Menu Action Code"));
                ParamMgt.CopyFromActionToField("Admin Menu Action Code", RecordId, FieldNo("Admin Menu Action Code"));
            end;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        TestField("Primary Key");
    end;

    var
        ParamMgt: Codeunit "NPR POS Action Param. Mgt.";
        ActionMgt: Codeunit "NPR POS Action Management";

    procedure AssistEdit(ActionCode: Code[20]; "Field": Integer)
    begin
        ParamMgt.EditParametersForField(ActionCode, RecordId, Field);
    end;
}

