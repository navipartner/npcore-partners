codeunit 6060001 "GIM - Data Type Validator"
{
    TableNo = "GIM - Import Document";

    trigger OnRun()
    begin
        //checking data types
        GIMImportDoc := Rec;

        BufferDetail.SetRange("Document No.",GIMImportDoc."No.");
        if BufferDetail.Count = 0 then begin
          MapTableField.SetRange("Document No.",GIMImportDoc."No.");
          if MapTableField.Count = 0 then
            MapTableLine.SelectVersion(false,GIMImportDoc."No.",GIMImportDoc."Document Type",GIMImportDoc."Sender ID",0);
          if MapTableField.Count = 0 then
            Error(Text001);
          GIMParser.ParseFile(GIMImportDoc,false,0,0,0);
        end;
        BufferDetail.FindSet;
        repeat
          BufferDetail.DataTypeValidation();
          BufferDetail.Modify;
        until BufferDetail.Next = 0;

        BufferDetail.SetRange("Failed Data Type Validation",true);
        if BufferDetail.Count <> 0 then begin
          Commit;
          Error(Text002);
        end;
        Rec := GIMImportDoc;
    end;

    var
        GIMImportDoc: Record "GIM - Import Document";
        BufferDetail: Record "GIM - Import Buffer Detail";
        Text001: Label 'First you need to define mappings under Define Mapping before you can continue with the process.';
        Text002: Label 'Some data hasn''t passed data type validation.';
        MapTableField: Record "GIM - Mapping Table Field";
        GIMParser: Codeunit "GIM - Parser";
        MapTableLine: Record "GIM - Mapping Table Line";
}

