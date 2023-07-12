table 6151525 "NPR Nc Collector"
{
    Access = Internal;
    Caption = 'Nc Collector';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = 'NPR23.0';
    ObsoleteReason = 'NC Collector module removed from NpCore. We switched to Job Queue instead of using Task Queue.';

    fields
    {
        field(10; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(20; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(30; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(35; "Table Name"; Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Table),
                                                             "Object ID" = FIELD("Table No.")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(40; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
        }
        field(50; "Max. Lines per Collection"; Integer)
        {
            Caption = 'Max. Lines per Collection';
            DataClassification = CustomerContent;
        }
        field(70; "Wait to Send"; Duration)
        {
            Caption = 'Wait to Send';
            DataClassification = CustomerContent;
        }
        field(80; "Delete Obsolete Lines"; Boolean)
        {
            Caption = 'Delete Obsolete Lines';
            DataClassification = CustomerContent;
        }
        field(90; "Delete Sent Collections After"; Duration)
        {
            Caption = 'Delete Sent Collections After';
            DataClassification = CustomerContent;
        }
        field(100; "Record Insert"; Boolean)
        {
            Caption = 'Insert';
            DataClassification = CustomerContent;
        }
        field(101; "Record Modify"; Boolean)
        {
            Caption = 'Modify';
            DataClassification = CustomerContent;
        }
        field(102; "Record Delete"; Boolean)
        {
            Caption = 'Delete';
            DataClassification = CustomerContent;
        }
        field(103; "Record Rename"; Boolean)
        {
            Caption = 'Rename';
            DataClassification = CustomerContent;
        }
        field(200; "Max. Lines per Request"; Integer)
        {
            Caption = 'Max. Lines per Request';
            DataClassification = CustomerContent;
        }
        field(210; "Allow Request from Database"; Text[250])
        {
            Caption = 'Allow Request from Database';
            DataClassification = CustomerContent;
        }
        field(220; "Allow Request from Company"; Text[30])
        {
            Caption = 'Allow Request from Company';
            DataClassification = CustomerContent;
        }
        field(230; "Allow Request from User ID"; Text[50])
        {
            Caption = 'Allow Request from User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(240; "Request Name"; Text[30])
        {
            Caption = 'Request Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }
}

