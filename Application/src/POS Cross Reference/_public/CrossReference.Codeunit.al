codeunit 6059905 "NPR Cross Reference"
{
    procedure InitReference(SystemId: Guid; GlobalReference: Code[50]; TableName: Text[250]; RecordValue: Text)
    var
        POSCrossRefMgt: Codeunit "NPR POS Cross Reference Mgt.";
    begin
        POSCrossRefMgt.InitReference(SystemId, GlobalReference, TableName, RecordValue);

    end;

    procedure RemoveReference(SystemId: Guid; TableName: Text[250])
    var
        POSCrossRefMgt: Codeunit "NPR POS Cross Reference Mgt.";
    begin
        POSCrossRefMgt.RemoveReference(SystemId, TableName);

    end;

}