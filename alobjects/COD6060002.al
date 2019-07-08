codeunit 6060002 "GIM - Data Mapper"
{
    TableNo = "GIM - Import Document";

    trigger OnRun()
    begin
        GIMImportDoc := Rec;
        with BufferTable do begin
          SetRange("Document No.",GIMImportDoc."No.");
          SetRange("Skip Column",false);
          SetRange("Skip Row",false);
          if FindSet then
            repeat
              DataMapper();
              Modify;
            until Next = 0;
          SetRange("Failed Data Mapping",true);
          if Count <> 0 then begin
            Commit;
            Error(Text001);
          end;
        end;
        Rec := GIMImportDoc;
    end;

    var
        GIMImportDoc: Record "GIM - Import Document";
        BufferTable: Record "GIM - Import Buffer Detail";
        Text001: Label 'Some data hasn''t passed data mapping.';
}

