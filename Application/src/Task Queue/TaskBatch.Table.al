table 6059901 "NPR Task Batch"
{
    Access = Internal;
    Caption = 'Task Batch';
    DataCaptionFields = Name, Description;
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = 'NPR23.0';
    ObsoleteReason = 'Task Queue module removed from NP Retail. We are now using Job Queue instead.';

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; Name; Code[10])
        {
            Caption = 'Name';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(3; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(19; "Task Worker Group"; Code[10])
        {
            Caption = 'Task Worker Group';
            DataClassification = CustomerContent;
        }
        field(21; "Template Type"; Option)
        {
            CalcFormula = Lookup("NPR Task Template".Type WHERE(Name = FIELD("Journal Template Name")));
            Caption = 'Template Type';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = 'General,NaviPartner';
            OptionMembers = General,NaviPartner;
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
        field(40; "Common Companies"; Boolean)
        {
            Caption = 'Common Companies';
            DataClassification = CustomerContent;
        }
        field(41; "Master Company"; Text[30])
        {
            Caption = 'Master Company';
            DataClassification = CustomerContent;
        }
        field(80; "Delete Log After"; Duration)
        {
            Caption = 'Delete Log After';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Journal Template Name", Name)
        {
        }
    }
}

