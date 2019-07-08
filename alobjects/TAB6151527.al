table 6151527 "Nc Collection"
{
    // NC2.01\BR\20160909  CASE 250447 NaviConnect: Object created

    Caption = 'Nc Collection';
    DrillDownPageID = "Nc Collection List";
    LookupPageID = "Nc Collection List";

    fields
    {
        field(1;"No.";BigInteger)
        {
            AutoIncrement = true;
            Caption = 'No.';
        }
        field(10;"Collector Code";Code[20])
        {
            Caption = 'Collector Code';
            TableRelation = "Nc Collector";
        }
        field(30;Status;Option)
        {
            Caption = 'Status';
            OptionCaption = 'Collecting,Ready to Send,Sent';
            OptionMembers = Collecting,"Ready to Send",Sent;
        }
        field(40;"Creation Date";DateTime)
        {
            Caption = 'Creation Date';
        }
        field(50;"Ready to Send Date";DateTime)
        {
            Caption = 'Ready to Send Date';
        }
        field(60;"Sent Date";DateTime)
        {
            Caption = 'Sent Date';
        }
        field(100;"Table No.";Integer)
        {
            Caption = 'Table No.';
        }
        field(200;"No. of Lines";Integer)
        {
            CalcFormula = Count("Nc Collection Line" WHERE ("Collector Code"=FIELD("Collector Code"),
                                                            "Collection No."=FIELD("No.")));
            Caption = 'No. of Lines';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
        key(Key2;"Collector Code",Status)
        {
        }
        key(Key3;"Collector Code","No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        NcCollectionLine: Record "Nc Collection Line";
    begin
        NcCollectionLine.Reset;
        NcCollectionLine.SetFilter("Collection No.",'=%1',"No.");
        NcCollectionLine.DeleteAll(true);
    end;

    trigger OnInsert()
    begin
        "Creation Date" := CurrentDateTime;
    end;

    trigger OnModify()
    begin
        case Status of
          Status :: "Ready to Send" :
            if "Ready to Send Date" = 0DT then
              "Ready to Send Date" := CurrentDateTime;
          Status :: Sent :
            if "Sent Date" = 0DT then
              "Sent Date" := CurrentDateTime;
        end;
    end;
}

