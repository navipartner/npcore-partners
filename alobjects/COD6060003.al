codeunit 6060003 "GIM - Data Verification"
{
    TableNo = "GIM - Import Document";

    trigger OnRun()
    begin
        GIMImportDoc := Rec;

        ImpEntity.SetRange("Document No.",GIMImportDoc."No.");
        ImpEntity.DeleteAll;

        MappingTableLine.SetCurrentKey(Priority);
        MappingTableLine.SetRange("Document No.",GIMImportDoc."No.");
        if MappingTableLine.FindSet then
          repeat
            BufferTable.DataVerification(MappingTableLine,false);
            BufferTable.Modify;
          until MappingTableLine.Next = 0;

        //data creation test is done as part of data verification as Data Creation step should create data with no errors
        //in this code we also apply all mapping settings that rely on field validation
        DataCreationTestRunner.SetEntity2(false,0);
        DataCreationTestRunner.Run(Rec);

        //after test code is run, we can now apply field validation results and repeat data verification step
        ImpEntity.SetFilter("Validation Value",'<>%1','');
        if ImpEntity.FindSet then begin
          repeat
            BufferTable.Reset;
            BufferTable.SetRange("Document No.",GIMImportDoc."No.");
            BufferTable.SetRange("Row No.",ImpEntity."Row No.");
            BufferTable.SetRange("Mapping Table Line No.",ImpEntity."Mapping Table Line No.");
            BufferTable.SetRange("Field ID",ImpEntity."Field ID");
            if BufferTable.FindSet then
              repeat
                if BufferTable."Find Filter" and (BufferTable."Filter Value Type" = BufferTable."Filter Value Type"::Const) and (BufferTable."Filter Value" = '') then begin
                  BufferTable."Filter Value" := ImpEntity."Validation Value";
                  BufferTable.Modify;
                end;
                if (BufferTable."Value Type" = BufferTable."Value Type"::Const) and (BufferTable."Const Value" = '') then begin
                  BufferTable."Const Value" := ImpEntity."Validation Value";
                  BufferTable."Formatted Value" := ImpEntity."Validation Value";
                  BufferTable.DataTypeValidation();
                  BufferTable.Modify;
                end;
              until BufferTable.Next = 0;
          until ImpEntity.Next = 0;

          ImpEntity.SetRange("Validation Value");
          ImpEntity.DeleteAll;
          Clear(BufferTable);
          if MappingTableLine.FindSet then
            repeat
              BufferTable.DataVerification(MappingTableLine,true);
              BufferTable.Modify;
            until MappingTableLine.Next = 0;
        end;

        ErrLog.SetRange("Document No.",GIMImportDoc."No.");
        ErrLog.SetRange("Document Log Entry No.",0);
        ErrExists := ErrLog.Count <> 0;

        BufferTable.Reset;
        BufferTable.SetRange("Document No.",GIMImportDoc."No.");
        BufferTable.SetRange("Failed Data Verification",true);
        if (BufferTable.Count <> 0) or ErrExists then begin
          Commit; //we want to preserve all the fail reasons and checks so the ERROR in next line doesn't rollback
          Error(Text001);
        end;
    end;

    var
        GIMImportDoc: Record "GIM - Import Document";
        BufferTable: Record "GIM - Import Buffer Detail";
        MappingTableLine: Record "GIM - Mapping Table Line";
        Text001: Label 'Some data hasn''t passed data verification.';
        ImpEntity: Record "GIM - Import Entity";
        DataCreationTestRunner: Codeunit "GIM - Data Create Test Runner";
        ErrExists: Boolean;
        ErrLog: Record "GIM - Error Log";
}

