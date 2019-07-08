page 6060028 "GIM - Import Entities 2"
{
    Caption = 'GIM - Import Entities 2';
    Editable = false;
    PageType = List;
    SourceTable = "GIM - Import Buffer Detail";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = "Buffer Indentation Level";
                IndentationControls = "Table Caption";
                ShowAsTree = true;
                field("Table Caption";"Table Caption")
                {
                }
            }
            part(Control6150617;"GIM - Import Entities Subpage")
            {
                SubPageLink = "Document No."=FIELD("Document No."),
                              "Row No."=FIELD("Row No."),
                              "Mapping Table Line No."=FIELD("Mapping Table Line No.");
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        DocNo := GetFilter("Document No.");
        if DocNo = '' then
          Error(Text001);

        EntryNo := 1;
        BufferDetail.SetCurrentKey(Priority);
        BufferDetail.SetRange("Document No.",DocNo);
        if BufferDetail.FindSet then
          repeat
            MapTableLine.SetRange("Document No.",BufferDetail."Document No.");
            MapTableLine.SetRange("Line No.",BufferDetail."Mapping Table Line No.");
            if MapTableLine.FindFirst and (MapTableLine."Data Action" <> MapTableLine."Data Action"::" ") then begin
              SetRange("Mapping Table Line No.",BufferDetail."Mapping Table Line No.");
              SetRange("Row No.",BufferDetail."Row No.");
              SetRange("Buffer Indentation Level",BufferDetail."Buffer Indentation Level");
              if not FindFirst then begin
                Init;
                "Entry No." := EntryNo;
                "Document No." := BufferDetail."Document No.";
                "Table ID" := BufferDetail."Table ID";
                Priority := BufferDetail.Priority;
                "Buffer Indentation Level" := BufferDetail."Buffer Indentation Level";
                "Row No." := BufferDetail."Row No.";
                "Mapping Table Line No." := BufferDetail."Mapping Table Line No.";
                Insert;
                EntryNo += 1;
              end;
            end;
          until BufferDetail.Next = 0;

        Reset;
        SetCurrentKey("Row No.");
    end;

    var
        DocNo: Code[20];
        Text001: Label 'You can''t run this page as a standalone page.';
        BufferDetail: Record "GIM - Import Buffer Detail";
        EntryNo: Integer;
        MapTableLine: Record "GIM - Mapping Table Line";
}

