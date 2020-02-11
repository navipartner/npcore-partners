codeunit 6151221 "PrintNode Mgt."
{
    // NPR5.53/THRO/20200106 CASE 383562 Object Created


    trigger OnRun()
    begin
    end;

    var
        NaviDocsHandlingProfileTxt: Label 'PrintNode printing';
        RemovedTxt: Label 'Printer Removed';
        NoDefaultPrinterErr: Label 'No default Printer found.';
        RecordNotFoundErr: Label 'Document %1 not found.';
        NoOutputErr: Label 'No output from Report %1.';

    procedure LookupPrinter(var PrinterId: Text): Boolean
    var
        PrintNodePrinter: Record "PrintNode Printer";
    begin
        if PAGE.RunModal(6151221,PrintNodePrinter) = ACTION::LookupOK then begin
          PrinterId := PrintNodePrinter.Id;
          exit(true);
        end;
    end;

    procedure RefreshPrinters()
    var
        Printer: Record "PrintNode Printer";
        TempPrinter: Record "PrintNode Printer" temporary;
        PrintNodeAPIMgt: Codeunit "PrintNode API Mgt.";
    begin
        if not PrintNodeAPIMgt.GetPrinters(TempPrinter) then
          exit;
        if Printer.FindSet(true) then
          repeat
            if TempPrinter.Get(Printer.Id) then begin
              Printer.Name := TempPrinter.Name;
              Printer.Description := TempPrinter.Description;
              Printer.Modify(true);
              TempPrinter.Delete(false);
            end else begin
              Printer.Delete(true);
            end;
          until Printer.Next = 0;
        if TempPrinter.FindSet then
          repeat
            Printer := TempPrinter;
            Printer.Insert(true);
          until TempPrinter.Next = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6059767, 'OnAddHandlingProfilesToLibrary', '', true, true)]
    local procedure AddNaviDocsHandlingProfile()
    var
        NaviDocsManagement: Codeunit "NaviDocs Management";
    begin
        NaviDocsManagement.AddHandlingProfileToLibrary(NaviDocsHandlingProfileCode,NaviDocsHandlingProfileTxt,true,false,false,false);
    end;

    local procedure NaviDocsHandlingProfileCode(): Text
    begin
        exit('PRINTNODE-PDF');
    end;

    local procedure AddPrintNodeJobtoNaviDocs(RecordVariant: Variant;PrinterID: Text;ReportID: Integer;DelayUntil: DateTime)
    var
        NaviDocsManagement: Codeunit "NaviDocs Management";
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        DataTypeManagement.GetRecordRef(RecordVariant,RecRef);
        NaviDocsManagement.AddDocumentEntryWithHandlingProfileExt(RecRef,NaviDocsHandlingProfileCode,ReportID,'',PrinterID,DelayUntil);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6059767, 'OnManageDocument', '', true, true)]
    local procedure HandleNaviDocsDocument(var IsDocumentHandled: Boolean;ProfileCode: Code[20];var NaviDocsEntry: Record "NaviDocs Entry";ReportID: Integer;var WithSuccess: Boolean;var ErrorMessage: Text)
    var
        OutPDFStream: DotNet npNetMemoryStream;
        PrintNodeAPIMgt: Codeunit "PrintNode API Mgt.";
        RecRef: RecordRef;
        PrinterId: Text;
    begin
        if IsDocumentHandled or (ProfileCode <> NaviDocsHandlingProfileCode) then
          exit;

        PrinterId := NaviDocsEntry."Template Code";
        //IF PrinterId = '' THEN
        //   PrinterId := FindPrinter(NaviDocsEntry."Insert User ID",ReportID);

        if PrinterId = '' then
          ErrorMessage := NoDefaultPrinterErr;

        if ErrorMessage = '' then
          if not RecRef.Get(NaviDocsEntry."Record ID") then
            ErrorMessage := StrSubstNo(RecordNotFoundErr,NaviDocsEntry."Record ID");

        // GetOutput
        if ErrorMessage = '' then begin
          //TempBlob.INIT;
          //TempBlob.Blob.CREATEOUTSTREAM(DataStream);
          RecRef.SetRecFilter;
          SetCustomReportLayout(RecRef,ReportID);
          OutPDFStream := OutPDFStream.MemoryStream();
          REPORT.SaveAs(ReportID,'',REPORTFORMAT::Pdf,OutPDFStream,RecRef);
          if OutPDFStream.Length < 1 then
            ErrorMessage := StrSubstNo(NoOutputErr,ReportID);
          ClearCustomReportLayout;
        end;

        //Send to printer
        if ErrorMessage = '' then begin
          PrintNodeAPIMgt.SendPDFStream(PrinterId,OutPDFStream,NaviDocsEntry."Document Description",'','');
        end;

        IsDocumentHandled := true;
        WithSuccess := ErrorMessage = '';
    end;

    local procedure SetCustomReportLayout(RecRef: RecordRef;ReportID: Integer)
    var
        CustomReportSelection: Record "Custom Report Selection";
        ReportLayoutSelection: Record "Report Layout Selection";
        CustomReportLayout: Record "Custom Report Layout";
        EmailNaviDocsMgtWrapper: Codeunit "E-mail NaviDocs Mgt. Wrapper";
        CustomReportLayoutVariant: Variant;
    begin
        if RecRef.Number in [18,36,112,114] then begin
          CustomReportSelection.SetRange("Source Type",DATABASE::Customer);
          if RecRef.Number = 18 then
            CustomReportSelection.SetRange("Source No.",Format(RecRef.Field(1).Value))
          else
            CustomReportSelection.SetRange("Source No.",Format(RecRef.Field(4).Value));
          CustomReportSelection.SetRange("Report ID",ReportID);
          if CustomReportSelection.FindFirst then begin
            EmailNaviDocsMgtWrapper.GetCustomReportLayoutVariant(CustomReportSelection,CustomReportLayoutVariant);
            if CustomReportLayout.Get(CustomReportLayoutVariant) then
              ReportLayoutSelection.SetTempLayoutSelected(CustomReportLayoutVariant);
          end;
        end;
    end;

    local procedure ClearCustomReportLayout()
    var
        ReportLayoutSelection: Record "Report Layout Selection";
        CustomReportSelection: Record "Custom Report Selection";
        EmailNaviDocsMgtWrapper: Codeunit "E-mail NaviDocs Mgt. Wrapper";
        BlankVariant: Variant;
    begin
        EmailNaviDocsMgtWrapper.GetCustomReportLayoutVariant(CustomReportSelection,BlankVariant);
        ReportLayoutSelection.SetTempLayoutSelected(BlankVariant);
    end;
}

