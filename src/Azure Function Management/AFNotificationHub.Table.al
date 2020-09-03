table 6151574 "NPR AF Notification Hub"
{
    // NPR5.36/NPKNAV/20171003  CASE 269792 Transport NPR5.36 - 3 October 2017
    // NPR5.38/NPKNAV/20180126  CASE 269792-01 Transport NPR5.38 - 26 January 2018

    Caption = 'AF Notification Hub';
    DataClassification = CustomerContent;
    DataCaptionFields = Id, Title;
    DrillDownPageID = "NPR Notification List";
    LookupPageID = "NPR Notification List";

    fields
    {
        field(1; Id; Integer)
        {
            AutoIncrement = true;
            Caption = 'Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; Title; Text[30])
        {
            Caption = 'Title';
            DataClassification = CustomerContent;
        }
        field(11; Body; Text[250])
        {
            Caption = 'Body';
            DataClassification = CustomerContent;
        }
        field(12; Platform; Option)
        {
            Caption = 'Platform';
            DataClassification = CustomerContent;
            Description = 'WNS = Windows,APNS = IOS,GCM = Android';
            InitValue = APNS;
            OptionCaption = 'WNS,APNS,GCM';
            OptionMembers = WNS,APNS,GCM;
        }
        field(13; "Notification Color"; Option)
        {
            Caption = 'Notification Color';
            DataClassification = CustomerContent;
            InitValue = Blue;
            OptionCaption = 'Red,Green,Blue,Yellow,Dark';
            OptionMembers = Red,Green,Blue,Yellow,Dark;
        }
        field(14; "From Register No."; Code[10])
        {
            Caption = 'From Register No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR Register";
        }
        field(15; "To Register No."; Code[10])
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
        field(20; Location; Code[10])
        {
            Caption = 'Location';
            DataClassification = CustomerContent;
        }
        field(100; Created; DateTime)
        {
            Caption = 'Created';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(101; "Created By"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(103; "Notification Delivered to Hub"; Boolean)
        {
            Caption = 'Notification Delivered to Hub';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(104; Handled; DateTime)
        {
            Caption = 'Handled';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(105; "Handled By"; Code[50])
        {
            Caption = 'Handled By';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(106; "Handled Register"; Code[10])
        {
            Caption = 'Handled Register';
            DataClassification = CustomerContent;
            TableRelation = "NPR Register";
        }
        field(107; Cancelled; DateTime)
        {
            Caption = 'Cancelled';
            DataClassification = CustomerContent;
        }
        field(108; "Cancelled By"; Code[50])
        {
            Caption = 'Cancelled By';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(109; "Cancelled Register"; Code[10])
        {
            Caption = 'Cancelled Register';
            DataClassification = CustomerContent;
            TableRelation = "NPR Register";
        }
        field(110; Completed; DateTime)
        {
            Caption = 'Completed';
            DataClassification = CustomerContent;
        }
        field(111; "Completed By"; Code[50])
        {
            Caption = 'Completed By';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(112; "Completed Register"; Code[10])
        {
            Caption = 'Completed Register';
            DataClassification = CustomerContent;
            TableRelation = "NPR Register";
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
        field(202; "Temp Current Register"; Code[10])
        {
            Caption = 'Temp Current Register';
            DataClassification = CustomerContent;
            TableRelation = "NPR Register";
        }
    }

    keys
    {
        key(Key1; Id)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Id, Title, Body, Handled, "Handled By")
        {
        }
        fieldgroup(Brick; Id, Title, Body, Handled, "Handled By")
        {
        }
    }

    trigger OnInsert()
    begin
        "Notification Delivered to Hub" := false;
        Created := CurrentDateTime;
        "Created By" := UserId;
        Handled := 0DT;
        "Handled By" := '';
    end;
}

