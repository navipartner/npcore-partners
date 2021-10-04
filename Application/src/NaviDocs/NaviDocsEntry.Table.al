table 6059768 "NPR NaviDocs Entry"
{
    Caption = 'NaviDocs';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(5; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            DataClassification = CustomerContent;
        }
        field(10; "Document Type"; Integer)
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(15; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(20; "Record ID"; RecordID)
        {
            Caption = 'Record ID';
            DataClassification = CustomerContent;
        }
        field(25; "Document Description"; Text[100])
        {
            Caption = 'Document Description';
            DataClassification = CustomerContent;
        }
        field(30; "Document Handling Option"; Integer)
        {
            Caption = 'Document Handling Option';
            DataClassification = CustomerContent;
        }
        field(35; "Document Handling Profile"; Code[20])
        {
            Caption = 'Document Handling Profile';
            TableRelation = "NPR NaviDocs Handling Profile";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NaviDocsHandlingProfile: Record "NPR NaviDocs Handling Profile";
            begin
                if NaviDocsHandlingProfile.Get("Document Handling Profile") then
                    "Document Handling" := NaviDocsHandlingProfile.Description;
            end;
        }
        field(40; "Document Handling"; Text[100])
        {
            Caption = 'Document Handling';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Document Handling" <> '' then
                    Error(Error001);
            end;
        }
        field(45; "Report No."; Integer)
        {
            Caption = 'Report No.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = CONST(Report));
            DataClassification = CustomerContent;
        }
        field(50; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(60; "Template Code"; Code[20])
        {
            Caption = 'Template Code';
            DataClassification = CustomerContent;
        }
        field(90; Status; Integer)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(100; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(150; "Order No."; Code[20])
        {
            Caption = 'Order No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(190; "Type (Recipient)"; Enum "NPR NaviDocs Entry Type (Recipient)")
        {
            Caption = 'Type (Recipient)';
            DataClassification = CustomerContent;
        }
        field(200; "No. (Recipient)"; Code[20])
        {
            Caption = 'No. (Recipient)';
            NotBlank = true;
            TableRelation = IF ("Type (Recipient)" = CONST(Customer)) Customer
            ELSE
            IF ("Type (Recipient)" = CONST(Vendor)) Vendor;
            DataClassification = CustomerContent;
        }
        field(210; "E-mail (Recipient)"; Text[80])
        {
            Caption = 'E-mail (Recipient)';
            DataClassification = CustomerContent;
        }
        field(220; "Name (Recipient)"; Text[100])
        {
            Caption = 'Name (Recipient)';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(230; "Name 2 (Recipient)"; Text[50])
        {
            Caption = 'Name 2 (Recipient)';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(500; "Insert User ID"; Text[250])
        {
            Caption = 'Inserted by User';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(510; "Insert Date"; Date)
        {
            Caption = 'Insert Date';
            DataClassification = CustomerContent;
        }
        field(520; "Insert Time"; Time)
        {
            Caption = 'Insert Time';
            DataClassification = CustomerContent;
        }
        field(600; "Delay sending until"; DateTime)
        {
            Caption = 'Delay sending until';
            DataClassification = CustomerContent;
        }
        field(1000; "Processed Qty."; Integer)
        {
            Caption = 'Processed Qty.';
            DataClassification = CustomerContent;
        }
        field(1010; "Printed Qty."; Integer)
        {
            Caption = 'Printed Qty.';
            DataClassification = CustomerContent;
        }
        field(1020; "OIO Sent"; Boolean)
        {
            Caption = 'OIO Sent';
            DataClassification = CustomerContent;
        }
        field(1030; "E-mail Qty."; Integer)
        {
            Caption = 'E-mail Qty.';
            DataClassification = CustomerContent;
        }
        field(1040; "Error Qty."; Integer)
        {
            CalcFormula = Count("NPR NaviDocs Entry Comment" WHERE("Table No." = FIELD("Table No."),
                                                                "Document No." = FIELD("No."),
                                                                Warning = CONST(true)));
            Caption = 'Errors Qty.';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Table No.", "Document Type", "No.")
        {
        }
        key(Key3; Status)
        {
        }
        key(Key4; "Posting Date")
        {
        }
        key(Key5; "Order No.")
        {
        }
    }

    trigger OnDelete()
    var
        ActivityLog: Record "Activity Log";
        NaviDocsEntryAttachment: Record "NPR NaviDocs Entry Attachment";
    begin
        NaviDocsEntryComment.SetRange("Table No.", "Table No.");
        NaviDocsEntryComment.SetRange("Document Type", "Document Type");
        NaviDocsEntryComment.SetRange("Document No.", "No.");
        NaviDocsEntryComment.DeleteAll(true);

        ActivityLog.SetRange("Record ID", RecordId);
        ActivityLog.DeleteAll();

        NaviDocsEntryAttachment.SetRange("NaviDocs Entry No.", "Entry No.");
        NaviDocsEntryAttachment.DeleteAll();
    end;

    trigger OnInsert()
    begin
        "Entry No." := 0;
        "Insert User ID" := CopyStr(UserId, 1, MaxStrLen("Insert User ID"));
        "Insert Date" := Today();
        "Insert Time" := Time;
    end;

    var
        NaviDocsEntryComment: Record "NPR NaviDocs Entry Comment";
        Error001: Label 'Please use Lookup (F6).';
}

