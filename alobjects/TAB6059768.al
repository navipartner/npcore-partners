table 6059768 "NaviDocs Entry"
{
    // NPR5.23/THRO/20160315 CASE 236043 Get Table Caption from Object.Type=Table
    // NPR5.26/THRO/20160808 CASE 248662 Added Document Handling Profile. Document Handling Option no longer used.
    //                                   Removed field 3 Type, 300 "Post Shipment",  310 "Post Invoice", 320 "Post Reception" and 1500 "Attached File"
    //                                   Field 100 External Document No. change to code(35) to match size in salesheader
    // NPR5.26/THRO/20160908 CASE 250371 Added field 600 "Delay sending until" - for delayed sending of document
    // NPR5.28/MMV /20161104 CASE 254575 Added option "Contact" to field 190 "Type (Recipient)".
    // NPR5.30/THRO/20170209 CASE 243998 Use Activity Log for Logging
    // NPR5.36/THRO/20170913 CASE 289216 Added Template Code. Used to specify a template to use when sending. Overwrite the normal "find a matching template"-function
    // NPR5.43/THRO/20180614 CASE 315958 Attachment table

    Caption = 'NaviDocs';

    fields
    {
        field(1;"Entry No.";BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(5;"Table No.";Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Table));
        }
        field(10;"Document Type";Integer)
        {
            Caption = 'Document Type';
        }
        field(15;"No.";Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(20;"Record ID";RecordID)
        {
            Caption = 'Record ID';
        }
        field(25;"Document Description";Text[100])
        {
            Caption = 'Document Description';
        }
        field(30;"Document Handling Option";Integer)
        {
            Caption = 'Document Handling Option';
        }
        field(35;"Document Handling Profile";Code[20])
        {
            Caption = 'Document Handling Profile';
            TableRelation = "NaviDocs Handling Profile";

            trigger OnValidate()
            var
                NaviDocsHandlingProfile: Record "NaviDocs Handling Profile";
            begin
                //-NPR5.26 [248662]
                if NaviDocsHandlingProfile.Get("Document Handling Profile") then
                  "Document Handling" := NaviDocsHandlingProfile.Description;
                //+NPR5.26 [248662]
            end;
        }
        field(40;"Document Handling";Text[100])
        {
            Caption = 'Document Handling';

            trigger OnValidate()
            begin
                if "Document Handling" <> '' then
                  Error(Error001);
            end;
        }
        field(45;"Report No.";Integer)
        {
            Caption = 'Report No.';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Report));
        }
        field(50;"Posting Date";Date)
        {
            Caption = 'Posting Date';
            Editable = false;
        }
        field(60;"Template Code";Code[20])
        {
            Caption = 'Template Code';
        }
        field(90;Status;Integer)
        {
            Caption = 'Status';
        }
        field(100;"External Document No.";Code[35])
        {
            Caption = 'External Document No.';
        }
        field(150;"Order No.";Code[20])
        {
            Caption = 'Order No.';
            Editable = false;
        }
        field(190;"Type (Recipient)";Option)
        {
            Caption = 'Type (Recipient)';
            OptionCaption = ' ,Customer,Vendor,Contact';
            OptionMembers = " ",Customer,Vendor,Contact;
        }
        field(200;"No. (Recipient)";Code[20])
        {
            Caption = 'No. (Recipient)';
            NotBlank = true;
            TableRelation = IF ("Type (Recipient)"=CONST(Customer)) Customer
                            ELSE IF ("Type (Recipient)"=CONST(Vendor)) Vendor;
        }
        field(210;"E-mail (Recipient)";Text[80])
        {
            Caption = 'E-mail (Recipient)';
        }
        field(220;"Name (Recipient)";Text[50])
        {
            Caption = 'Name (Recipient)';
            Editable = false;
        }
        field(230;"Name 2 (Recipient)";Text[50])
        {
            Caption = 'Name 2 (Recipient)';
            Editable = false;
        }
        field(500;"Insert User ID";Text[250])
        {
            Caption = 'Inserted by User';
            Editable = false;
        }
        field(510;"Insert Date";Date)
        {
            Caption = 'Insert Date';
        }
        field(520;"Insert Time";Time)
        {
            Caption = 'Insert Time';
        }
        field(600;"Delay sending until";DateTime)
        {
            Caption = 'Delay sending until';
        }
        field(1000;"Processed Qty.";Integer)
        {
            Caption = 'Processed Qty.';
        }
        field(1010;"Printed Qty.";Integer)
        {
            Caption = 'Printed Qty.';
        }
        field(1020;"OIO Sent";Boolean)
        {
            Caption = 'OIO Sent';
        }
        field(1030;"E-mail Qty.";Integer)
        {
            Caption = 'E-mail Qty.';
        }
        field(1040;"Error Qty.";Integer)
        {
            CalcFormula = Count("NaviDocs Entry Comment" WHERE ("Table No."=FIELD("Table No."),
                                                                "Document No."=FIELD("No."),
                                                                Warning=CONST(true)));
            Caption = 'Errors Qty.';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Table No.","Document Type","No.")
        {
        }
        key(Key3;Status)
        {
        }
        key(Key4;"Posting Date")
        {
        }
        key(Key5;"Order No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ActivityLog: Record "Activity Log";
        NaviDocsEntryAttachment: Record "NaviDocs Entry Attachment";
    begin
        NaviDocsEntryComment.SetRange("Table No.","Table No.");
        NaviDocsEntryComment.SetRange("Document Type","Document Type");
        NaviDocsEntryComment.SetRange("Document No.","No.");
        NaviDocsEntryComment.DeleteAll(true);
        //-NPR5.30 [243998]
        ActivityLog.SetRange("Record ID",RecordId);
        ActivityLog.DeleteAll;
        //+NPR5.30 [243998]
        //-NPR5.43 [315958]
        NaviDocsEntryAttachment.SetRange("NaviDocs Entry No.","Entry No.");
        NaviDocsEntryAttachment.DeleteAll;
        //+NPR5.43 [315958]
    end;

    trigger OnInsert()
    begin
        "Entry No." := 0;
        "Insert User ID" := UserId;
        "Insert Date" := Today;
        "Insert Time" := Time;
    end;

    var
        NaviDocsEntryComment: Record "NaviDocs Entry Comment";
        Error001: Label 'Please use Lookup (F6).';
        AdditionalHandlingOptionTxt: Label ',,,,,,,,,,,,,,,,,,,SMS';
}

