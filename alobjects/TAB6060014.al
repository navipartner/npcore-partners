table 6060014 "GIM - Import Entity"
{
    Caption = 'GIM - Import Entity';
    LookupPageID = "GIM - Mapping";

    fields
    {
        field(1;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
        }
        field(10;"Document No.";Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "GIM - Import Document";
        }
        field(20;"Row No.";Integer)
        {
            Caption = 'Row No.';
        }
        field(30;"Column No.";Integer)
        {
            Caption = 'Column No.';
        }
        field(40;"Table ID";Integer)
        {
            Caption = 'Table ID';
        }
        field(41;"Table Caption";Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=CONST(TableData),
                                                                           "Object ID"=FIELD("Table ID")));
            Caption = 'Table Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50;"Field ID";Integer)
        {
            Caption = 'Field ID';
        }
        field(51;"Field Caption";Text[250])
        {
            CalcFormula = Lookup(Field."Field Caption" WHERE (TableNo=FIELD("Table ID"),
                                                              "No."=FIELD("Field ID")));
            Caption = 'Field Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(52;"Part of Primary Key";Boolean)
        {
            Caption = 'Part of Primary Key';
        }
        field(60;"Data Type";Text[30])
        {
            Caption = 'Data Type';
        }
        field(61;"Integer Value";Integer)
        {
            Caption = 'Integer Value';
        }
        field(62;"Decimal Value";Decimal)
        {
            Caption = 'Decimal Value';
        }
        field(63;"Date Value";Date)
        {
            Caption = 'Date Value';
        }
        field(64;"Time Value";Time)
        {
            Caption = 'Time Value';
        }
        field(65;"Datetime Value";DateTime)
        {
            Caption = 'Datetime Value';
        }
        field(66;"Boolean Value";Boolean)
        {
            Caption = 'Boolean Value';
        }
        field(67;"DateFormula Value";DateFormula)
        {
            Caption = 'DateFormula Value';
        }
        field(68;"Option Value";Text[250])
        {
            Caption = 'Option Value';
        }
        field(69;"Text Value";Text[250])
        {
            Caption = 'Text Value';
        }
        field(70;"Current Value";Text[250])
        {
            Caption = 'Current Value';
        }
        field(80;"Validate Field";Boolean)
        {
            Caption = 'Validate Field';
        }
        field(90;"Apply Enrichment";Boolean)
        {
            Caption = 'Apply Enrichment';
        }
        field(100;"Entity Action";Option)
        {
            Caption = 'Entity Action';
            OptionCaption = ' ,Insert,Modify';
            OptionMembers = " ",Insert,Modify;
        }
        field(110;"New Value";Text[250])
        {
            Caption = 'New Value';
        }
        field(120;Priority;Integer)
        {
            Caption = 'Priority';
        }
        field(130;"Buffer Indentation Level";Integer)
        {
            Caption = 'Buffer Indentation Level';
        }
        field(140;"Mapping Table Line No.";Integer)
        {
            Caption = 'Mapping Table Line No.';
        }
        field(150;"Column ID";Integer)
        {
            Caption = 'Column ID';
        }
        field(160;"Validation Value";Text[250])
        {
            Caption = 'Validation Value';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Row No.","Table ID","Column No.","Field ID")
        {
        }
    }

    fieldgroups
    {
    }

    procedure InsertLine(ImpBufferDetail: Record "GIM - Import Buffer Detail")
    var
        EntryNo: Integer;
        ImportEnt: Record "GIM - Import Entity";
    begin
        if ImportEnt.FindLast then
          EntryNo := ImportEnt."Entry No." + 1
        else
          EntryNo := 1;

        Init;
        "Entry No." := EntryNo;
        "Document No." := ImpBufferDetail."Document No.";
        "Row No." := ImpBufferDetail."Row No.";
        "Column No." := ImpBufferDetail."Column No.";
        "Table ID" := ImpBufferDetail."Table ID";
        "Field ID" := ImpBufferDetail."Field ID";
        "Data Type" := ImpBufferDetail."Field Type";
        Priority := ImpBufferDetail.Priority;
        "Buffer Indentation Level" := ImpBufferDetail."Buffer Indentation Level";
        "Mapping Table Line No." := ImpBufferDetail."Mapping Table Line No.";
        Insert;
    end;
}

