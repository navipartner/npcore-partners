table 6060019 "GIM - Error Log"
{
    Caption = 'GIM - Error Log';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
        }
        field(5;"Document Log Entry No.";Integer)
        {
            Caption = 'Document Log Entry No.';
        }
        field(6;"Buffer Detail Entry No.";Integer)
        {
            Caption = 'Buffer Detail Entry No.';
        }
        field(10;"Document No.";Code[20])
        {
            Caption = 'Document No.';
        }
        field(30;"Started At";DateTime)
        {
            Caption = 'Started At';
        }
        field(40;"Finished At";DateTime)
        {
            Caption = 'Finished At';
        }
        field(50;Description;Text[250])
        {
            Caption = 'Description';
        }
        field(60;"Codeunit ID";Integer)
        {
            Caption = 'Codeunit ID';
        }
        field(70;"Codeunit Name";Text[30])
        {
            Caption = 'Codeunit Name';
        }
        field(80;"Function Name";Text[128])
        {
            Caption = 'Function Name';
        }
        field(90;"Table ID";Integer)
        {
            Caption = 'Table ID';
        }
        field(91;"Table Caption";Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE ("Object Type"=CONST(TableData),
                                                                           "Object ID"=FIELD("Table ID")));
            Caption = 'Table Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(100;"Field ID";Integer)
        {
            Caption = 'Field ID';
        }
        field(101;"Field Caption";Text[250])
        {
            CalcFormula = Lookup(Field."Field Caption" WHERE (TableNo=FIELD("Table ID"),
                                                              "No."=FIELD("Field ID")));
            Caption = 'Field Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(110;"Mapping Table Line No.";Integer)
        {
            Caption = 'Mapping Table Line No.';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure InsertLine(DocLogEntryNo: Integer;BuffDetailEntryNo: Integer;DocNo: Code[20];StartAt: DateTime;EndAt: DateTime;Desc: Text[250];CodeunitID: Integer;CodeunitName: Text[30];FunctionName: Text[128];TableID: Integer;FieldID: Integer;MappTableLineNo: Integer)
    var
        ErrorLog: Record "GIM - Error Log";
        EntryNo: Integer;
    begin
        if ErrorLog.FindLast then
          EntryNo := ErrorLog."Entry No." + 1
        else
          EntryNo := 1;

        Init;
        "Entry No." := EntryNo;
        "Document Log Entry No." := DocLogEntryNo;
        "Buffer Detail Entry No." := BuffDetailEntryNo;
        "Document No." := DocNo;
        "Started At" := StartAt;
        "Finished At" := EndAt;
        Description := Desc;
        "Codeunit ID" := CodeunitID;
        "Codeunit Name" := CodeunitName;
        "Function Name" := FunctionName;
        "Table ID" := TableID;
        "Field ID" := FieldID;
        "Mapping Table Line No." := MappTableLineNo;
        Insert;
    end;
}

