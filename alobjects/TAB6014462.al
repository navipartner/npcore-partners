table 6014462 "E-mail Template Header"
{
    // PN1.00/MH/20140725  NAV-AddOn: PDF2NAV
    //   - Refactored module from the "Mail And Document Handler" Module.
    //   - This Table Contains E-mail Templates used for sending E-mail using PDF2NAV.
    // PN1.06/LS/20150525  CASE 205029 Added fields 101 & 102
    // NPR4.16/TTH/20151001  CASE 222376 PDF2NAV Changes. Added a field for document format (PDF/Word).
    // PN1.08/MHA/20151214  CASE 228859 Pdf2Nav (New Version List)
    // PN1.10/MHA/20160314 CASE 236653 "Report Format" (Word) deleted
    // NPR5.36/THRO/20170913 CASE 289216 Added Group (field 70). Used to filter which templates to use for default sending
    // NPR5.38/MHA /20180104  CASE 301054 Deleted blank Global Text Constant ErrorExistingLines
    // NPR5.38/THRO/20180108  CASE 286713 Added Transactional E-mail setup fields (field 80 + 82)
    // NPR5.43/THRO/20180626  CASE 318935 Added field 90 + 92 "Fieldnumber Start Tag" and "Fieldnumber End Tag"

    Caption = 'E-mail Template Header';
    DrillDownPageID = "E-mail Templates";
    LookupPageID = "E-mail Templates";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(5;Description;Text[30])
        {
            Caption = 'Description';
        }
        field(10;"Table No.";Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Table));

            trigger OnValidate()
            begin
                //-NPR5.38 [301054]
                //"Mail And Document Field".SETRANGE("E-mail Template Code",Code);
                //"Mail And Document Field".SETRANGE("Table No.",xRec."Table No.");
                //IF "Mail And Document Field".FIND('-') THEN
                //  ERROR(ErrorExistingLines);
                //+NPR5.38 [301054]
            end;
        }
        field(20;"HTML Template";BLOB)
        {
            Caption = 'HTML Template';
            Description = 'Using external HTML Editor from Web - Retail Setup (Magento integration)';
        }
        field(25;"Use HTML Template";Boolean)
        {
            Caption = 'Use HTML Template';
        }
        field(40;Filename;Text[30])
        {
            Caption = 'Filename';
        }
        field(50;"Verify Recipient";Boolean)
        {
            Caption = 'Verify Recipient';
        }
        field(51;"Sender as bcc";Boolean)
        {
            Caption = 'Sender as bcc';
        }
        field(52;Subject;Text[250])
        {
            Caption = 'Subject';
        }
        field(53;"From E-mail Address";Text[80])
        {
            Caption = 'From E-mail Address';
        }
        field(54;"From E-mail Name";Text[80])
        {
            Caption = 'From E-mail Name';
        }
        field(60;"Report ID";Integer)
        {
            Caption = 'Report ID';
            Description = 'Report Selection - If 0 default report is chosen.';
        }
        field(65;"Report Name";Text[249])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=CONST(Report),
                                                                           "Object ID"=FIELD("Report ID")));
            Caption = 'Report Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(70;Group;Code[20])
        {
            Caption = 'Group';
        }
        field(80;"Transactional E-mail";Option)
        {
            Caption = 'Transactional E-mail';
            OptionCaption = ' ,Campaign Monitor Transactional';
            OptionMembers = " ","Campaign Monitor Transactional";

            trigger OnValidate()
            begin
                //-NPR5.38 [2867139]
                if "Transactional E-mail" = 0 then
                  "Transactional E-mail Code" := '';
                //+NPR5.38 [2867139]
            end;
        }
        field(82;"Transactional E-mail Code";Code[20])
        {
            Caption = 'Transactional E-mail Code';
            TableRelation = IF ("Transactional E-mail"=CONST("Campaign Monitor Transactional")) "Smart Email" WHERE ("Merge Table ID"=FIELD("Table No."));
        }
        field(90;"Fieldnumber Start Tag";Text[10])
        {
            Caption = 'Fieldnumber Start Tag';
            InitValue = '{';
        }
        field(92;"Fieldnumber End Tag";Text[10])
        {
            Caption = 'Fieldnumber End Tag';
            InitValue = '}';
        }
        field(100;"Default Recipient Address";Text[250])
        {
            Caption = 'Default recipient e-mail address';
        }
        field(101;"Default Recipient Address CC";Text[250])
        {
            Caption = 'Default recipient e-mail address (CC)';
            Description = 'PN1.06';
        }
        field(102;"Default Recipient Address BCC";Text[250])
        {
            Caption = 'Default recipient e-mail address (BCC)';
            Description = 'PN1.06';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        EmailAttachment: Record "E-mail Attachment";
        EmailTemplateFilter: Record "E-mail Template Filter";
        EmailTemplateLine: Record "E-mail Template Line";
    begin
        EmailTemplateFilter.SetRange("E-mail Template Code",Code);
        EmailTemplateFilter.DeleteAll;

        EmailTemplateLine.SetRange("E-mail Template Code",Code);
        EmailTemplateLine.DeleteAll;

        EmailAttachment.SetRange("Primary Key",GetPosition(false));
        EmailAttachment.DeleteAll;
    end;
}

