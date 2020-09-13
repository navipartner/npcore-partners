table 6014676 "NPR Endpoint Request Batch"
{
    // NPR5.23\BR\20160518  CASE 237658 Object created

    Caption = 'Endpoint Request Batch';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(10; "Endpoint Code"; Code[20])
        {
            Caption = 'Endpoint Code';
            TableRelation = "NPR Endpoint";
            DataClassification = CustomerContent;
        }
        field(30; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Collecting,Ready to Send,Sent';
            OptionMembers = Collecting,"Ready to Send",Sent;
            DataClassification = CustomerContent;
        }
        field(40; "Creation Date"; DateTime)
        {
            Caption = 'Creation Date';
            DataClassification = CustomerContent;
        }
        field(50; "Ready to Send Date"; DateTime)
        {
            Caption = 'Ready to Send Date';
            DataClassification = CustomerContent;
        }
        field(60; "Sent Date"; DateTime)
        {
            Caption = 'Sent Date';
            DataClassification = CustomerContent;
        }
        field(100; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
        }
        field(200; "No. of Requests"; Integer)
        {
            CalcFormula = Count ("NPR Endpoint Request" WHERE("Request Batch No." = FIELD("No.")));
            Caption = 'No. of Requests';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; "Endpoint Code", Status)
        {
        }
        key(Key3; "Endpoint Code", "No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        EndpointRequest: Record "NPR Endpoint Request";
    begin
        EndpointRequest.Reset;
        EndpointRequest.SetFilter("Endpoint Code", '=%1', "Endpoint Code");
        EndpointRequest.DeleteAll(true);
    end;

    trigger OnInsert()
    begin
        "Creation Date" := CurrentDateTime;
    end;

    trigger OnModify()
    begin
        case Status of
            Status::"Ready to Send":
                if "Ready to Send Date" = 0DT then
                    "Ready to Send Date" := CurrentDateTime;
            Status::Sent:
                if "Sent Date" = 0DT then
                    "Sent Date" := CurrentDateTime;
        end;
    end;
}

