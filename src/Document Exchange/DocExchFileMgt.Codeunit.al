codeunit 6059932 "NPR Doc. Exch. File Mgt."
{
    // NPR5.26/TJ/20160812 CASE 248831 Added export framework to be based on Electronic Document Format setup table
    //                                 Added modify permission for table 112 Sales Invoice Header so we can update document status
    // NPR5.27/TJ/20160928 CASE 248831 Recoded most of the export functions to only use RecordRef and to be resistant to export codeunit if it changes posted document
    // NPR5.27/BR/20161014 CASE 252537 Show Error message if not export
    // NPR5.29/BR/20170117 CASE 263705 Added support for FTP Import
    // NPR5.33/BR/20170216 CASE 266527 Added functions for FTP and local file export
    // NPR5.33/BR/20170420 CASE 266527 Added functions and subscribers to support more export buttons
    // NPR5.54/THRO/20200212 CASE 389951 Close connection to ftp after last action
    // NPR5.55/THRO/20200618 CASE 410350 Removed DisconnectFTP. Always setting KeepAlive to False, Removed the Keepalive parameter in InitFTPWebRequest
    //                                   Added tryfunctions to get ftp filelist using NLST and LIST command. Retrive ftp-file in tryfunction

    Permissions = TableData "Sales Invoice Header" = m;

    trigger OnRun()
    var
        ServerFilePath: Text;
    begin
        ImportUsingSetup;
        //-NPR5.29 [263705]
        ImportFTPUsingSetup;
        //+NPR5.29 [263705]
    end;

    var
        InboxError: Label 'Inbox folder path needs to be set as an %1 parameter.';
        ArchiveError: Label 'Archive folder path needs to be set as an %1 parameter.';
        FolderError: Label 'Invalid %1 folder path.';
        FileMgt: Codeunit "File Management";
        FileImported: Label 'File %1 has been successfully imported.';
        FolderStructureDelimiter: Text;
        LoggingConstTxt: Label 'Document Exchange Framework';
        SendDocTxt: Label 'Send document.';
        DocSendSuccessMsg: Label 'The document was successfully created and exported to set export folder.', Comment = '%1 is the actual document no.';

    procedure ImportUsingSetup()
    var
        InboxPath: Text;
        InboxPathServer: Text;
        IsLocalInbox: Boolean;
        ArchivePath: Text;
        IsLocalArchive: Boolean;
        CreateDocument: Boolean;
        DocExchSetup: Record "NPR Doc. Exch. Setup";
        DocExchangePath: Record "NPR Doc. Exchange Path";
    begin
        DocExchSetup.Get;
        InboxPath := DocExchSetup."Import File Location";
        IsLocalInbox := DocExchSetup."Import Local";
        ArchivePath := DocExchSetup."Archive File Location";
        IsLocalArchive := DocExchSetup."Archive Local";
        CreateDocument := DocExchSetup."Create Document";

        if InboxPath <> '' then
            ImportDirectory(InboxPath, ArchivePath, IsLocalInbox, IsLocalArchive, CreateDocument);

        DocExchangePath.Reset;
        DocExchangePath.SetRange(Direction, DocExchangePath.Direction::Import);
        DocExchangePath.SetRange(Enabled, true);
        if DocExchangePath.FindSet then
            repeat
                if DocExchangePath."Archive Path" <> '' then
                    ArchivePath := DocExchangePath."Archive Path";
                InboxPath := DocExchangePath.Path;
                ImportDirectory(InboxPath, ArchivePath, IsLocalInbox, IsLocalArchive, CreateDocument);
            until DocExchangePath.Next = 0;
    end;

    procedure ImportDirectory(InboxPath: Text; ArchivePath: Text; IsLocalInbox: Boolean; IsLocalArchive: Boolean; CreateDocument: Boolean) Success: Boolean
    var
        DirectoryInfoServer: DotNet NPRNetDirectoryInfo;
        [RunOnClient]
        DirectoryInfoClient: DotNet NPRNetDirectoryInfo;
        FileInfo: DotNet NPRNetFileInfo;
        List: DotNet NPRNetList_Of_T;
        NetConvHelper: Variant;
    begin
        FolderStructureDelimiter := '\';
        if InboxPath = '' then
            ThrowError(StrSubstNo(InboxError, InboxPath));
        InboxPath := CheckFolderPath(InboxPath);
        if not SearchForFolder(IsLocalInbox, InboxPath) then
            ThrowError(StrSubstNo(FolderError, InboxPath));
        if ArchivePath = '' then
            ThrowError(StrSubstNo(ArchiveError, ArchivePath));
        ArchivePath := CheckFolderPath(ArchivePath);
        if not SearchForFolder(IsLocalArchive, ArchivePath) then
            ThrowError(StrSubstNo(FolderError, ArchivePath));

        if IsLocalInbox then begin
            //this is how one would normally upload entire directory if the function would actually work
            //  InboxPathServer := FileMgt.UploadClientDirectorySilent(InboxPath,'*.xml',FALSE)
            DirectoryInfoClient := DirectoryInfoClient.DirectoryInfo(InboxPath);
            NetConvHelper := DirectoryInfoClient.GetFiles();
            List := NetConvHelper;
        end else begin
            DirectoryInfoServer := DirectoryInfoServer.DirectoryInfo(InboxPath);
            NetConvHelper := DirectoryInfoServer.GetFiles();
            List := NetConvHelper;
        end;

        foreach FileInfo in List do begin
            ImportFile(FileInfo.Name, InboxPath, ArchivePath, IsLocalInbox, IsLocalArchive, CreateDocument);
        end;
    end;

    local procedure ImportFile(FileName: Text; InboxPath: Text; ArchivePath: Text; IsLocalInbox: Boolean; IsLocalArchive: Boolean; CreateDocument: Boolean)
    var
        ServerFilePath: Text;
    begin
        PrepareFile(ServerFilePath, IsLocalInbox, InboxPath + FileName);
        ProcessFile(ServerFilePath, CreateDocument);
        ArchiveFile(ServerFilePath, ArchivePath + FileName, IsLocalArchive);
        CleanupFile(ServerFilePath, IsLocalInbox, InboxPath + FileName);
        Commit;
    end;

    procedure ImportFTPUsingSetup()
    var
        FTPServer: Text;
        FTPUsername: Text;
        FTPPassword: Text;
        FTPFolder: Text;
        FTPArchiveFolder: Text;
        FTPUsePassive: Boolean;
        CreateDocument: Boolean;
        DocExchSetup: Record "NPR Doc. Exch. Setup";
        DocExchangePath: Record "NPR Doc. Exchange Path";
        FTPFileMask: Text;
    begin
        //-NPR5.29 [263705]
        DocExchSetup.Get;
        if not DocExchSetup."FTP Import Enabled" then
            exit;
        FTPServer := DocExchSetup."Import FTP Server";
        FTPUsername := DocExchSetup."Import FTP Username";
        FTPPassword := DocExchSetup."Import FTP Password";
        FTPFolder := DocExchSetup."Import FTP Folder";
        FTPArchiveFolder := DocExchSetup."Archive FTP Folder";
        FTPFileMask := DocExchSetup."Import FTP File Mask";
        FTPUsePassive := DocExchSetup."Import FTP Using Passive";
        CreateDocument := DocExchSetup."Create Document";

        if FTPServer <> '' then
            ImportFTPFolder(FTPServer, FTPUsername, FTPPassword, FTPFolder, FTPFileMask, FTPArchiveFolder, FTPUsePassive, CreateDocument);
        //+NPR5.29 [263705]
    end;

    procedure ImportFTPFolder(FTPserver: Text; FTPUsername: Text; FTPPassword: Text; FTPFolder: Text; FTPFileMask: Text; FTPArchiveFolder: Text; FTPUsePassive: Boolean; CreateDocument: Boolean) Success: Boolean
    var
        FtpWebRequest: DotNet NPRNetFtpWebRequest;
        FtpWebResponse: DotNet NPRNetFtpWebResponse;
        NetworkCredential: DotNet NPRNetNetworkCredential;
        Stream: DotNet NPRNetStream;
        StreamReader: DotNet NPRNetStreamReader;
        MemoryStream: DotNet NPRNetMemoryStream;
        FileName: Text;
        FileNameList: array[20] of Text;
        FileCounter: Integer;
        I: Integer;
    begin
        //-NPR5.29 [263705]
        //Get file list
        //-NPR5.55 [410350]
        //IF UPPERCASE(COPYSTR(FTPserver,1,4)) <> 'FTP://' THEN
        if UpperCase(CopyStr(FTPserver, 1, 6)) <> 'FTP://' then
            //+NPR5.55 [410350]
            FTPserver := 'FTP://' + FTPserver;
        if FTPFileMask = '' then
            FTPFileMask := '*.*';
        //-NPR5.55 [410350]
        //-NPR5.54 [389951]
        //InitFTPWebRequest(FtpWebRequest,'LIST',FTPserver,FTPUsername,FTPPassword,FTPFolder,FTPFileMask,FTPUsePassive,TRUE);
        //+NPR5.54 [389951]
        // FtpWebResponse := FtpWebRequest.GetResponse;
        // Stream := FtpWebResponse.GetResponseStream;
        // StreamReader := StreamReader.StreamReader(Stream);
        //
        // FileCounter := 0;
        // //Store list of files, Maximum of 20 per execution
        // WHILE (NOT (StreamReader.EndOfStream)) AND (FileCounter < 20) DO BEGIN
        //  FileName := StreamReader.ReadLine;
        //  IF STRLEN(FileName) > 56 THEN BEGIN
        //    FileName := COPYSTR(FileName,56);
        //    IF COPYSTR(FileName,1,1) <> '.' THEN BEGIN
        //      FileCounter := FileCounter + 1;
        //      FileNameList[FileCounter] := FileName;
        //    END;
        //  END;
        // END;
        // FtpWebResponse.Close;
        // StreamReader.Close;
        // Stream.Close;
        //
        // IF FileCounter = 0 THEN
        //  EXIT;
        //
        // SLEEP(2000); //Allow 2 secs between retrieving the file list so that anything writing to the FTP can finish writing file
        // I:=0;
        // REPEAT
        //  I := I + 1;
        //  ImportFTPFile(FTPserver,FTPUsername,FTPPassword,FTPFolder,FileNameList[I],FTPArchiveFolder,FTPUsePassive,CreateDocument);
        // UNTIL I >= FileCounter;
        // //-NPR5.29 [263705]
        // //-NPR5.54 [389951]
        // DisconnectFTP(FTPserver,FTPUsername,FTPPassword,FTPUsePassive);
        // //+NPR5.54 [389951]

        if not GetFtpFileList(FTPserver, FTPUsername, FTPPassword, FTPFolder, FTPFileMask, FTPUsePassive, FileNameList) then
            exit;
        CompressArray(FileNameList);
        FileCounter := 1;
        while FileNameList[FileCounter] <> '' do begin
            ImportFTPFile(FTPserver, FTPUsername, FTPPassword, FTPFolder, FileNameList[FileCounter], FTPArchiveFolder, FTPUsePassive, CreateDocument);
            FileCounter += 1;
        end;
        //+NPR5.55 [410350]
    end;

    local procedure ImportFTPFile(FTPserver: Text; FTPUsername: Text; FTPPassword: Text; FTPFolder: Text; FTPFilename: Text; FTPArchiveFolder: Text; FTPUsePassive: Boolean; CreateDocument: Boolean)
    var
        FtpWebRequest: DotNet NPRNetFtpWebRequest;
        FtpWebResponse: DotNet NPRNetFtpWebResponse;
        Stream: DotNet NPRNetStream;
        StreamReader: DotNet NPRNetStreamReader;
        MemoryStream: DotNet NPRNetMemoryStream;
        UTF8Encoding: DotNet NPRNetEncoding;
        FileLength: Integer;
        TempBlob: Codeunit "Temp Blob";
        OStream: OutStream;
        IStream: InStream;
        IncomingDocument: Record "Incoming Document";
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        ImportAttachIncDoc: Codeunit "Import Attachment - Inc. Doc.";
        FileText: Text;
        RecRef: RecordRef;
    begin
        //-NPR5.29 [263705]
        //Download file and store in Blob
        //-NPR5.55 [410350]
        //-NPR5.54 [389951]
        InitFTPWebRequest(FtpWebRequest, 'RETR', FTPserver, FTPUsername, FTPPassword, FTPFolder, FTPFilename, FTPUsePassive);
        //+NPR5.54 [389951]
        //FtpWebResponse := FtpWebRequest.GetResponse;
        if not GetFtpResponse(FtpWebRequest, FtpWebResponse) then
            exit;
        //+NPR5.55 [410350]
        Stream := FtpWebResponse.GetResponseStream;
        MemoryStream := MemoryStream.MemoryStream();
        TempBlob.CreateOutStream(OStream);
        Stream.CopyTo(OStream);
        Stream.Close;
        FtpWebResponse.Close;

        //Import file from Blob
        RecRef.GetTable(IncomingDocumentAttachment);
        TempBlob.ToRecordRef(RecRef, IncomingDocumentAttachment.FieldNo(Content));
        RecRef.SetTable(IncomingDocumentAttachment);

        if ImportAttachIncDoc.ImportAttachment(IncomingDocumentAttachment, FTPFilename) then begin
            if CreateDocument then begin
                IncomingDocument.Get(IncomingDocumentAttachment."Incoming Document Entry No.");
                IncomingDocument.CreateDocumentWithDataExchange();
            end;

            //If imported: Archive file
            if FTPArchiveFolder <> '' then begin
                //-NPR5.54 [389951]
                //-NPR5.55 [410350]
                InitFTPWebRequest(FtpWebRequest, 'STOR', FTPserver, FTPUsername, FTPPassword, FTPArchiveFolder, FTPFilename, FTPUsePassive);
                //+NPR5.55 [410350]
                //+NPR5.54 [389951]
                TempBlob.CreateInStream(IStream, TEXTENCODING::UTF8);
                IStream.Read(FileText);
                Clear(IStream);
                UTF8Encoding := UTF8Encoding.UTF8;
                FtpWebRequest.ContentLength := UTF8Encoding.GetBytes(FileText).Length;
                Stream := FtpWebRequest.GetRequestStream;
                Stream.Write(UTF8Encoding.GetBytes(FileText), 0, FtpWebRequest.ContentLength);
                Stream.Close;
                FtpWebResponse := FtpWebRequest.GetResponse;
                FtpWebResponse.Close;
                Clear(IStream);
            end;

            //If imported: Delete file
            //-NPR5.54 [389951]
            //-NPR5.55 [410350]
            InitFTPWebRequest(FtpWebRequest, 'DELE', FTPserver, FTPUsername, FTPPassword, FTPFolder, FTPFilename, FTPUsePassive);
            //+NPR5.55 [410350]
            //+NPR5.54 [389951]
            FtpWebResponse := FtpWebRequest.GetResponse;
            FtpWebResponse.Close;
        end;

        Commit;
        //+NPR5.29 [263705]
    end;

    local procedure InitFTPWebRequest(var FtpWebRequest: DotNet NPRNetFtpWebRequest; FTPMethod: Text; FTPServerName: Text; FTPUsername: Text; FTPPassword: Text; FTPFolder: Text; FTPFileNameOrMask: Text; FTPusePassive: Boolean)
    var
        NetworkCredential: DotNet NPRNetNetworkCredential;
    begin
        //-NPR5.29 [263705]
        FtpWebRequest := FtpWebRequest.Create(GetFTPPath(FTPServerName, FTPFolder, FTPFileNameOrMask));
        FtpWebRequest.Credentials := NetworkCredential.NetworkCredential(FTPUsername, FTPPassword);
        FtpWebRequest.Method := FTPMethod;
        //-NPR5.54 [389951]
        //FtpWebRequest.KeepAlive := TRUE;
        //-NPR5.55 [410350]
        FtpWebRequest.KeepAlive := false;
        //+NPR5.55 [410350]
        //+NPR5.54 [389951]
        FtpWebRequest.UseBinary := true;
        if FTPusePassive then
            FtpWebRequest.UsePassive := false;
        //+NPR5.29 [263705]
    end;

    local procedure GetFTPPath(FTPServerName: Text; FTPFolder: Text; FTPFileNameOrMask: Text): Text
    var
        FTPStructureDelimiter: Text;
    begin
        //-NPR5.29 [263705]
        FTPStructureDelimiter := '/';
        if FTPFolder <> '' then
            exit(FTPServerName + FTPStructureDelimiter + FTPFolder + FTPStructureDelimiter + FTPFileNameOrMask)
        else
            exit(FTPServerName + FTPStructureDelimiter + FTPFileNameOrMask);
        //+NPR5.29 [263705]
    end;

    local procedure GetFtpFileList(FTPServerName: Text; FTPUsername: Text; FTPPassword: Text; FTPFolder: Text; FTPFileNameOrMask: Text; FTPusePassive: Boolean; var FileNameList: array[20] of Text): Boolean
    begin
        //-NPR5.55 [410350]
        if FtpNLST(FTPServerName, FTPUsername, FTPPassword, FTPFolder, FTPFileNameOrMask, FTPusePassive, FileNameList) then
            exit(true);
        if FtpLIST(FTPServerName, FTPUsername, FTPPassword, FTPFolder, FTPFileNameOrMask, FTPusePassive, FileNameList) then
            exit(true);
        exit(false);
        //+NPR5.55 [410350]
    end;

    [TryFunction]
    local procedure FtpNLST(FTPServerName: Text; FTPUsername: Text; FTPPassword: Text; FTPFolder: Text; FTPFileNameOrMask: Text; FTPusePassive: Boolean; var FileNameList: array[20] of Text)
    var
        FtpWebRequest: DotNet NPRNetFtpWebRequest;
        FtpWebResponse: DotNet NPRNetFtpWebResponse;
        Stream: DotNet NPRNetStream;
        StreamReader: DotNet NPRNetStreamReader;
        FileCounter: Integer;
    begin
        //-NPR5.55 [410350]
        InitFTPWebRequest(FtpWebRequest, 'NLST', FTPServerName, FTPUsername, FTPPassword, FTPFolder, FTPFileNameOrMask, FTPusePassive);
        FtpWebResponse := FtpWebRequest.GetResponse;
        Stream := FtpWebResponse.GetResponseStream;
        StreamReader := StreamReader.StreamReader(Stream);

        FileCounter := 0;
        while (not (StreamReader.EndOfStream)) and (FileCounter < ArrayLen(FileNameList)) do begin
            FileCounter := FileCounter + 1;
            FileNameList[FileCounter] := StreamReader.ReadLine;
        end;
        FtpWebResponse.Close;
        StreamReader.Close;
        Stream.Close;
        //+NPR5.55 [410350]
    end;

    [TryFunction]
    local procedure FtpLIST(FTPServerName: Text; FTPUsername: Text; FTPPassword: Text; FTPFolder: Text; FTPFileNameOrMask: Text; FTPusePassive: Boolean; var FileNameList: array[20] of Text)
    var
        FtpWebRequest: DotNet NPRNetFtpWebRequest;
        FtpWebResponse: DotNet NPRNetFtpWebResponse;
        Stream: DotNet NPRNetStream;
        StreamReader: DotNet NPRNetStreamReader;
        FileCounter: Integer;
        FileName: Text;
    begin
        //-NPR5.55 [410350]
        InitFTPWebRequest(FtpWebRequest, 'LIST', FTPServerName, FTPUsername, FTPPassword, FTPFolder, FTPFileNameOrMask, FTPusePassive);
        FtpWebResponse := FtpWebRequest.GetResponse;
        Stream := FtpWebResponse.GetResponseStream;
        StreamReader := StreamReader.StreamReader(Stream);

        FileCounter := 0;
        while (not (StreamReader.EndOfStream)) and (FileCounter < ArrayLen(FileNameList)) do begin
            FileName := StreamReader.ReadLine;
            if (StrLen(FileName) > 56) and (LowerCase(CopyStr(FileName, 1, 1)) <> 'd') then begin
                FileName := CopyStr(FileName, 56);
                if CopyStr(FileName, 1, 1) <> '.' then begin
                    FileCounter := FileCounter + 1;
                    FileNameList[FileCounter] := FileName;
                end;
            end;
        end;
        FtpWebResponse.Close;
        StreamReader.Close;
        Stream.Close;
        //-NPR5.55 [410350]
    end;

    [TryFunction]
    local procedure GetFtpResponse(FtpWebRequest: DotNet NPRNetFtpWebRequest; FtpWebResponse: DotNet NPRNetFtpWebResponse)
    begin
        FtpWebResponse := FtpWebRequest.GetResponse;
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterPostSalesDoc', '', false, false)]
    local procedure ExportSalesDocumentOnAfterPost(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20])
    var
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        RecordRef: RecordRef;
    begin
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::Order:
                if SalesHeader.Invoice then begin
                    SalesInvHeader.Get(SalesInvHdrNo);

                    //-NPR5.27 [248831]
                    /*
                          PostedSalesDoc := SalesInvHeader;
                          SendSalesDocument(PostedSalesDoc,SalesInvHeader."Sell-to Customer No.",SalesInvHdrNo,0);
                    */
                    RecordRef.GetTable(SalesInvHeader);
                    SendSalesDocument(RecordRef, SalesInvHeader."Sell-to Customer No.", SalesInvHdrNo, 0);
                    //+NPR5.27 [248831]

                end;
            SalesHeader."Document Type"::"Credit Memo":
                begin
                    SalesCrMemoHeader.Get(SalesCrMemoHdrNo);

                    //-NPR5.27 [248831]
                    /*
                          PostedSalesDoc := SalesCrMemoHeader;
                          SendSalesDocument(PostedSalesDoc,SalesCrMemoHeader."Sell-to Customer No.",SalesCrMemoHdrNo,0);
                    */
                    RecordRef.GetTable(SalesCrMemoHeader);
                    SendSalesDocument(RecordRef, SalesCrMemoHeader."Sell-to Customer No.", SalesCrMemoHdrNo, 0);
                    //+NPR5.27 [248831]

                end;
            else
                exit;
        end;

    end;

    [EventSubscriber(ObjectType::Page, 132, 'OnAfterActionEvent', 'NPR Export', false, false)]
    local procedure ExportSalesInvoiceOnPage132Action(var Rec: Record "Sales Invoice Header")
    var
        RecordRef: RecordRef;
        Text001: Label 'One or more invoices that match your filter criteria have been created before.\\Do you want to continue?';
        Text002: Label 'This will export an invoice in an electronic document format specified. Do you want to continue?';
        Text003: Label 'The file was not created. Error message: %1 at %2.';
        ActivityLog: Record "Activity Log";
        Text004: Label 'The file was not created: Unknown error.';
    begin
        //-NPR5.33 [266527]
        ExportSalesInvoice(Rec);

        // IF NOT CONFIRM(Text002) THEN
        //  EXIT;
        // IF Rec."Doc. Exch. Exported" THEN
        //  IF NOT CONFIRM(Text001) THEN
        //    EXIT;
        //
        // //-NPR5.27 [248831]
        // {
        // PostedSalesDoc := Rec;
        // SendSalesDocument(PostedSalesDoc,Rec."Sell-to Customer No.",Rec."No.",0);
        // Rec := PostedSalesDoc;
        // }
        // RecordRef.GETTABLE(Rec);
        // SendSalesDocument(RecordRef,Rec."Sell-to Customer No.",Rec."No.",0);
        // RecordRef.SETTABLE(Rec);
        // //+NPR5.27 [248831]
        //
        // //-NPR5.27 [252537]
        // IF GUIALLOWED THEN BEGIN
        //  IF NOT Rec."Doc. Exch. File Exists" THEN BEGIN
        //    ActivityLog.SETRANGE("Record ID",RecordRef.RECORDID);
        //    IF ActivityLog.FINDLAST THEN
        //      MESSAGE(Text003,ActivityLog."Activity Message",ActivityLog."Activity Date")
        //    ELSE
        //      MESSAGE(Text004);
        //  END;
        // END;
        //+NPR5.33 [266527]
    end;

    [EventSubscriber(ObjectType::Page, 143, 'OnAfterActionEvent', 'NPR Export', false, false)]
    local procedure ExportSalesInvoiceOnPage143Action(var Rec: Record "Sales Invoice Header")
    var
        RecordRef: RecordRef;
        Text001: Label 'One or more invoices that match your filter criteria have been created before.\\Do you want to continue?';
        Text002: Label 'This will export an invoice in an electronic document format specified. Do you want to continue?';
        Text003: Label 'The file was not created. Error message: %1 at %2.';
        ActivityLog: Record "Activity Log";
        Text004: Label 'The file was not created: Unknown error.';
    begin
        //-NPR5.33 [266527]
        ExportSalesInvoice(Rec);

        // IF NOT CONFIRM(Text002) THEN
        //  EXIT;
        // IF Rec."Doc. Exch. Exported" THEN
        //  IF NOT CONFIRM(Text001) THEN
        //    EXIT;
        //
        // //-NPR5.27 [248831]
        // {
        // PostedSalesDoc := Rec;
        // SendSalesDocument(PostedSalesDoc,Rec."Sell-to Customer No.",Rec."No.",0);
        // Rec := PostedSalesDoc;
        // }
        // RecordRef.GETTABLE(Rec);
        // SendSalesDocument(RecordRef,Rec."Sell-to Customer No.",Rec."No.",0);
        // RecordRef.SETTABLE(Rec);
        // //+NPR5.27 [248831]
        //
        // //-NPR5.27 [252537]
        // IF GUIALLOWED THEN BEGIN
        //  IF NOT Rec."Doc. Exch. File Exists" THEN BEGIN
        //    ActivityLog.SETRANGE("Record ID",RecordRef.RECORDID);
        //    IF ActivityLog.FINDLAST THEN
        //      MESSAGE(Text003,ActivityLog."Activity Message",ActivityLog."Activity Date")
        //    ELSE
        //      MESSAGE(Text004);
        //  END;
        // END;
        //+NPR5.33 [266527]
    end;

    [EventSubscriber(ObjectType::Page, 132, 'OnAfterActionEvent', 'NPR UpdateStatus', false, false)]
    local procedure UpdateSalesInvoiceOnPage132Action(var Rec: Record "Sales Invoice Header")
    var
        DocExchPath: Record "NPR Doc. Exchange Path";
        RecordRef: RecordRef;
    begin
        //-NPR5.33 [266527]
        UpdateSalesInvoice(Rec);

        // IF NOT Rec."Doc. Exch. Exported" OR (Rec."Doc. Exch. Framework Status" = Rec."Doc. Exch. Framework Status"::"Delivered to Recepient") THEN
        //  EXIT;
        // RecordRef.GET(Rec."Doc. Exch. Setup Path Used");
        //
        // //-NPR5.27 [248831]
        // {
        // PostedSalesDoc := Rec;
        // UpdateSalesDoc(PostedSalesDoc,RecordRef,FALSE,1);
        // Rec := PostedSalesDoc;
        // }
        // RecordRef.SETTABLE(DocExchPath);
        // RecordRef.GETTABLE(Rec);
        // UpdateSalesDoc(RecordRef,DocExchPath,FALSE,1);
        // RecordRef.SETTABLE(Rec);;
        // //+NPR5.27 [248831]
        //+NPR5.33 [266527]
    end;

    [EventSubscriber(ObjectType::Page, 143, 'OnAfterActionEvent', 'NPR UpdateStatus', false, false)]
    local procedure UpdateSalesInvoiceOnPage143Action(var Rec: Record "Sales Invoice Header")
    var
        DocExchPath: Record "NPR Doc. Exchange Path";
        RecordRef: RecordRef;
    begin
        //-NPR5.33 [266527]
        UpdateSalesInvoice(Rec);

        // IF NOT Rec."Doc. Exch. Exported" OR (Rec."Doc. Exch. Framework Status" = Rec."Doc. Exch. Framework Status"::"Delivered to Recepient") THEN
        //  EXIT;
        // RecordRef.GET(Rec."Doc. Exch. Setup Path Used");
        //
        // //-NPR5.27 [248831]
        // {
        // PostedSalesDoc := Rec;
        // UpdateSalesDoc(PostedSalesDoc,RecordRef,FALSE,1);
        // Rec := PostedSalesDoc;
        // }
        // RecordRef.SETTABLE(DocExchPath);
        // RecordRef.GETTABLE(Rec);
        // UpdateSalesDoc(RecordRef,DocExchPath,FALSE,1);
        // RecordRef.SETTABLE(Rec);;
        // //+NPR5.27 [248831]
        //+NPR5.33 [266527]
    end;

    [EventSubscriber(ObjectType::Page, 134, 'OnAfterActionEvent', 'NPR Export', false, false)]
    local procedure ExportSalesCrMemoOnPage134Action(var Rec: Record "Sales Cr.Memo Header")
    var
        RecordRef: RecordRef;
        Text001: Label 'One or more invoices that match your filter criteria have been created before.\\Do you want to continue?';
        Text002: Label 'This will export an invoice in an electronic document format specified. Do you want to continue?';
        Text003: Label 'The file was not created. Error message: %1 at %2.';
        ActivityLog: Record "Activity Log";
        Text004: Label 'The file was not created: Unknown error.';
    begin
        //-NPR5.33 [266527]
        ExportSalesCrMemo(Rec);
        //+NPR5.33 [266527]
    end;

    [EventSubscriber(ObjectType::Page, 144, 'OnAfterActionEvent', 'NPR Export', false, false)]
    local procedure ExportSalesCrMemoOnPage144Action(var Rec: Record "Sales Cr.Memo Header")
    var
        RecordRef: RecordRef;
        Text001: Label 'One or more invoices that match your filter criteria have been created before.\\Do you want to continue?';
        Text002: Label 'This will export an invoice in an electronic document format specified. Do you want to continue?';
        Text003: Label 'The file was not created. Error message: %1 at %2.';
        ActivityLog: Record "Activity Log";
        Text004: Label 'The file was not created: Unknown error.';
    begin
        //-NPR5.33 [266527]
        ExportSalesCrMemo(Rec);
        //+NPR5.33 [266527]
    end;

    [EventSubscriber(ObjectType::Page, 134, 'OnAfterActionEvent', 'NPR UpdateStatus', false, false)]
    local procedure UpdateSalesCrMemoOnPage134Action(var Rec: Record "Sales Cr.Memo Header")
    var
        DocExchPath: Record "NPR Doc. Exchange Path";
        RecordRef: RecordRef;
    begin
        //-NPR5.33 [266527]
        UpdateSalesCrMemo(Rec);
        //+NPR5.33 [266527]
    end;

    [EventSubscriber(ObjectType::Page, 144, 'OnAfterActionEvent', 'NPR UpdateStatus', false, false)]
    local procedure UpdateSalesCrMemoOnPage144Action(var Rec: Record "Sales Cr.Memo Header")
    var
        DocExchPath: Record "NPR Doc. Exchange Path";
        RecordRef: RecordRef;
    begin
        //-NPR5.33 [266527]
        UpdateSalesCrMemo(Rec);
        //+NPR5.33 [266527]
    end;

    local procedure ExportSalesInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        RecordRef: RecordRef;
        Text001: Label 'One or more invoices that match your filter criteria have been created before.\\Do you want to continue?';
        Text002: Label 'This will export an invoice in an electronic document format specified. Do you want to continue?';
        Text003: Label 'The file was not created. Error message: %1 at %2.';
        ActivityLog: Record "Activity Log";
        Text004: Label 'The file was not created: Unknown error.';
    begin
        //-NPR5.33 [266527]
        if not Confirm(Text002) then
            exit;
        if SalesInvoiceHeader."NPR Doc. Exch. Exported" then
            if not Confirm(Text001) then
                exit;

        RecordRef.GetTable(SalesInvoiceHeader);
        SendSalesDocument(RecordRef, SalesInvoiceHeader."Sell-to Customer No.", SalesInvoiceHeader."No.", 0);
        RecordRef.SetTable(SalesInvoiceHeader);

        if GuiAllowed then begin
            if not SalesInvoiceHeader."NPR Doc. Exch. File Exists" then begin
                ActivityLog.SetRange("Record ID", RecordRef.RecordId);
                if ActivityLog.FindLast then
                    Message(Text003, ActivityLog."Activity Message", ActivityLog."Activity Date")
                else
                    Message(Text004);
            end;
        end;
        //+NPR5.33 [266527]
    end;

    procedure UpdateSalesInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        DocExchPath: Record "NPR Doc. Exchange Path";
        RecordRef: RecordRef;
    begin
        //-NPR5.33 [266527]
        if not SalesInvoiceHeader."NPR Doc. Exch. Exported" or (SalesInvoiceHeader."NPR Doc. Exch. Fr.work Status" = SalesInvoiceHeader."NPR Doc. Exch. Fr.work Status"::"Delivered to Recepient") then
            exit;
        RecordRef.Get(SalesInvoiceHeader."NPR Doc. Exch. Setup Path Used");

        RecordRef.SetTable(DocExchPath);
        RecordRef.GetTable(SalesInvoiceHeader);
        UpdateSalesDoc(RecordRef, DocExchPath, false, 1);
        RecordRef.SetTable(SalesInvoiceHeader);
        //+NPR5.33 [266527]
    end;

    local procedure ExportSalesCrMemo(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        RecordRef: RecordRef;
        Text001: Label 'One or more invoices that match your filter criteria have been created before.\\Do you want to continue?';
        Text002: Label 'This will export an invoice in an electronic document format specified. Do you want to continue?';
        Text003: Label 'The file was not created. Error message: %1 at %2.';
        ActivityLog: Record "Activity Log";
        Text004: Label 'The file was not created: Unknown error.';
    begin
        //-NPR5.33 [266527]
        if not Confirm(Text002) then
            exit;
        if SalesCrMemoHeader."NPR Doc. Exch. Exported" then
            if not Confirm(Text001) then
                exit;

        RecordRef.GetTable(SalesCrMemoHeader);
        SendSalesDocument(RecordRef, SalesCrMemoHeader."Sell-to Customer No.", SalesCrMemoHeader."No.", 0);
        RecordRef.SetTable(SalesCrMemoHeader);

        if GuiAllowed then begin
            if not SalesCrMemoHeader."NPR Doc. Exch. File Exists" then begin
                ActivityLog.SetRange("Record ID", RecordRef.RecordId);
                if ActivityLog.FindLast then
                    Message(Text003, ActivityLog."Activity Message", ActivityLog."Activity Date")
                else
                    Message(Text004);
            end;
        end;
        //+NPR5.33 [266527]
    end;

    procedure UpdateSalesCrMemo(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        DocExchPath: Record "NPR Doc. Exchange Path";
        RecordRef: RecordRef;
    begin
        //-NPR5.33 [266527]
        if not SalesCrMemoHeader."NPR Doc. Exch. Exported" or (SalesCrMemoHeader."NPR Doc.Exch. F.work Status" = SalesCrMemoHeader."NPR Doc.Exch. F.work Status"::"Delivered to Recepient") then
            exit;
        RecordRef.Get(SalesCrMemoHeader."NPR Doc.Exch.Setup Path Used");

        RecordRef.SetTable(DocExchPath);
        RecordRef.GetTable(SalesCrMemoHeader);
        UpdateSalesDoc(RecordRef, DocExchPath, false, 1);
        RecordRef.SetTable(SalesCrMemoHeader);
        //+NPR5.33 [266527]
    end;

    procedure SendSalesDocument(var RecordRef: RecordRef; CustomerNo: Code[20]; DocumentNo: Code[20]; CalledFrom: Integer)
    var
        DocExchPath: Record "NPR Doc. Exchange Path";
        SendSuccess: Boolean;
    begin
        //-NPR5.27 [248831]
        //Changed first parameter from Variant to RecordRef
        //RecordRef.GETTABLE(PostedSalesDoc);
        //+NPR5.27 [248831]

        if not GatherExportSetup(CustomerNo, DocExchPath) then
            exit;
        SendSuccess := ExportDocument(RecordRef, DocumentNo, DocExchPath);
        if SendSuccess then
            LogActivitySucceeded(RecordRef.RecordId, SendDocTxt, DocSendSuccessMsg)
        else
            LogActivityFailed(RecordRef.RecordId, SendDocTxt, '');

        //-NPR5.27 [248831]
        //UpdateSalesDoc(PostedSalesDoc,DocExchPath,SendSuccess,CalledFrom);
        UpdateSalesDoc(RecordRef, DocExchPath, SendSuccess, CalledFrom);
        //+NPR5.27 [248831]
    end;

    local procedure GatherExportSetup(CustomerNo: Code[20]; var DocExchPath: Record "NPR Doc. Exchange Path"): Boolean
    var
        DocExchSetup: Record "NPR Doc. Exch. Setup";
    begin
        Clear(DocExchPath);
        //-NPR5.33 [266527]
        //IF NOT DocExchSetup.GET() OR NOT DocExchSetup."File Export Enabled" THEN
        //  EXIT(FALSE);
        if not DocExchSetup.Get() then
            exit(false);
        if (not DocExchSetup."File Export Enabled") and (not DocExchSetup."FTP Export Enabled") then
            exit(false);
        //+NPR5.33 [266527]
        if not DocExchPath.Get(DocExchPath.Direction::Export, DocExchPath.Type::Customer, CustomerNo) then
            if not DocExchPath.Get(DocExchPath.Direction::Export, DocExchPath.Type::All, '') then
                exit(false);

        if not DocExchPath.Enabled and (DocExchPath."Electronic Format Code" = '') then
            exit(false);

        if (DocExchPath.Path = '') and (DocExchPath."Archive Path" = '') then
            //-NPR5.33 [266527]
            if (not DocExchPath."Use Export FTP Settings") then
                //+NPR5.33 [266527]
                exit(false);

        exit(true);
    end;

    [TryFunction]
    local procedure ExportDocument(var RecordRef: RecordRef; DocumentNo: Code[20]; var DocExchPath: Record "NPR Doc. Exchange Path")
    var
        ServerFilePath: Text;
        ClientFileName: Text;
        SpecificRecordRef: RecordRef;
    begin
        //-NPR5.27 [248831]
        //Parameter RecordRef is now called by reference
        //+NPR5.27 [248831]
        if DocExchPath.Path <> '' then
            DocExchPath.Path := StrSubstNo('%1\%2.xml', DelChr(DocExchPath.Path, '>', '\'), DocumentNo);
        if DocExchPath."Archive Path" <> '' then
            DocExchPath."Archive Path" := StrSubstNo('%1\%2.xml', DelChr(DocExchPath."Archive Path", '>', '\'), DocumentNo);

        //-NPR5.27 [248831]
        /*
        SpecificRecordRef.GET(RecordRef.RECORDID);
        SpecificRecordRef.SETRECFILTER;
        
        ProcessDocumentElectronically(ServerFilePath,ClientFileName,SpecificRecordRef,DocExchPath);
        */
        ProcessDocumentElectronically(ServerFilePath, ClientFileName, RecordRef, DocExchPath);
        //+NPR5.27 [248831]

        if ServerFilePath <> '' then begin
            FolderStructureDelimiter := '\';
            //-NPR5.33 [266527]
            //IF DocExchPath.Path <> '' THEN
            //  ExportFile(ServerFilePath,DocExchPath.Path);
            //IF DocExchPath."Archive Path" <> '' THEN
            //  ExportFile(ServerFilePath,DocExchPath."Archive Path");
            if DocExchPath."Use Export FTP Settings" then begin
                ExportFTPUsingSetup(ServerFilePath, DocumentNo);
            end;
            if DocExchPath.Path <> '' then
                ExportFile(ServerFilePath, DocExchPath.Path, DocExchPath."Export Locally");
            if DocExchPath."Archive Path" <> '' then
                ExportFile(ServerFilePath, DocExchPath."Archive Path", DocExchPath."Export Locally");
            //+NPR5.33 [266527]
        end;

    end;

    [IntegrationEvent(false, false)]
    local procedure ProcessDocumentElectronically(var ServerFilePath: Text; var ClientFileName: Text; var RecordRef: RecordRef; DocExchPath: Record "NPR Doc. Exchange Path")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6059932, 'ProcessDocumentElectronically', '', false, false)]
    local procedure SendW1DocFormats(var ServerFilePath: Text; var ClientFileName: Text; var RecordRef: RecordRef; DocExchPath: Record "NPR Doc. Exchange Path")
    var
        ElectronicDocumentFormat: Record "Electronic Document Format";
        SpecificRecordRef: RecordRef;
    begin
        //-NPR5.27 [248831]
        //IF NOT DocExchPath."Localization Format Code" THEN
        if not DocExchPath."Localization Format Code" then begin
            SpecificRecordRef.Get(RecordRef.RecordId);
            SpecificRecordRef.SetRecFilter;
            //+NPR5.27 [248831]

            ElectronicDocumentFormat.SendElectronically(
              ServerFilePath, ClientFileName, SpecificRecordRef, DocExchPath."Electronic Format Code");

            //-NPR5.27 [248831]
        end;
        //+NPR5.27 [248831]
    end;

    local procedure ExportFile(SourceFile: Text; var DestinationFile: Text; LocalExport: Boolean)
    var
        FileMgt: Codeunit "File Management";
        DirectoryDoesntExist: Label 'Path %1 doesn''t exist on server or client.';
        DirectoryPath: Text;
        ExportLocally: Integer;
    begin
        //-NPR5.27 [248831]
        //Parameter DestinationFile is now called by reference
        //+NPR5.27 [248831]
        //-NPR5.33 [266527]
        DirectoryPath := FileMgt.GetDirectoryName(DestinationFile);
        // CASE TRUE OF
        //  FileMgt.ServerDirectoryExists(DirectoryPath):
        //    BEGIN
        //      IF FileMgt.ServerFileExists(DestinationFile) THEN
        //        DestinationFile := AddSuffixToFileName(DestinationFile);
        //      FileMgt.CopyServerFile(SourceFile,DestinationFile,FALSE);
        //    END;
        //  FileMgt.ClientDirectoryExists(DirectoryPath):
        //    BEGIN
        //      IF FileMgt.ClientFileExists(DestinationFile) THEN
        //        DestinationFile := AddSuffixToFileName(DestinationFile);
        //      FileMgt.DownloadToFile(SourceFile,DestinationFile);
        //    END;
        //  ELSE
        //    ERROR(DirectoryDoesntExist,DirectoryPath);
        // END;

        if LocalExport then begin
            if FileMgt.ServerDirectoryExists(DirectoryPath) then begin
                if FileMgt.ServerFileExists(DestinationFile) then
                    DestinationFile := AddSuffixToFileName(DestinationFile);
                FileMgt.CopyServerFile(SourceFile, DestinationFile, false);
                exit;
            end;
        end else begin
            if FileMgt.ClientDirectoryExists(DirectoryPath) then begin
                if FileMgt.ClientFileExists(DestinationFile) then
                    DestinationFile := AddSuffixToFileName(DestinationFile);
                FileMgt.DownloadToFile(SourceFile, DestinationFile);
                exit;
            end;
        end;
        Error(DirectoryDoesntExist, DirectoryPath);
        //+NPR5.33 [266527]
    end;

    procedure UpdateSalesDoc(var RecordRef: RecordRef; DocExchPath: Record "NPR Doc. Exchange Path"; SendSuccess: Boolean; UpdateFrom: Option SendDoc,DocList)
    var
        FieldRef: FieldRef;
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        FileMgt: Codeunit "File Management";
    begin
        //-NPR5.27 [248831]

        //Changed first parameter to RecordRef from Variant and second from Variant to Doc. Exch. Path
        /*
        DocExchPath := DocExchPathVar;
        RecordRef.GETTABLE(PostedSalesDoc);
        */
        //+NPR5.27 [248831]
        case RecordRef.Number of
            DATABASE::"Sales Invoice Header":
                begin

                    //-NPR5.27 [248831]
                    //      SalesInvHeader := PostedSalesDoc;
                    RecordRef.SetTable(SalesInvHeader);
                    //+NPR5.27 [248831]

                    case UpdateFrom of
                        UpdateFrom::SendDoc:
                            begin
                                SalesInvHeader."NPR Doc. Exch. Exported" := SendSuccess;
                                SalesInvHeader."NPR Doc. Exch. Setup Path Used" := DocExchPath.RecordId;
                                SalesInvHeader."NPR Doc. Exch. Export. to" := DocExchPath.Path;
                                SalesInvHeader."NPR Doc. Exch. File Exists" := SendSuccess;
                                if SendSuccess then
                                    SalesInvHeader."NPR Doc. Exch. Fr.work Status" := SalesInvHeader."NPR Doc. Exch. Fr.work Status"::"Exported to Folder"
                                else
                                    SalesInvHeader."NPR Doc. Exch. Fr.work Status" := SalesInvHeader."NPR Doc. Exch. Fr.work Status"::"File Validation Error";
                            end;
                        UpdateFrom::DocList:
                            begin
                                SalesInvHeader."NPR Doc. Exch. File Exists" := Exists(SalesInvHeader."NPR Doc. Exch. Export. to");
                                if not SalesInvHeader."NPR Doc. Exch. File Exists" then //file has been picked up by the receipient
                                    SalesInvHeader."NPR Doc. Exch. Fr.work Status" := SalesInvHeader."NPR Doc. Exch. Fr.work Status"::"Delivered to Recepient"
                                else
                                    if DelChr(DocExchPath.Path, '>', '\') <> DelChr(FileMgt.GetDirectoryName(SalesInvHeader."NPR Doc. Exch. Export. to"), '>', '\') then
                                        SalesInvHeader."NPR Doc. Exch. Fr.work Status" := SalesInvHeader."NPR Doc. Exch. Fr.work Status"::"Setup Changed";
                            end;
                    end;
                    SalesInvHeader.Modify;

                    //-NPR5.27 [248831]
                    //      PostedSalesDoc := SalesInvHeader;
                    RecordRef.GetTable(SalesInvHeader);
                    //+NPR5.27 [248831]

                end;

            //-NPR5.33 [266527]
            DATABASE::"Sales Cr.Memo Header":
                begin
                    RecordRef.SetTable(SalesCrMemoHeader);
                    case UpdateFrom of
                        UpdateFrom::SendDoc:
                            begin
                                SalesCrMemoHeader."NPR Doc. Exch. Exported" := SendSuccess;
                                SalesCrMemoHeader."NPR Doc.Exch.Setup Path Used" := DocExchPath.RecordId;
                                SalesCrMemoHeader."NPR Doc. Exch. Exported to" := DocExchPath.Path;
                                SalesCrMemoHeader."NPR Doc. Exch. File Exists" := SendSuccess;
                                if SendSuccess then
                                    SalesInvHeader."NPR Doc. Exch. Fr.work Status" := SalesCrMemoHeader."NPR Doc.Exch. F.work Status"::"Exported to Folder"
                                else
                                    SalesInvHeader."NPR Doc. Exch. Fr.work Status" := SalesCrMemoHeader."NPR Doc.Exch. F.work Status"::"File Validation Error";
                            end;
                        UpdateFrom::DocList:
                            begin
                                SalesCrMemoHeader."NPR Doc. Exch. File Exists" := Exists(SalesCrMemoHeader."NPR Doc. Exch. Exported to");
                                if not SalesCrMemoHeader."NPR Doc. Exch. File Exists" then //file has been picked up by the receipient
                                    SalesCrMemoHeader."NPR Doc.Exch. F.work Status" := SalesCrMemoHeader."NPR Doc.Exch. F.work Status"::"Delivered to Recepient"
                                else
                                    if DelChr(DocExchPath.Path, '>', '\') <> DelChr(FileMgt.GetDirectoryName(SalesCrMemoHeader."NPR Doc. Exch. Exported to"), '>', '\') then
                                        SalesCrMemoHeader."NPR Doc.Exch. F.work Status" := SalesCrMemoHeader."NPR Doc.Exch. F.work Status"::"Setup Changed";
                            end;
                    end;
                    SalesCrMemoHeader.Modify;
                    RecordRef.GetTable(SalesCrMemoHeader);
                end;
        //+NPR5.33 [266527]

        end;

    end;

    local procedure CheckFolderPath(FolderPath: Text): Text[250]
    begin
        if FolderPath <> '' then
            if CopyStr(FolderPath, StrLen(FolderPath), 1) <> FolderStructureDelimiter then
                FolderPath := FolderPath + FolderStructureDelimiter;
        exit(FolderPath);
    end;

    local procedure SearchForFolder(var IsLocal: Boolean; FolderPath: Text) FolderExists: Boolean
    begin
        if IsLocal then
            FolderExists := FileMgt.ClientDirectoryExists(FolderPath)
        else begin
            //if its not local it can be that parameter is indeed set to point to server folder or parameter is not set so we need to check local side as well
            FolderExists := FileMgt.ServerDirectoryExists(FolderPath);
            if not FolderExists then begin
                FolderExists := FileMgt.ClientDirectoryExists(FolderPath);
                IsLocal := FolderExists;
            end;
        end;
        exit(FolderExists);
    end;

    local procedure ProcessFile(FilePath: Text; CreateDocument: Boolean)
    var
        TempBlob: Codeunit "Temp Blob";
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        ImportAttachIncDoc: Codeunit "Import Attachment - Inc. Doc.";
        IncomingDocument: Record "Incoming Document";
        RecRef: RecordRef;
    begin
        FileMgt.BLOBImportFromServerFile(TempBlob, FilePath);

        RecRef.GetTable(IncomingDocumentAttachment);
        TempBlob.ToRecordRef(RecRef, IncomingDocumentAttachment.FieldNo(Content));
        RecRef.SetTable(IncomingDocumentAttachment);

        if ImportAttachIncDoc.ImportAttachment(IncomingDocumentAttachment, FilePath) then begin
            if CreateDocument then begin
                IncomingDocument.Get(IncomingDocumentAttachment."Incoming Document Entry No.");
                IncomingDocument.CreateDocumentWithDataExchange();
            end;
        end;
    end;

    local procedure ThrowError(ErrorMsg: Text)
    begin
        Error(ErrorMsg);
    end;

    local procedure PrepareFile(var ServerFilePath: Text; IsLocal: Boolean; FilePath: Text)
    var
        TempServerPath: Text;
    begin
        if IsLocal then begin
            TempServerPath := FileMgt.UploadFileSilent(FilePath);
            ServerFilePath := FileMgt.GetDirectoryName(TempServerPath) + FolderStructureDelimiter + FileMgt.GetFileName(FilePath);
            FileMgt.CopyServerFile(TempServerPath, ServerFilePath, true);
            FileMgt.DeleteServerFile(TempServerPath);
        end else
            ServerFilePath := FilePath;
    end;

    local procedure ArchiveFile(SourcePath: Text; DestinationPath: Text; IsLocal: Boolean)
    begin
        if IsLocal then begin
            if FileMgt.ClientFileExists(DestinationPath) then
                DestinationPath := AddSuffixToFileName(DestinationPath);
            FileMgt.DownloadToFile(SourcePath, DestinationPath)
        end else begin
            if FileMgt.ServerFileExists(DestinationPath) then
                DestinationPath := AddSuffixToFileName(DestinationPath);
            FileMgt.CopyServerFile(SourcePath, DestinationPath, false);
        end;
    end;

    local procedure AddSuffixToFileName(FilePath: Text): Text
    var
        Suffix: Text;
    begin
        //using datetime in a custom format that suits file naming
        Suffix := Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2>-<Hours24,2><Minutes,2><Seconds,2>');
        exit(FileMgt.GetDirectoryName(FilePath) +
             FolderStructureDelimiter + FileMgt.GetFileNameWithoutExtension(FilePath) + ' ' +
             Suffix + '.' + FileMgt.GetExtension(FilePath));
    end;

    local procedure CleanupFile(ServerFilePath: Text; IsLocal: Boolean; ClientFilePath: Text)
    begin
        FileMgt.DeleteServerFile(ServerFilePath);
        if IsLocal then
            FileMgt.DeleteClientFile(ClientFilePath);
    end;

    procedure ShowWithStylesheet(var XmlDoc: DotNet "NPRNetXmlDocument")
    var
        MemoryStream: DotNet NPRNetMemoryStream;
        MemoryStream2: DotNet NPRNetMemoryStream;
        XmlStyleSheet: DotNet "NPRNetXmlDocument";
        XslCompiledTransform: DotNet NPRNetXslCompiledTransform;
        XmlReader: DotNet NPRNetXmlReader;
        XmlWriter: DotNet NPRNetXmlWriter;
    begin
        if IsNull(XmlStyleSheet) then begin
            XmlStyleSheet := XmlStyleSheet.XmlDocument;
            XmlStyleSheet.LoadXml('<?xml version="1.0" encoding="UTF-8"?>' +
                                  '<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">' +
                                    '<xsl:output method="xml" encoding="UTF-8" />' +
                                    '<xsl:template match="/">' +
                                      '<xsl:copy>' +
                                        '<xsl:apply-templates />' +
                                      '</xsl:copy>' +
                                    '</xsl:template>' +
                                    '<xsl:template match="*">' +
                                      '<xsl:element name="{local-name()}">' +
                                         '<xsl:apply-templates select="@* | node()" />' +
                                      '</xsl:element>' +
                                    '</xsl:template>' +
                                    '<xsl:template match="@*">' +
                                      '<xsl:attribute name="{local-name()}"><xsl:value-of select="."/></xsl:attribute>' +
                                    '</xsl:template>' +
                                    '<xsl:template match="text() | processing-instruction() | comment()">' +
                                      '<xsl:copy />' +
                                    '</xsl:template>' +
                                  '</xsl:stylesheet>');
            XslCompiledTransform := XslCompiledTransform.XslCompiledTransform;
            XslCompiledTransform.Load(XmlStyleSheet);
        end;
        MemoryStream := MemoryStream.MemoryStream;
        XmlDoc.Save(MemoryStream);
        MemoryStream.Position := 0;
        XmlReader := XmlReader.Create(MemoryStream);

        MemoryStream2 := MemoryStream2.MemoryStream;
        XmlWriter := XmlWriter.Create(MemoryStream2);
        XslCompiledTransform.Transform(XmlReader, XmlWriter);
        MemoryStream2.Position := 0;

        Clear(XmlDoc);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.Load(MemoryStream2);
    end;

    local procedure LogActivitySucceeded(RelatedRecordID: RecordID; ActivityDescription: Text; ActivityMessage: Text)
    var
        ActivityLog: Record "Activity Log";
    begin
        ActivityLog.LogActivity(RelatedRecordID, ActivityLog.Status::Success, LoggingConstTxt,
          CopyStr(ActivityDescription, 1, 250), CopyStr(ActivityMessage, 1, 250));
    end;

    local procedure LogActivityFailed(RelatedRecordID: RecordID; ActivityDescription: Text; ActivityMessage: Text)
    var
        ActivityLog: Record "Activity Log";
    begin
        ActivityMessage := GetLastErrorText + ' ' + ActivityMessage;
        ClearLastError;

        ActivityLog.LogActivity(RelatedRecordID, ActivityLog.Status::Failed, LoggingConstTxt,
          CopyStr(ActivityDescription, 1, 250), CopyStr(ActivityMessage, 1, 250));

        //COMMIT;

        //IF DELCHR(ActivityMessage,'<>',' ') <> '' THEN
        //  ERROR(ActivityMessage);
    end;

    procedure ExportFTPUsingSetup(ServerFilePath: Text; DocumentNo: Text)
    var
        FTPServer: Text;
        FTPUsername: Text;
        FTPPassword: Text;
        FTPFolder: Text;
        FTPArchiveFolder: Text;
        FTPUsePassive: Boolean;
        DocExchSetup: Record "NPR Doc. Exch. Setup";
        DocExchangePath: Record "NPR Doc. Exchange Path";
        FTPFileName: Text;
    begin
        //-NPR5.33 [266527]
        DocExchSetup.Get;
        if not DocExchSetup."FTP Export Enabled" then
            exit;
        FTPServer := DocExchSetup."Export FTP Server";
        FTPUsername := DocExchSetup."Export FTP Username";
        FTPPassword := DocExchSetup."Export FTP Password";
        FTPFolder := DocExchSetup."Export FTP Folder";
        //FTPFileName := FileMgt.GetFileName(ServerFilePath);
        FTPFileName := DocumentNo + '.xml';
        FTPUsePassive := DocExchSetup."Export FTP Using Passive";

        if FTPServer = '' then
            exit;
        //-NPR5.55 [410350]
        //IF UPPERCASE(COPYSTR(FTPServer,1,4)) <> 'FTP://' THEN
        if UpperCase(CopyStr(FTPServer, 1, 6)) <> 'FTP://' then
            //+NPR5.55 [410350]
            FTPServer := 'FTP://' + FTPServer;
        Sleep(1000);
        ExportFTPFile(FTPServer, FTPUsername, FTPPassword, FTPFolder, FTPFileName, FTPUsePassive, ServerFilePath);
        //+NPR5.33 [266527]
    end;

    local procedure ExportFTPFile(FTPserver: Text; FTPUsername: Text; FTPPassword: Text; FTPFolder: Text; FTPFilename: Text; FTPUsePassive: Boolean; ServerFilePath: Text)
    var
        FtpWebRequest: DotNet NPRNetFtpWebRequest;
        FtpWebResponse: DotNet NPRNetFtpWebResponse;
        Stream: DotNet NPRNetStream;
        StreamReader: DotNet NPRNetStreamReader;
        MemoryStream: DotNet NPRNetMemoryStream;
        UTF8Encoding: DotNet NPRNetEncoding;
        FileLength: Integer;
        TempBlob: Codeunit "Temp Blob";
        OStream: OutStream;
        IStream: InStream;
        IncomingDocument: Record "Incoming Document";
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        ImportAttachIncDoc: Codeunit "Import Attachment - Inc. Doc.";
        FileText: Text;
    begin
        //-NPR5.33 [266527]

        //Upload file
        //-NPR5.54 [389951]
        //-NPR5.55 [410350]
        InitFTPWebRequest(FtpWebRequest, 'STOR', FTPserver, FTPUsername, FTPPassword, FTPFolder, FTPFilename, FTPUsePassive);
        //+NPR5.55 [410350]
        //+NPR5.54 [389951]
        FileMgt.BLOBImportFromServerFile(TempBlob, ServerFilePath);
        TempBlob.CreateInStream(IStream, TEXTENCODING::UTF8);
        IStream.Read(FileText);
        Clear(IStream);
        UTF8Encoding := UTF8Encoding.UTF8;
        FtpWebRequest.ContentLength := UTF8Encoding.GetBytes(FileText).Length;
        Stream := FtpWebRequest.GetRequestStream;
        Stream.Write(UTF8Encoding.GetBytes(FileText), 0, FtpWebRequest.ContentLength);
        Stream.Close;
        FtpWebResponse := FtpWebRequest.GetResponse;
        FtpWebResponse.Close;
        Clear(IStream);
        //+NPR5.33 [266527]
    end;
}

