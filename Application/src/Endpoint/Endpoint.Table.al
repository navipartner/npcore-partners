table 6014674 "NPR Endpoint"
{
    Access = Internal;
    Caption = 'Endpoint';
    DrillDownPageID = "NPR Endpoint List";
    LookupPageID = "NPR Endpoint List";
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(20; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(30; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                EndpointFilter: Record "NPR Endpoint Filter";
            begin
                if "Table No." <> xRec."Table No." then begin
                    EndpointFilter.SetRange("Endpoint Code", Code);
                    if not EndpointFilter.IsEmpty then
                        Error(TxtRemoveFilters);
                end;
            end;
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
        field(50; "Max. Requests per Batch"; Integer)
        {
            Caption = 'Max. Requests per Batch';
            DataClassification = CustomerContent;
        }
        field(60; "Send when Max. Requests"; Boolean)
        {
            Caption = 'Send when Max. Requests';
            DataClassification = CustomerContent;
        }
        field(70; "Wait to Send"; Duration)
        {
            Caption = 'Wait to Send';
            DataClassification = CustomerContent;
        }
        field(80; "Delete Obsolete Requests"; Boolean)
        {
            Caption = 'Delete Obsolete Requests';
            DataClassification = CustomerContent;
        }
        field(90; "Delete Sent Requests After"; Duration)
        {
            Caption = 'Delete Sent Requests After';
            DataClassification = CustomerContent;
        }
        field(100; "Trigger on Insert"; Boolean)
        {
            Caption = 'Insert';
            DataClassification = CustomerContent;
        }
        field(101; "Trigger on Modify"; Boolean)
        {
            Caption = 'Modify';
            DataClassification = CustomerContent;
        }
        field(102; "Trigger on Delete"; Boolean)
        {
            Caption = 'Delete';
            DataClassification = CustomerContent;
        }
        field(103; "Trigger on Rename"; Boolean)
        {
            Caption = 'Rename';
            DataClassification = CustomerContent;
        }
        field(200; "Max. Requests per Query"; Integer)
        {
            Caption = 'Max. Requests per Query';
            Description = 'CASE 234602';
            DataClassification = CustomerContent;
        }
        field(210; "Allow Query from Database"; Text[250])
        {
            Caption = 'Allow Query from Database';
            Description = 'CASE 234602';
            DataClassification = CustomerContent;
        }
        field(220; "Allow Query from Company Name"; Text[30])
        {
            Caption = 'Allow Query from Company Name';
            Description = 'CASE 234602';
            DataClassification = CustomerContent;
        }
        field(230; "Allow Query from User ID"; Text[50])
        {
            Caption = 'Allow Query from User ID';
            Description = 'CASE 234602';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(240; "Query Name"; Text[30])
        {
            Caption = 'Query Name';
            Description = 'CASE 234602';
            DataClassification = CustomerContent;
        }
        field(300; "No. of Inboud Queries"; Integer)
        {
            CalcFormula = Count("NPR Endpoint Query" WHERE("Endpoint Code" = FIELD(Code),
                                                        Direction = CONST(Incoming)));
            Caption = 'No. of Inboud Queries';
            Editable = false;
            FieldClass = FlowField;
        }
        field(310; "No. of Outbound Queries"; Integer)
        {
            CalcFormula = Count("NPR Endpoint Query" WHERE("Endpoint Code" = FIELD(Code),
                                                        Direction = CONST(Outgoing)));
            Caption = 'No. of Outbound Queries';
            Editable = false;
            FieldClass = FlowField;
        }
        field(320; "No. of Requests"; Integer)
        {
            CalcFormula = Count("NPR Endpoint Request" WHERE("Endpoint Code" = FIELD(Code)));
            Caption = 'No. of Requests';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
        key(Key2; "Query Name")
        {
        }
    }

    trigger OnDelete()
    var
        EndpointRequestBatch: Record "NPR Endpoint Request Batch";
        EndpointFilter: Record "NPR Endpoint Filter";
    begin
        EndpointRequestBatch.SetRange("Endpoint Code", Code);
        if not EndpointRequestBatch.IsEmpty then
            Error(TxtCannotDelete, TableCaption, Code, EndpointRequestBatch.TableCaption);
        EndpointFilter.SetRange("Endpoint Code", Code);
        EndpointFilter.DeleteAll(true);
    end;

    var
        TxtRemoveFilters: Label 'Please remove filters first.';
        TxtCannotDelete: Label 'You cannot delete %1 %2 because there are %3 records for this record.';
}

