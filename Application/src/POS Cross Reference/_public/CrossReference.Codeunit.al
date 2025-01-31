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

    procedure GetCrossReferenceIds(TableName: Text[250]; RecordValue: Text[100]; ReferenceNo: Code[50]; var ListOfSystemId: List of [Guid])
    var
        POSCrossReference: Record "NPR POS Cross Reference";
    begin
        POSCrossReference.SetCurrentKey("Reference No.", "Table Name");
        POSCrossReference.SetRange("Reference No.", ReferenceNo);
        POSCrossReference.SetRange("Table Name", TableName);
        if RecordValue <> '' then
            POSCrossReference.SetRange("Record Value", RecordValue);
        if POSCrossReference.FindSet() then
            repeat
                ListOfSystemId.Add(POSCrossReference.SystemId);
            until POSCrossReference.Next() = 0;
    end;


}