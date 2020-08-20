table 6151493 "Raptor Action"
{
    // NPR5.53/ALPO/20191125 CASE 377727 Raptor integration enhancements
    // NPR5.54/ALPO/20200302 CASE 355871 Possibility to specify user identifier parameter name

    Caption = 'Raptor Action';
    DataClassification = CustomerContent;
    DrillDownPageID = "Raptor Action List";
    LookupPageID = "Raptor Action List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; "Data Type Description"; Text[50])
        {
            Caption = 'Data Type Description';
            DataClassification = CustomerContent;
        }
        field(3; "Raptor Module Code"; Text[50])
        {
            Caption = 'Raptor Module Code';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Raptor Module API Req. String" <> '') and ("Raptor Module API Req. String" = xRec."Raptor Module Code") then
                    "Raptor Module API Req. String" := "Raptor Module Code";
            end;
        }
        field(4; "Number of Entries to Return"; Integer)
        {
            Caption = 'Number of Entries to Return';
            DataClassification = CustomerContent;
        }
        field(5; Comment; Text[140])
        {
            Caption = 'Comment';
            DataClassification = CustomerContent;
        }
        field(6; "Raptor Module API Req. String"; Text[50])
        {
            Caption = 'Raptor Module API Req. String';
            DataClassification = CustomerContent;
        }
        field(20; "User Identifier Param. Name"; Text[30])
        {
            Caption = 'User Identifier Param. Name';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
        }
        field(51; "Show Date-Time Created"; Boolean)
        {
            Caption = 'Show Date-Time Created';
            DataClassification = CustomerContent;
        }
        field(52; "Show Priority"; Boolean)
        {
            Caption = 'Show Priority';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    procedure RaptorActionAPIReqString(): Text
    begin
        if "Raptor Module API Req. String" <> '' then
            exit("Raptor Module API Req. String");
        exit("Raptor Module Code");
    end;
}

