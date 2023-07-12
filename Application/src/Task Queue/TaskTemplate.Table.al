table 6059900 "NPR Task Template"
{
    Access = Internal;
    Caption = 'Task Template';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = 'NPR23.0';
    ObsoleteReason = 'Task Queue module removed from NP Retail. We are now using Job Queue instead.';

    fields
    {
        field(1; Name; Code[10])
        {
            Caption = 'Name';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(5; "Test Report ID"; Integer)
        {
            Caption = 'Test Report ID';
            DataClassification = CustomerContent;
        }
        field(6; "Page ID"; Integer)
        {
            Caption = 'Form ID';
            DataClassification = CustomerContent;
        }
        field(9; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'General,NaviPartner';
            OptionMembers = General,NaviPartner;
            DataClassification = CustomerContent;
        }
        field(15; "Test Report Name"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Report),
                                                                           "Object ID" = FIELD("Test Report ID")));
            Caption = 'Test Report Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(16; "Page Name"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Page),
                                                                           "Object ID" = FIELD("Page ID")));
            Caption = 'Form Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(19; "Task Worker Group"; Code[10])
        {
            Caption = 'Task Worker Group';
            DataClassification = CustomerContent;
        }
        field(30; "Mail Program"; Option)
        {
            Caption = 'Mail Program';
            InitValue = SMTPMail;
            OptionCaption = ' ,J-Mail,SMTP-Mail';
            OptionMembers = " ",JMail,SMTPMail;
            DataClassification = CustomerContent;
        }
        field(31; "Mail From Address"; Text[80])
        {
            Caption = 'Mail From Address';
            DataClassification = CustomerContent;
        }
        field(32; "Mail From Name"; Text[80])
        {
            Caption = 'Mail From Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Name)
        {
        }
    }
}

