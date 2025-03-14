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

    internal procedure DownloadAsExcel()
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        InStr: InStream;
        FileMgt: Codeunit "File Management";
    begin
        TempExcelBuffer.CreateNewBook('NPEmailDNSRecords');

        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn('Type', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Host', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn('Data', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

        if (Rec.FindSet()) then
            repeat
                TempExcelBuffer.NewRow();
                TempExcelBuffer.AddColumn(Rec.Type, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(Rec.Host, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(Rec.Data, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
            until Rec.Next() = 0;

        TempExcelBuffer.WriteSheet('DNS Records', CompanyName(), UserId());
        TempExcelBuffer.CloseBook();

        TempBlob.CreateOutStream(OutStr);
        TempExcelBuffer.SaveToStream(OutStr, true);
        TempBlob.CreateInStream(InStr);

        FileMgt.DownloadFromStreamHandler(InStr, 'Download DNS Records', '', '', 'NPEmailDNSRecords.xlsx');
    end;
}
#endif