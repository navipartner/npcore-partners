table 6060151 "NPR Event Word Layout"
{
    Access = Internal;
    Caption = 'Event Word Layout';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Replaced with NPR Event Report Layout';

    fields
    {
        field(1; "Source Record ID"; RecordID)
        {
            Caption = 'Source Record ID';
            DataClassification = CustomerContent;
        }
        field(2; Usage; Option)
        {
            Caption = 'Usage';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Customer,Team';
            OptionMembers = " ",Customer,Team;

        }
        field(5; "Report ID"; Integer)
        {
            Caption = 'Report ID';
            DataClassification = CustomerContent;
        }
        field(10; "Basic Layout Code"; Code[20])
        {
            Caption = 'Basic Layout ID';
            DataClassification = CustomerContent;
            TableRelation = "Custom Report Layout".Code WHERE("Report ID" = FIELD("Report ID"));
        }
        field(20; Layout; BLOB)
        {
            Caption = 'Layout';
            DataClassification = CustomerContent;
        }
        field(30; "XML Part"; BLOB)
        {
            Caption = 'XML Part';
            DataClassification = CustomerContent;
        }
        field(40; "Last Modified"; DateTime)
        {
            Caption = 'Last Modified';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50; "Last Modified by User"; Code[50])
        {
            Caption = 'Last Modified by User';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(60; "Basic Layout Description"; Text[250])
        {
            CalcFormula = Lookup("Custom Report Layout".Description WHERE(Code = FIELD("Basic Layout Code")));
            Caption = 'Basic Layout Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(70; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(80; "Request Page Parameters"; Blob)
        {
            Caption = 'Request Page Parameters';
            DataClassification = CustomerContent;
        }
        field(81; "Use Req. Page Parameters"; Boolean)
        {
            Caption = 'Use Req. Page Parameters';
            DataClassification = CustomerContent;

        }
    }

    keys
    {
        key(Key1; "Source Record ID", Usage)
        {
        }
    }

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;


    procedure GetJobFromRecID(var Job: Record Job)
    var
        RecRef: RecordRef;
    begin
        Clear(Job);
        RecRef.Get("Source Record ID");
        RecRef.SetTable(Job);
    end;





}

