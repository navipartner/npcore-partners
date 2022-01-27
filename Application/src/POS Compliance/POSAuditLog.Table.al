table 6150637 "NPR POS Audit Log"
{
    Access = Internal;
    Caption = 'POS Audit Log';
    DataClassification = CustomerContent;
    LookupPageID = "NPR POS Audit Log";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(2; "Record ID"; RecordID)
        {
            Caption = 'Record ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(3; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "Table Name"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Table),
                                                                           "Object ID" = FIELD("Table ID")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; "Action Type"; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            Editable = false;
            OptionCaption = 'Salesperson Sign In,Salesperson Sign Out,Receipt Copy,Direct Sale End,Item RMA,Workshift End,Archive Attempt,Manual Cash Drawer Open,Audit Verification,Data Export,Permission Modification,Data Import,Drawer Count,Data Purge,Partner Modification,Audit Log Init,Compliance Modification,Setup Modification,Grand Total,Archive Create,Initial Receipt Print,Other POS Print,Unit Lock, Unit Unlock,Sale Park,Sale Load,Unit Open,Automatic Cash Drawer Open,Line Quantity Correction,Price Check,Manual Price Change,Credit Sale End,Cancel Sale End,Custom';
            OptionMembers = SIGN_IN,SIGN_OUT,RECEIPT_COPY,DIRECT_SALE_END,ITEM_RMA,WORKSHIFT_END,ARCHIVE_ATTEMPT,MANUAL_DRAWER_OPEN,AUDIT_VERIFY,DATA_EXPORT,PERMISSION_MODIFY,DATA_IMPORT,DRAWER_COUNT,DATA_PURGE,PARTNER_MODIFICATION,LOG_INIT,COMPLIANCE_MODIFICATION,SETUP_MODIFICATION,GRANDTOTAL,ARCHIVE_CREATE,RECEIPT_PRINT,OTHER_POS_PRINT,UNIT_LOCK,UNIT_UNLOCK,SALE_PARK,SALE_LOAD,UNIT_OPEN,AUTO_DRAWER_OPEN,QUANTITY_CORRECTION,PRICE_CHECK,MANUAL_PRICE_CHANGE,CREDIT_SALE_END,CANCEL_SALE_END,CUSTOM;
        }
        field(6; "Acted on POS Entry No."; Integer)
        {
            Caption = 'Acted on POS Entry No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(7; "Acted on POS Entry Fiscal No."; Code[20])
        {
            Caption = 'Acted on POS Entry Fiscal No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(8; "Acted on POS Unit No."; Code[10])
        {
            Caption = 'Acted on POS Unit No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(9; "Active Salesperson Code"; Code[20])
        {
            Caption = 'Active Salesperson Code';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "Log Timestamp"; DateTime)
        {
            Caption = 'Log Timestamp';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "External ID"; Code[20])
        {
            Caption = 'External ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; "External Code"; Code[20])
        {
            Caption = 'External Code';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13; "External Description"; Text[250])
        {
            Caption = 'External Description';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14; "Electronic Signature"; BLOB)
        {
            Caption = 'Electronic Signature';
            DataClassification = CustomerContent;
        }
        field(15; "Previous Electronic Signature"; BLOB)
        {
            Caption = 'Previous Electronic Signature';
            DataClassification = CustomerContent;
        }
        field(18; "Signature Base Value"; BLOB)
        {
            Caption = 'Signature Base Value';
            DataClassification = CustomerContent;
        }
        field(19; "Signature Base Hash"; Text[250])
        {
            Caption = 'Signature Base Hash';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(20; "External Implementation"; Text[30])
        {
            Caption = 'External Implementation';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(21; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(22; "Certificate Thumbprint"; Text[250])
        {
            Caption = 'Certificate Thumbprint';
            DataClassification = CustomerContent;
        }
        field(23; "Additional Information"; Text[250])
        {
            Caption = 'Additional Information';
            DataClassification = CustomerContent;
        }
        field(25; "External Type"; Code[20])
        {
            Caption = 'External Type';
            DataClassification = CustomerContent;
        }
        field(26; "Certificate Implementation"; Text[30])
        {
            Caption = 'Certificate Implementation';
            DataClassification = CustomerContent;
        }
        field(27; "Original Signature Base Value"; BLOB)
        {
            Caption = 'Original Signature Base Value';
            DataClassification = CustomerContent;
        }
        field(28; "Original Signature Base Hash"; Text[250])
        {
            Caption = 'Original Signature Base Hash';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(29; "Handled by External Impl."; Boolean)
        {
            Caption = 'Handled by External Impl.';
            DataClassification = CustomerContent;
        }
        field(30; Uploaded; Boolean)
        {
            Caption = 'Uploaded';
            DataClassification = CustomerContent;
        }
        field(31; "Active POS Sale ID"; Integer)
        {
            Caption = 'Active POS Sale ID';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Use systemID instead';
        }
        field(32; "Active POS Unit No."; Code[10])
        {
            Caption = 'Active POS Unit No.';
            DataClassification = CustomerContent;
        }
        field(33; "Action Custom Subtype"; Text[30])
        {
            Caption = 'Action Custom Subtype';
            DataClassification = CustomerContent;
        }
        field(34; "Active POS Sale SystemId"; Guid)
        {
            Caption = 'Active POS Sale SystemId';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Acted on POS Unit No.", "Action Type")
        {
        }
        key(Key3; "Acted on POS Unit No.", "External Type")
        {
        }
        key(Key4; "Acted on POS Unit No.", Uploaded)
        {
        }
        key(Key5; "Acted on POS Entry No.")
        {
        }
    }
}
