codeunit 6059941 "NaviDocs Handling Profile Tmpl"
{
    // NPR5.30/THRO/20170228 CASE 267474 Template codeunit for new NaviDocs Handling codeunit


    trigger OnRun()
    begin
    end;

    var
        NaviDocsHandlingProfileTxt: Label 'Add Description here';
        DataTypeManagement: Codeunit "Data Type Management";

    procedure DoHandleNaviDocs(RecordVariant: Variant): Boolean
    var
        HttpResponseMessage: DotNet npNetHttpResponseMessage;
        StringContent: DotNet npNetStringContent;
        Encoding: DotNet npNetEncoding;
        IComm: Record "I-Comm";
        ServiceCalc: Codeunit "NP Service Calculation";
        SMSHandled: Boolean;
        ForeignPhone: Boolean;
        ServiceCode: Code[20];
        Result: Text;
        ErrorHandled: Boolean;
    begin
        // Handle the record...
    end;

    procedure AddToNaviDocs(RecordVariant: Variant;Recepient: Text;ReportID: Integer;DelayUntil: DateTime)
    var
        NaviDocsManagement: Codeunit "NaviDocs Management";
        RecRef: RecordRef;
    begin
        if NaviDocsHandlingProfileCode <> '' then begin
          DataTypeManagement.GetRecordRef(RecordVariant,RecRef);
          NaviDocsManagement.AddDocumentEntryWithHandlingProfile(RecRef,NaviDocsHandlingProfileCode,ReportID,Recepient,DelayUntil);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6059767, 'OnAddHandlingProfilesToLibrary', '', true, true)]
    local procedure AddNaviDocsHandlingProfile()
    var
        NaviDocsManagement: Codeunit "NaviDocs Management";
    begin
        if NaviDocsHandlingProfileCode <> '' then
          NaviDocsManagement.AddHandlingProfileToLibrary(NaviDocsHandlingProfileCode,NaviDocsHandlingProfileTxt,false,false,false,false);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6059767, 'OnShowTemplate', '', false, false)]
    local procedure ShowTemplateFromNaviDocs(var RequestHandled: Boolean;NaviDocsEntry: Record "NaviDocs Entry")
    var
        RecRef: RecordRef;
    begin
        if RequestHandled or (NaviDocsEntry."Document Handling Profile" <> NaviDocsHandlingProfileCode) then
          exit;
        RequestHandled := true;

        if not RecRef.Get(NaviDocsEntry."Record ID") then
          exit;

        // Add code to Show the template here
        Message('Showing the Template');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6059767, 'OnManageDocument', '', false, false)]
    local procedure HandleNaviDocsDocument(var IsDocumentHandled: Boolean;ProfileCode: Code[20];var NaviDocsEntry: Record "NaviDocs Entry";ReportID: Integer;var WithSuccess: Boolean;var ErrorMessage: Text)
    var
        RecRef: RecordRef;
    begin
        if IsDocumentHandled or (ProfileCode <> NaviDocsHandlingProfileCode) then
          exit;

        if RecRef.Get(NaviDocsEntry."Record ID") then;

        if not DoHandleNaviDocs(RecRef) then
          ErrorMessage := 'Something went wrong';

        IsDocumentHandled := true;
        WithSuccess := ErrorMessage = '';
    end;

    local procedure NaviDocsHandlingProfileCode(): Text
    begin
        //Let function return the HandlingProfileCode
        exit('');
    end;
}

