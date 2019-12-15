table 6151573 "AF Arguments - NotificationHub"
{
    // NPR5.36/CLVA/20170710 CASE 269792 AF Argument Table - Spire

    Caption = 'AF Arguments - NotificationHub';

    fields
    {
        field(1;"Primary Key";Guid)
        {
            Caption = 'Primary Key';
        }
        field(10;Body;Text[250])
        {
            Caption = 'Body';
        }
        field(11;Platform;Option)
        {
            Caption = 'Platform';
            Description = 'WNS = Windows,APNS = IOS,GCM = Android';
            InitValue = APNS;
            OptionCaption = 'WNS,APNS,GCM';
            OptionMembers = WNS,APNS,GCM;
        }
        field(12;"Hub Connection String";Text[250])
        {
            Caption = 'Hub Connection String';
        }
        field(13;"Notification Hub Path";Text[250])
        {
            Caption = 'Notification Hub Path';
        }
        field(14;"Customer Tag";Text[50])
        {
            Caption = 'Customer Tag';
        }
        field(15;Title;Text[30])
        {
            Caption = 'Title';
        }
        field(16;"Notification Color";Option)
        {
            Caption = 'Notification Color';
            InitValue = Blue;
            OptionCaption = 'Red,Green,Blue,Yellow,Dark';
            OptionMembers = Red,Green,Blue,Yellow,Dark;
        }
        field(17;"To Register No.";Code[10])
        {
            Caption = 'To Register No.';
            TableRelation = Register;
        }
        field(18;"Action Type";Option)
        {
            Caption = 'Action Type';
            InitValue = Message;
            OptionCaption = 'Message,Phone Call,Facetime Video,Facetime Audio';
            OptionMembers = Message,"Phone Call","Facetime Video","Facetime Audio";
        }
        field(19;"Action Value";Text[100])
        {
            Caption = 'Action Value';
        }
        field(20;"Notification Key";Integer)
        {
            Caption = 'Notification Key';
            TableRelation = "AF Notification Hub";
        }
        field(21;"From Register No.";Code[10])
        {
            Caption = 'From Register No.';
            TableRelation = Register;
        }
        field(22;"Created By";Code[50])
        {
            Caption = 'Created By';
        }
        field(23;Location;Code[10])
        {
            Caption = 'Location';
        }
        field(100;"API Key";Text[100])
        {
            Caption = 'API Key';
        }
        field(101;"Base Url";Text[250])
        {
            Caption = 'Base Url';
        }
        field(102;"API Routing";Text[100])
        {
            Caption = 'API Routing';
        }
        field(103;"Notification Delivered to Hub";Boolean)
        {
            Caption = 'Notification Delivered to Hub';
        }
        field(200;"Request Data";BLOB)
        {
            Caption = 'Request Data';
        }
        field(201;"Response Data";BLOB)
        {
            Caption = 'Response Data';
        }
    }

    keys
    {
        key(Key1;"Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}

