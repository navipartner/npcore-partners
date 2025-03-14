#if not (BC17 or BC18 or BC19 or BC20 or BC21)
table 6151109 "NPR NPEmailDomainDNSRecord"
{
    Access = Internal;
    Caption = 'NP Email Domain DNS Record';
    TableType = Temporary;

    fields
    {
        field(1; EntryNo; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(2; Type; Text[10])
        {
            Caption = 'Type';
            DataClassification = SystemMetadata;
        }
        field(3; Host; Text[300])
        {
            Caption = 'Host';
            DataClassification = CustomerContent;
        }
        field(4; Data; Text[2048])
        {
            Caption = 'Data';
            DataClassification = CustomerContent;
        }
    }

    var
        _LastEntryNo: Integer;

    internal procedure AddRecord(pType: Text[10]; pHost: Text[300]; pData: Text[2048])
    begin
        _LastEntryNo += 1;

        Rec.Init();
        Rec.EntryNo := _LastEntryNo;
        Rec.Type := pType;
        Rec.Host := pHost;
        Rec.Data := pData;
        Rec.Insert();
    end;
}
#endif