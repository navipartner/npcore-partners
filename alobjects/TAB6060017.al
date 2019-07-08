table 6060017 "GIM - Mapping Table Field Spec"
{
    // GIM8.00.10.1.02/TJ/20150819 CASE 210725 Changed code in AddLine()
    // GIM8.00.10.1.02/TJ/20150819 CASE 210725 Added fields 30 Doc. Type Code, 40 Sender IDCode, 50 Version No. and 60 Mapping Table Line No.
    //                                         Changed primary key
    //                                           from: Document No.,Column No.,Table ID,Field ID,Entry No.
    //                                             to: Document No.,Doc. Type Code,Sender ID,Version No.,Mapping Table Line No.,Field ID,Entry No.

    Caption = 'GIM - Mapping Table Field Spec';
    LookupPageID = "GIM - Mapping Table Field Spec";

    fields
    {
        field(1;"Document No.";Code[20])
        {
            Caption = 'Document No.';
        }
        field(2;"Column No.";Integer)
        {
            Caption = 'Column No.';
        }
        field(3;"Table ID";Integer)
        {
            Caption = 'Table ID';

            trigger OnLookup()
            var
                Objects: Page Objects;
                "Object": Record "Object";
            begin
            end;
        }
        field(4;"Field ID";Integer)
        {
            Caption = 'Field ID';
        }
        field(5;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
        }
        field(10;"Map To";Text[250])
        {
            Caption = 'Map To';

            trigger OnLookup()
            var
                RecRef: RecordRef;
                VarRecRef: Variant;
                FldRef: FieldRef;
                MapTableField: Record "GIM - Mapping Table Field";
                MapTableLine: Record "GIM - Mapping Table Line";
                IntValue: Integer;
                DecValue: Decimal;
                DateValue: Date;
                TimeValue: Time;
                DatetimeValue: DateTime;
                DateFormulaValue: DateFormula;
                BoolValue: Boolean;
                ImpBufferDetail: Record "GIM - Import Buffer Detail";
                TableView: Text[1024];
            begin
                RecRef.Open("Table ID");
                VarRecRef := RecRef;
                if PAGE.RunModal(0,VarRecRef) = ACTION::LookupOK then begin
                  RecRef := VarRecRef;
                  FldRef := RecRef.Field("Field ID");
                  "Map To" := Format(FldRef);
                end;
            end;
        }
        field(20;"File Value";Text[250])
        {
            Caption = 'File Value';
        }
        field(30;"Doc. Type Code";Code[10])
        {
            Caption = 'Doc. Type Code';
        }
        field(40;"Sender ID";Code[20])
        {
            Caption = 'Sender ID';
        }
        field(50;"Version No.";Integer)
        {
            Caption = 'Version No.';
        }
        field(60;"Mapping Table Line No.";Integer)
        {
            Caption = 'Mapping Table Line No.';
        }
        field(70;"Used For";Option)
        {
            Caption = 'Used For';
            OptionCaption = 'Mapping,Filtering';
            OptionMembers = Mapping,Filtering;
        }
        field(80;"Field Caption";Text[250])
        {
            CalcFormula = Lookup(Field."Field Caption" WHERE (TableNo=FIELD("Table ID"),
                                                              "No."=FIELD("Field ID")));
            Caption = 'Field Caption';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Document No.","Doc. Type Code","Sender ID","Version No.","Mapping Table Line No.","Field ID","Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    procedure InsertLine(ReadText: Text[250];ColumnNo: Integer;MapTableField: Record "GIM - Mapping Table Field";UsedFor: Integer)
    var
        MapSpec: Record "GIM - Mapping Table Field Spec";
        EntryNo: Integer;
    begin
        if MapSpec.FindLast then
          EntryNo := MapSpec."Entry No." + 10000
        else
          EntryNo := 10000;

        MapSpec.SetRange("Document No.",MapTableField."Document No.");
        MapSpec.SetRange("Doc. Type Code",MapTableField."Doc. Type Code");
        MapSpec.SetRange("Sender ID",MapTableField."Sender ID");
        MapSpec.SetRange("Version No.",MapTableField."Version No.");
        MapSpec.SetRange("Mapping Table Line No.",MapTableField."Mapping Table Line No.");
        MapSpec.SetRange("Field ID",MapTableField."Field ID");
        MapSpec.SetRange("File Value",ReadText);
        MapSpec.SetRange("Used For",UsedFor);
        if not MapSpec.FindFirst then begin
          Init;
          "Document No." := MapTableField."Document No.";
          "Doc. Type Code" := MapTableField."Doc. Type Code";
          "Sender ID" := MapTableField."Sender ID";
          "Version No." := MapTableField."Version No.";
          "Mapping Table Line No." := MapTableField."Mapping Table Line No.";
          "Field ID" := MapTableField."Field ID";
          "Entry No." := EntryNo;
          "Column No." := ColumnNo;
          "Table ID" := MapTableField."Table ID";
          "File Value" := ReadText;
          "Used For" := UsedFor;
          Insert;
        end;
    end;

    procedure OpenPage(DocNo: Code[20];ColumnNo: Integer;TableID: Integer;FieldID: Integer)
    var
        MapSpec: Record "GIM - Mapping Table Field Spec";
        MapSpecList: Page "GIM - Mapping Table Field Spec";
        MapTableField: Record "GIM - Mapping Table Field";
    begin
        /*
        MapTableField.GET(DocNo,ColumnNo,TableID,FieldID);
        MapTableField.TESTFIELD("Value Type",MapTableField."Value Type"::Specific);
        MapTableField.TESTFIELD("Automatically Created",FALSE);
        MapSpec.SETRANGE("Document No.",DocNo);
        MapSpec.SETRANGE("Column No.",ColumnNo);
        MapSpec.SETRANGE("Table ID",TableID);
        MapSpec.SETRANGE("Field ID",FieldID);
        MapSpec.SETFILTER("Map To",'<>%1','');
        IF NOT MapSpec.FINDFIRST THEN BEGIN
          AddLine(DocNo,ColumnNo,TableID,FieldID);
          COMMIT;
        END;
        MapSpec.SETRANGE("Map To");
        MapSpecList.SETTABLEVIEW(MapSpec);
        MapSpecList.RUNMODAL;
        */

    end;

    procedure AddLine(MapTableField: Record "GIM - Mapping Table Field";ColumnNo: Integer;UsedFor: Integer)
    var
        GIMParser: Codeunit "GIM - Parser";
        ImpDoc: Record "GIM - Import Document";
    begin
        ImpDoc.Get(MapTableField."Document No.");
        GIMParser.SetMapTableFieldSpecData(MapTableField,UsedFor);
        GIMParser.ParseFile(ImpDoc,true,ColumnNo,MapTableField."Table ID",MapTableField."Field ID");
    end;
}

