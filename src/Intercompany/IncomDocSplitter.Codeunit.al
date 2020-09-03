codeunit 6060074 "NPR Incom. Doc. Splitter"
{
    // NPR5.27/BR  /20160927 CASE 252817 Object Created


    trigger OnRun()
    var
        VendorCode: Code[20];
    begin
        VendorCode := GetVendorCode;
        Initialize;
        ReadFileAndSplit;
        ImportSplitFiles(VendorCode);
        Commit;
        if NoOfIncominDocsCreated > 0 then begin
            if GuiAllowed then
                if Confirm(StrSubstNo(TextDocsCreatedProcess, Format(NoOfIncominDocsCreated)), false) then
                    CreateDocs;
        end else begin
            if GuiAllowed then
                Message(TextNoIncomingDocs);

        end;
    end;

    var
        DataExchangeType: Record "Data Exchange Type";
        TextSelectRecord: Label 'Please select a %1.';
        ServerOutputDirectory: Text;
        TextNoDirectoryReturned: Label 'No file location returned by the file splitter.';
        TextNoDirectoryFound: Label 'File location %1 was not found.';
        TextNoFilesinDirectory: Label 'File location %1 does not contain any files to read.';
        FileMgt: Codeunit "File Management";
        ImportAttachmentIncDoc: Codeunit "Import Attachment - Inc. Doc.";
        NoOfIncominDocsCreated: Integer;
        StartEntryNo: Integer;
        EndEntryNo: Integer;
        TextDocsCreatedProcess: Label '%1 Incoming documents have been created. Would you like to attempt creating Purchase Invoices based on these?  ';
        TextNoIncomingDocs: Label 'No incoming documents were created.';

    local procedure Initialize()
    begin
        NoOfIncominDocsCreated := 0;
        StartEntryNo := 0;
        EndEntryNo := 0;
    end;

    local procedure ReadFileAndSplit()
    var
        DataExchDef: Record "Data Exch. Def";
        FieldDelimiter: Char;
        SplitMethod: Option "0",GroupByColumn,SplitOnValueFirstField;
        SplitOnColumn: Integer;
        SplitOnValue: Text;
        CSVSplitter: Codeunit "NPR CSV Splitter";
    begin
        if PAGE.RunModal(PAGE::"Data Exchange Types", DataExchangeType) <> ACTION::LookupOK then
            Error(TextSelectRecord, DataExchangeType.TableCaption);
        DataExchangeType.TestField("Data Exch. Def. Code");
        DataExchDef.Get(DataExchangeType."Data Exch. Def. Code");
        DataExchDef.TestField("File Type", DataExchDef."File Type"::"Variable Text");
        FieldDelimiter := GetFieldDelimiter(DataExchDef);
        GetSplitParameters(DataExchDef, SplitMethod, SplitOnColumn, SplitOnValue);
        CSVSplitter.Initialize('', FieldDelimiter, '"', SplitMethod, SplitOnColumn, SplitOnValue, DataExchDef."Header Lines", DataExchDef."File Encoding", true);
        ServerOutputDirectory := CSVSplitter.Process;
    end;

    local procedure ImportSplitFiles(VendorCode: Code[20])
    var
        NameValueBuffer: Record "Name/Value Buffer";
        IncomingDocumentFile: File;
    begin
        StartEntryNo := 0;
        EndEntryNo := 0;
        if ServerOutputDirectory = '' then
            Error(TextNoDirectoryReturned);
        if not FileMgt.ServerDirectoryExists(ServerOutputDirectory) then
            Error(TextNoDirectoryFound, ServerOutputDirectory);
        Clear(NameValueBuffer);
        FileMgt.GetServerDirectoryFilesList(NameValueBuffer, ServerOutputDirectory);
        if NameValueBuffer.IsEmpty then
            Error(TextNoFilesinDirectory, ServerOutputDirectory);
        if NameValueBuffer.FindSet then
            repeat
                CreateIncomingDoc(NameValueBuffer.Name, VendorCode);
                Erase(NameValueBuffer.Name);
            until NameValueBuffer.Next = 0;
    end;

    local procedure CreateDocs()
    var
        IncomingDocument: Record "Incoming Document";
    begin
        IncomingDocument.SetRange("Entry No.", StartEntryNo, EndEntryNo);
        if IncomingDocument.FindSet then
            repeat
                IncomingDocument.CreateDocumentWithDataExchange();
            until IncomingDocument.Next = 0;
    end;

    local procedure CreateIncomingDoc(IncDocFileName: Text; VendorCode: Code[10])
    var
        IncomingDocument: Record "Incoming Document";
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        DataExchDef: Record "Data Exch. Def";
    begin
        IncomingDocument.Init;
        IncomingDocument.Validate("Data Exchange Type", DataExchangeType.Code);
        if VendorCode <> '' then
            IncomingDocument.Validate("Vendor No.", VendorCode);
        IncomingDocument.Insert(true);
        if StartEntryNo = 0 then
            StartEntryNo := IncomingDocument."Entry No.";
        EndEntryNo := IncomingDocument."Entry No.";
        NoOfIncominDocsCreated += 1;
        IncomingDocumentAttachment."Incoming Document Entry No." := IncomingDocument."Entry No.";
        IncomingDocumentAttachment.SetRange("Incoming Document Entry No.", IncomingDocument."Entry No.");
        ImportAttachmentIncDoc.ImportAttachment(IncomingDocumentAttachment, IncDocFileName);

        IncomingDocument.Get(IncomingDocument."Entry No.");
        DataExchDef.Get(DataExchangeType."Data Exch. Def. Code");
        UpdateHeaderInfo(IncomingDocument, IncomingDocumentAttachment, DataExchDef);
        IncomingDocument.Modify(true);
    end;

    local procedure UpdateHeaderInfo(var IncomingDocument: Record "Incoming Document"; var IncomingDocumentAttachment: Record "Incoming Document Attachment"; DataExchDef: Record "Data Exch. Def")
    var
        DataExch: Record "Data Exch.";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
        GLEntry: Record "G/L Entry";
    begin
        if DataExchDef."Reading/Writing Codeunit" = 0 then
            exit;
        DataExch.Init;
        DataExch.Insert(true);
        IncomingDocumentAttachment.CalcFields(Content);

        if IncomingDocumentAttachment.IsEmpty then
            exit;
        DataExch."File Content" := IncomingDocumentAttachment.Content;
        DataExch."Data Exch. Def Code" := DataExchDef.Code;
        DataExch.Modify;
        CODEUNIT.Run(DataExchDef."Reading/Writing Codeunit", DataExch);

        //Mapping borrowed from Incoming Document table, function GetDataExchangePath
        IncomingDocument."Vendor Invoice No." := GetHeaderField(DataExch, DATABASE::"Purchase Header", PurchaseHeader.FieldNo("Vendor Invoice No."), MaxStrLen(IncomingDocument."Vendor Invoice No."));
        IncomingDocument."Vendor Name" := GetHeaderField(DataExch, DATABASE::"Purchase Header", PurchaseHeader.FieldNo("Buy-from Vendor Name"), MaxStrLen(IncomingDocument."Vendor Name"));
        IncomingDocument."Order No." := GetHeaderField(DataExch, DATABASE::"Purchase Header", PurchaseHeader.FieldNo("Vendor Order No."), MaxStrLen(IncomingDocument."Order No."));
        if Evaluate(IncomingDocument."Document Date", GetHeaderField(DataExch, DATABASE::"Purchase Header", PurchaseHeader.FieldNo("Document Date"), 0)) then;
        if Evaluate(IncomingDocument."Due Date", GetHeaderField(DataExch, DATABASE::"Purchase Header", PurchaseHeader.FieldNo("Due Date"), 0)) then;
        if Evaluate(IncomingDocument."Amount Excl. VAT", GetHeaderField(DataExch, DATABASE::"Purchase Header", PurchaseHeader.FieldNo(Amount), 0)) then;
        if Evaluate(IncomingDocument."Amount Incl. VAT", GetHeaderField(DataExch, DATABASE::"Purchase Header", PurchaseHeader.FieldNo("Amount Including VAT"), 0)) then;
        if Evaluate(IncomingDocument."VAT Amount", GetHeaderField(DataExch, DATABASE::"G/L Entry", GLEntry.FieldNo("VAT Amount"), 0)) then;
        IncomingDocument."Currency Code" := GetHeaderField(DataExch, DATABASE::"Purchase Header", PurchaseHeader.FieldNo("Currency Code"), MaxStrLen(IncomingDocument."Currency Code"));
        IncomingDocument."Vendor VAT Registration No." := GetHeaderField(DataExch, DATABASE::Vendor, Vendor.FieldNo("VAT Registration No."), MaxStrLen(IncomingDocument."Vendor VAT Registration No."));
        IncomingDocument."Vendor IBAN" := GetHeaderField(DataExch, DATABASE::"Vendor Bank Account", VendorBankAccount.FieldNo(IBAN), MaxStrLen(IncomingDocument."Vendor IBAN"));
        IncomingDocument."Vendor Bank Branch No." := GetHeaderField(DataExch, DATABASE::"Vendor Bank Account", VendorBankAccount.FieldNo("Bank Branch No."), MaxStrLen(IncomingDocument."Vendor Bank Branch No."));
        IncomingDocument."Vendor Bank Account No." := GetHeaderField(DataExch, DATABASE::"Vendor Bank Account", VendorBankAccount.FieldNo("Bank Account No."), MaxStrLen(IncomingDocument."Vendor IBAN"));
        IncomingDocument."Vendor Phone No." := GetHeaderField(DataExch, DATABASE::Vendor, Vendor.FieldNo("Phone No."), MaxStrLen(IncomingDocument."Vendor Phone No."));

        DataExch.Delete(true);
    end;

    local procedure GetVendorCode(): Code[20]
    var
        Vendor: Record Vendor;
    begin
        if PAGE.RunModal(PAGE::"Vendor List", Vendor) <> ACTION::LookupOK then
            exit('');
        exit(Vendor."No.");
    end;

    local procedure GetHeaderField(DataExch: Record "Data Exch."; TableNumber: Integer; FieldNumber: Integer; MaxFieldLength: Integer): Text
    var
        DataExchangeFieldMapping: Record "Data Exch. Field Mapping";
        DataExchField: Record "Data Exch. Field";
    begin
        DataExchangeFieldMapping.Reset;
        DataExchangeFieldMapping.SetRange("Data Exch. Def Code", DataExch."Data Exch. Def Code");
        DataExchangeFieldMapping.SetRange("Target Table ID", TableNumber);
        DataExchangeFieldMapping.SetRange("Target Field ID", FieldNumber);
        if DataExchangeFieldMapping.FindFirst then begin
            DataExchField.SetRange("Data Exch. No.", DataExch."Entry No.");
            DataExchField.SetRange("Column No.", DataExchangeFieldMapping."Column No.");
            DataExchField.SetFilter(Value, '<>%1', '');
            if DataExchField.FindFirst then
                if MaxFieldLength <> 0 then
                    exit(CopyStr(DataExchField.Value, 1, MaxFieldLength))
                else
                    exit(DataExchField.Value)
            else
                exit('');
        end;
        exit('');
    end;

    local procedure GetFieldDelimiter(DataExchDef: Record "Data Exch. Def"): Char
    begin
        case DataExchDef."Column Separator" of
            DataExchDef."Column Separator"::Tab:
                exit(9);
            DataExchDef."Column Separator"::Space:
                exit(' ');
            DataExchDef."Column Separator"::Semicolon:
                exit(';');
            DataExchDef."Column Separator"::Comma:
                exit(',');
        end;
    end;

    local procedure GetSplitParameters(DataExchDef: Record "Data Exch. Def"; var SplitMethod: Option "0",GroupByColumn,SplitOnValueFirstField; var SplitOnColumn: Integer; var SplitOnValue: Text)
    var
        DataExchColumnDef: Record "Data Exch. Column Def";
    begin
        DataExchColumnDef.Reset;
        DataExchColumnDef.SetRange("Data Exch. Def Code", DataExchDef.Code);
        DataExchColumnDef.SetFilter("NPR Split File", '>0');
        if DataExchColumnDef.FindFirst then begin
            SplitMethod := DataExchColumnDef."NPR Split File";
            SplitOnColumn := DataExchColumnDef."Column No.";
            SplitOnValue := DataExchColumnDef."NPR Split Value";
        end else
            SplitMethod := 0;
    end;

    local procedure "---Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 1223, 'OnAfterValidateEvent', 'NPR Split File', false, false)]
    local procedure OnValidateSplitFileSetSplitValue(var Rec: Record "Data Exch. Column Def"; var xRec: Record "Data Exch. Column Def"; CurrFieldNo: Integer)
    var
        DataExchColumnDef: Record "Data Exch. Column Def";
        TextOnlyOne: Label 'Only one Column can be set up to split files on per Data Exchange Definition.';
    begin
        if Rec."NPR Split File" <> Rec."NPR Split File"::NewFileOnSplitValue then
            Rec."NPR Split Value" := '';
        if Rec."NPR Split File" > 0 then begin
            DataExchColumnDef.Reset;
            DataExchColumnDef.SetRange("Data Exch. Def Code", Rec."Data Exch. Def Code");
            DataExchColumnDef.SetFilter("Column No.", '<>%1', Rec."Column No.");
            DataExchColumnDef.SetFilter("NPR Split File", '>0');
            if not DataExchColumnDef.IsEmpty then
                Error(TextOnlyOne);
        end;
    end;
}

