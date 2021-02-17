table 6060081 "NPR MCS Recomm. Model"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'On February 15, 2018, “Recommendations API is no longer under active development”';
    Caption = 'MCS Recommendations Model';
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Code"; Code[10])
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
        field(30; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;

        }
        field(40; "Model ID"; Text[50])
        {
            Caption = 'Model ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50; "Last Build ID"; BigInteger)
        {
            Caption = 'Last Build ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(60; "Last Build Date Time"; DateTime)
        {
            Caption = 'Last Build Date Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(70; "Last Item Ledger Entry No."; Integer)
        {
            Caption = 'Last Item Ledger Entry No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(80; "Build Status"; Option)
        {
            Caption = 'Build Status';
            DataClassification = CustomerContent;
            Editable = false;
            OptionCaption = 'Not Started,Running,Cancelling,Cancelled,Succeded,Failed';
            OptionMembers = NotStarted,Running,Cancelling,Cancelled,Succeded,Failed;
        }
        field(100; "Item View"; Text[250])
        {
            Caption = 'Item View';
            DataClassification = CustomerContent;
        }
        field(110; "Attribute View"; Text[250])
        {
            Caption = 'Attribute View';
            DataClassification = CustomerContent;
        }
        field(120; "Customer View"; Text[250])
        {
            Caption = 'Customer View';
            DataClassification = CustomerContent;
        }
        field(130; "Item Ledger Entry View"; Text[250])
        {
            Caption = 'Item Ledger Entry View';
            DataClassification = CustomerContent;
        }
        field(200; Categories; Option)
        {
            Caption = 'Categories';
            DataClassification = CustomerContent;
            OptionCaption = 'Item Category,Product Group,Item Category - Product Group,Item Group';
            OptionMembers = "Item Category","Product Group","Item Category - Product Group","Item Group";
        }
        field(210; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            DataClassification = CustomerContent;
            TableRelation = Language;
        }
        field(220; "Last Catalog Export Date Time"; DateTime)
        {
            Caption = 'Last Catalog Export Date Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(230; "Last Usage Export Date Time"; DateTime)
        {
            Caption = 'Last Usage Export Date Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(240; "Catalog Uploaded"; Boolean)
        {
            Caption = 'Catalog Uploaded';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(250; "Usage Data Uploaded"; Boolean)
        {
            Caption = 'Usage Data Uploaded';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(300; "Recommendations per Seed"; Integer)
        {
            Caption = 'Recommendations per Seed';
            DataClassification = CustomerContent;
            InitValue = 5;
            MinValue = 1;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

}

