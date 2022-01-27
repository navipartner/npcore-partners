table 6014632 "NPR Job Queue Notif. Profile"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Job Queue Notification Profile';

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            DataClassification = CustomerContent;
        }
        field(200; "Send E-mail"; Boolean)
        {
            Caption = 'Send E-mail';
            DataClassification = CustomerContent;
        }
        field(210; "E-mail Template Code"; Code[20])
        {
            Caption = 'E-mail Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR E-mail Template Header" WHERE("Table No." = field("Table No."));
        }
        field(220; "E-Mail"; Text[80])
        {
            Caption = 'Email';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;

            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                if "E-Mail" = '' then
                    exit;
                MailManagement.CheckValidEmailAddresses("E-Mail");
            end;
        }
        field(300; "Send Sms"; Boolean)
        {
            Caption = 'Send Sms';
            DataClassification = CustomerContent;
        }
        field(310; "SMS Template Code"; Code[10])
        {
            Caption = 'SMS Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR SMS Template Header" WHERE("Table No." = field("Table No."));
        }
        field(320; "Phone No."; Text[30])
        {
            Caption = 'Phone No.';
            DataClassification = CustomerContent;
            ExtendedDatatype = PhoneNo;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}