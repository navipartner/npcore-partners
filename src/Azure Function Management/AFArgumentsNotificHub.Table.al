table 6151573 "NPR AF Arguments - Notific.Hub"
{
    // NPR5.36/CLVA/20170710 CASE 269792 AF Argument Table - Spire

    Caption = 'AF Arguments - NotificationHub';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Guid)
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; Body; Text[250])
        {
            Caption = 'Body';
            DataClassification = CustomerContent;
        }
        field(11; Platform; Option)
        {
            Caption = 'Platform';
            DataClassification = CustomerContent;
            Description = 'WNS = Windows,APNS = IOS,GCM = Android';
            InitValue = APNS;
            OptionCaption = 'WNS,APNS,GCM';
            OptionMembers = WNS,APNS,GCM;
        }
        field(12; "Hub Connection String"; Text[250])
        {
            Caption = 'Hub Connection String';
            DataClassification = CustomerContent;
        }
        field(13; "Notification Hub Path"; Text[250])
        {
            Caption = 'Notification Hub Path';
            DataClassification = CustomerContent;
        }
        field(14; "Customer Tag"; Text[50])
        {
            Caption = 'Customer Tag';
            DataClassification = CustomerContent;
        }
        field(15; Title; Text[30])
        {
            Caption = 'Title';
            DataClassification = CustomerContent;
        }
        field(16; "Notification Color"; Option)
        {
            Caption = 'Notification Color';
            DataClassification = CustomerContent;
            InitValue = Blue;
            OptionCaption = 'Red,Green,Blue,Yellow,Dark';
            OptionMembers = Red,Green,Blue,Yellow,Dark;
        }
        field(17; "To Register No."; Code[10])
        {
            Caption = 'To Register No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR Register";
        }
        field(18; "Action Type"; Option)
        {
            Caption = 'Action Type';
            DataClassification = CustomerContent;
            InitValue = Message;
            OptionCaption = 'Message,Phone Call,Facetime Video,Facetime Audio';
            OptionMembers = Message,"Phone Call","Facetime Video","Facetime Audio";
        }
        field(19; "Action Value"; Text[100])
        {
            Caption = 'Action Value';
            DataClassification = CustomerContent;
        }
        field(20; "Notification Key"; Integer)
        {
            Caption = 'Notification Key';
            DataClassification = CustomerContent;
            TableRelation = "NPR AF Notification Hub";
        }
        field(21; "From Register No."; Code[10])
        {
            Caption = 'From Register No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR Register";
        }
        field(22; "Created By"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = CustomerContent;
        }
        field(23; Location; Code[10])
        {
            Caption = 'Location';
            DataClassification = CustomerContent;
        }
        field(100; "API Key"; Text[100])
        {
            Caption = 'API Key';
            DataClassification = CustomerContent;
        }
        field(101; "Base Url"; Text[250])
        {
            Caption = 'Base Url';
            DataClassification = CustomerContent;
        }
        field(102; "API Routing"; Text[100])
        {
            Caption = 'API Routing';
            DataClassification = CustomerContent;
        }
        field(103; "Notification Delivered to Hub"; Boolean)
        {
            Caption = 'Notification Delivered to Hub';
            DataClassification = CustomerContent;
        }
        field(200; "Request Data"; BLOB)
        {
            Caption = 'Request Data';
            DataClassification = CustomerContent;
        }
        field(201; "Response Data"; BLOB)
        {
            Caption = 'Response Data';
            DataClassification = CustomerContent;
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
}

