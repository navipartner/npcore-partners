table 6151525 "NPR Nc Collector"
{
    Caption = 'Nc Collector';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Nc Collector List";
    LookupPageID = "NPR Nc Collector List";

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

            trigger OnValidate()
            var
                NcCollectorFilter: Record "NPR Nc Collector Filter";
            begin
                if "Table No." <> xRec."Table No." then begin
                    NcCollectorFilter.SetRange("Collector Code", Code);
                    if not NcCollectorFilter.IsEmpty() then
                        Error(RemoveFiltersErr);
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

            trigger OnValidate()
            begin
                CheckCriteriaActiveCollector();
            end;
        }
        field(50; "Max. Lines per Collection"; Integer)
        {
            Caption = 'Max. Lines per Collection';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckCriteriaActiveCollector();
            end;
        }
        field(70; "Wait to Send"; Duration)
        {
            Caption = 'Wait to Send';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckCriteriaActiveCollector();
            end;
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

    trigger OnDelete()
    var
        NcCollection: Record "NPR Nc Collection";
        NcCollectorFilter: Record "NPR Nc Collector Filter";
    begin
        NcCollection.SetRange("Collector Code", Code);
        if not NcCollection.IsEmpty then
            Error(CannotDeleteErr, TableCaption, Code, NcCollection.TableCaption);
        NcCollectorFilter.SetRange("Collector Code", Code);
        NcCollectorFilter.DeleteAll(true);
    end;

    var
        RemoveFiltersErr: Label 'Please remove filters first.';
        CannotDeleteErr: Label 'You cannot delete %1 %2 because there are %3 records for this record.';
        ActivationNotAllowedErr: Label 'Collector %1 must have a value in field %2 and-or field %3 to be active. ';

    local procedure CheckCriteriaActiveCollector()
    begin
        if Active and ("Wait to Send" = 0) and ("Max. Lines per Collection" = 0) then
            Error(ActivationNotAllowedErr, Code, FieldCaption("Wait to Send"), FieldCaption("Max. Lines per Collection"));
    end;
}

