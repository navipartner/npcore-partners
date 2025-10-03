#if not (BC17 or BC18 or BC19 or BC20 or BC21)
page 6184998 "NPR NPEmailDomainDNSRecords"
{
    Extensible = false;
    Caption = 'NP Email Domain DNS Records';
    Editable = false;
    ApplicationArea = NPRNPEmail;
    UsageCategory = None;
    PageType = ListPart;
    SourceTable = "NPR NPEmailDomainDNSRecord";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(RecordRepeater)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = NPRNPEmail;
                    ToolTip = 'Specifies the DNS record type.';
                }
                field(Host; Rec.Host)
                {
                    ApplicationArea = NPRNPEmail;
                    ToolTip = 'Specifies the host component of the DNS record.';
                }
                field(Data; Rec.Data)
                {
                    ApplicationArea = NPRNPEmail;
                    ToolTip = 'Specifies the data component of the DNS record.';
                }
            }
        }
    }

    internal procedure SetTempRecord(var NPEmailDomainDNSRecord: Record "NPR NPEmailDomainDNSRecord")
    begin
        Rec.Copy(NPEmailDomainDNSRecord, true);
    end;

    internal procedure DownloadAsTxt()
    var
        TxtBuilder: TextBuilder;
        TempBlob: Codeunit "Temp Blob";
        FileName: Text;
        OutStr: OutStream;
        InStr: InStream;
    begin
        FileName := 'NPEmailDNSRecords.txt';
        TxtBuilder.AppendLine('Type    Host    Data');
        if Rec.FindSet() then
            repeat
                TxtBuilder.Append(Rec.Type);
                TxtBuilder.Append('    ');
                TxtBuilder.Append(Rec.Host);
                TxtBuilder.Append('    ');
                TxtBuilder.AppendLine(Rec.Data);
            until Rec.Next() = 0;

        TempBlob.CreateOutStream(OutStr);
        OutStr.WriteText(TxtBuilder.ToText());
        TempBlob.CreateInStream(InStr);
        DownloadFromStream(InStr, '', '', '', FileName);
    end;
}
#endif