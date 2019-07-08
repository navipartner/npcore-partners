table 6151525 "Nc Collector"
{
    // NC2.01 /BR  /20160909  CASE 250447 NaviConnect: Object created
    // NC2.04 /BR  /20170510  CASE 274524 Removed field 60: Send when Max. Lines, added checks for Activation

    Caption = 'Nc Collector';
    DrillDownPageID = "Nc Collector List";
    LookupPageID = "Nc Collector List";

    fields
    {
        field(10;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(20;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(30;"Table No.";Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Table));

            trigger OnValidate()
            var
                NcCollectorFilter: Record "Nc Collector Filter";
            begin
                if "Table No." <> xRec."Table No." then begin
                  NcCollectorFilter.SetRange("Collector Code",Code);
                  if not NcCollectorFilter.IsEmpty then
                    Error(TxtRemoveFilters);
                end;
            end;
        }
        field(35;"Table Name";Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE ("Object Type"=CONST(Table),
                                                             "Object ID"=FIELD("Table No.")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(40;Active;Boolean)
        {
            Caption = 'Active';

            trigger OnValidate()
            begin
                //-NC2.04 [274524]
                CheckCriteriaActiveCollector;
                //+NC2.04 [274524]
            end;
        }
        field(50;"Max. Lines per Collection";Integer)
        {
            Caption = 'Max. Lines per Collection';

            trigger OnValidate()
            begin
                //-NC2.04 [274524]
                CheckCriteriaActiveCollector;
                //+NC2.04 [274524]
            end;
        }
        field(70;"Wait to Send";Duration)
        {
            Caption = 'Wait to Send';

            trigger OnValidate()
            begin
                //-NC2.04 [274524]
                CheckCriteriaActiveCollector;
                //+NC2.04 [274524]
            end;
        }
        field(80;"Delete Obsolete Lines";Boolean)
        {
            Caption = 'Delete Obsolete Lines';
        }
        field(90;"Delete Sent Collections After";Duration)
        {
            Caption = 'Delete Sent Collections After';
        }
        field(100;"Record Insert";Boolean)
        {
            Caption = 'Insert';
        }
        field(101;"Record Modify";Boolean)
        {
            Caption = 'Modify';
        }
        field(102;"Record Delete";Boolean)
        {
            Caption = 'Delete';
        }
        field(103;"Record Rename";Boolean)
        {
            Caption = 'Rename';
        }
        field(200;"Max. Lines per Request";Integer)
        {
            Caption = 'Max. Lines per Request';
        }
        field(210;"Allow Request from Database";Text[250])
        {
            Caption = 'Allow Request from Database';
        }
        field(220;"Allow Request from Company";Text[30])
        {
            Caption = 'Allow Request from Company';
        }
        field(230;"Allow Request from User ID";Text[50])
        {
            Caption = 'Allow Request from User ID';
        }
        field(240;"Request Name";Text[30])
        {
            Caption = 'Request Name';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        NcCollection: Record "Nc Collection";
        NcCollectorFilter: Record "Nc Collector Filter";
    begin
        NcCollection.SetRange("Collector Code",Code);
        if not NcCollection.IsEmpty then
          Error(TxtCannotDelete,TableCaption,Code,NcCollection.TableCaption);
        NcCollectorFilter.SetRange("Collector Code",Code);
        NcCollectorFilter.DeleteAll(true);
    end;

    var
        TxtRemoveFilters: Label 'Please remove filters first.';
        TxtCannotDelete: Label 'You cannot delete %1 %2 because there are %1 records for this record.';
        TxtActivationNotAllowed: Label 'Collector %1 must have a value in field %2 and-or field %3 to be active. ';

    local procedure LinkedSetupExists(): Boolean
    begin
    end;

    local procedure CheckCriteriaActiveCollector()
    begin
        //-NC2.04 [274524]
        if Active and ("Wait to Send" = 0) and ("Max. Lines per Collection" = 0) then
          Error(StrSubstNo(TxtActivationNotAllowed,Code,FieldCaption("Wait to Send"),FieldCaption("Max. Lines per Collection")));
        //+NC2.04 [274524]
    end;
}

