table 6060006 "GIM - Import Buffer"
{
    Caption = 'GIM - Import Buffer';
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
        field(20;"Parsed Text";Text[250])
        {
            Caption = 'Parsed Text';

            trigger OnValidate()
            begin
                BufferDetail.SetRange("Document No.","Document No.");
                BufferDetail.SetRange("Column ID","Column No.");
                BufferDetail.SetRange("Row No.","Row No.");
                if BufferDetail.FindSet then
                  repeat
                    BufferDetail.Validate("Parsed Text","Parsed Text");
                    BufferDetail.Modify;
                  until BufferDetail.Next = 0;
            end;
        }
        field(25;"Skip Processing";Boolean)
        {
            Caption = 'Skip Processing';
        }
        field(30;"Column Name";Text[50])
        {
            Caption = 'Column Name';
        }
        field(45;Level;Integer)
        {
            Caption = 'Level';
        }
        field(50;"Parent Entry No.";Integer)
        {
            Caption = 'Parent Entry No.';
        }
        field(100;"Column No.";Integer)
        {
            Caption = 'Column No.';
        }
        field(110;"Row No.";Integer)
        {
            Caption = 'Row No.';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Row No.")
        {
        }
        key(Key3;"Column No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        BufferDetail: Record "GIM - Import Buffer Detail";
        ImportEntity: Record "GIM - Import Entity";

    procedure InsertLine(DocNo: Code[20];ParsedText: Text[250];ColumnNo: Integer;RowNo: Integer;LevelHere: Integer;ParentEntryNo: Integer)
    var
        EntryNo: Integer;
        ImportBuffer: Record "GIM - Import Buffer";
        MappingTable: Record "GIM - Mapping Table";
    begin
        if ImportBuffer.FindLast then
          EntryNo := ImportBuffer."Entry No." + 1
        else
          EntryNo := 1;

        Init;
        "Entry No." := EntryNo;
        "Document No." := DocNo;
        "Parsed Text" := ParsedText;
        "Column No." := ColumnNo;
        "Row No." := RowNo;
        if ColumnNo <> 0 then begin
          MappingTable.SetRange("Document No.",DocNo);
          MappingTable.SetRange("Column No.",ColumnNo);
          if MappingTable.FindFirst then
            "Column Name" := MappingTable."Column Name";
        end;
        Level := LevelHere;
        "Parent Entry No." := ParentEntryNo;
        Insert;
    end;
}

