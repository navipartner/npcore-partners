table 6014600 "NPR Auto Rapidstart Import Log"
{
    Caption = 'Auto Rapidstart Import Log';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Package Name"; Code[20])
        {
            Caption = 'Package Name';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; "Package Name")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}