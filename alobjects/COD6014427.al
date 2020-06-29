codeunit 6014427 "System Event Wrapper"
{
    // TM1.39/THRO/2081108 CASE 334644 Wrapper codeunit for calls and subscription to codeunit 1
    // NPHC1.00/TJ /20181214 CASE 337793 Added this version so object is included in HQ connector objects
    // NPR5.50/ZESO/201905006 CASE 353382 Remove Function CaptionClassTranslate


    trigger OnRun()
    begin
    end;

    procedure MakeDateFilter(var DateFilterText: Text)
    var
        FilterTokens: Codeunit "Filter Tokens";
    begin
        FilterTokens.MakeDateFilter(DateFilterText);
    end;

    procedure ApplicationVersion() ApplicationVersion: Text[248]
    var
        ApplicationSystemConstants: Codeunit "Application System Constants";
    begin
        exit(ApplicationSystemConstants.ApplicationVersion());
    end;

    procedure ApplicationBuild(): Text[80]
    var
        ApplicationSystemConstants: Codeunit "Application System Constants";
    begin
        exit(ApplicationSystemConstants.ApplicationBuild());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCompanyOpen()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCompanyOpen()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCompanyClose()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCompanyClose()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCaptionClassTranslate(Language: Integer; CaptionExpression: Text[1024]; var Caption: Text[1024])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFindPrinter(ReportID: Integer; var PrinterName: Text[250])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetDatabaseTableTriggerSetup(TableId: Integer; var OnDatabaseInsert: Boolean; var OnDatabaseModify: Boolean; var OnDatabaseDelete: Boolean; var OnDatabaseRename: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterOnDatabaseInsert(RecRef: RecordRef)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterOnDatabaseModify(RecRef: RecordRef)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterOnDatabaseDelete(RecRef: RecordRef)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterOnDatabaseRename(RecRef: RecordRef; xRecRef: RecordRef)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetApplicationVersion(var AppVersion: Text[80])
    begin
    end;

    local procedure "--- Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 40, 'OnBeforeCompanyOpen', '', true, true)]
    local procedure C40OnBeforeCompanyOpen()
    begin
        OnBeforeCompanyOpen();
    end;

    [EventSubscriber(ObjectType::Codeunit, 40, 'OnAfterCompanyOpen', '', true, true)]
    local procedure C40OnAfterCompanyOpen()
    begin
        OnAfterCompanyOpen();
    end;

    [EventSubscriber(ObjectType::Codeunit, 40, 'OnBeforeCompanyClose', '', true, true)]
    local procedure C40OnBeforeCompanyClose()
    begin
        OnBeforeCompanyClose();
    end;

    [EventSubscriber(ObjectType::Codeunit, 40, 'OnAfterCompanyClose', '', true, true)]
    local procedure C40OnAfterCompanyClose()
    begin
        OnAfterCompanyClose();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Caption Class", 'OnAfterCaptionClassTranslate', '', true, true)]
    local procedure C42OnAfterCaptionClassTranslate(Language: Integer; CaptionExpression: Text[1024]; var Caption: Text[1024])
    begin
        OnAfterCaptionClassTranslate(Language, CaptionExpression, Caption);
    end;

    [EventSubscriber(ObjectType::Codeunit, 44, 'OnAfterGetPrinterName', '', true, true)]
    local procedure C44OnAfterFindPrinter(ReportID: Integer; var PrinterName: Text[250])
    begin
        OnAfterFindPrinter(ReportID, PrinterName);
    end;

    [EventSubscriber(ObjectType::Codeunit, 49, 'OnAfterGetDatabaseTableTriggerSetup', '', true, true)]
    local procedure C49OnAfterGetDatabaseTableTriggerSetup(TableId: Integer; var OnDatabaseInsert: Boolean; var OnDatabaseModify: Boolean; var OnDatabaseDelete: Boolean; var OnDatabaseRename: Boolean)
    begin
        OnAfterGetDatabaseTableTriggerSetup(TableId, OnDatabaseInsert, OnDatabaseModify, OnDatabaseDelete, OnDatabaseRename);
    end;

    [EventSubscriber(ObjectType::Codeunit, 49, 'OnAfterOnDatabaseInsert', '', true, true)]
    local procedure C49OnAfterOnDatabaseInsert(RecRef: RecordRef)
    begin
        OnAfterOnDatabaseInsert(RecRef);
    end;

    [EventSubscriber(ObjectType::Codeunit, 49, 'OnAfterOnDatabaseModify', '', true, true)]
    local procedure C49OnAfterOnDatabaseModify(RecRef: RecordRef)
    begin
        OnAfterOnDatabaseModify(RecRef);
    end;

    [EventSubscriber(ObjectType::Codeunit, 49, 'OnAfterOnDatabaseDelete', '', true, true)]
    local procedure C49OnAfterOnDatabaseDelete(RecRef: RecordRef)
    begin
        OnAfterOnDatabaseDelete(RecRef);
    end;

    [EventSubscriber(ObjectType::Codeunit, 49, 'OnAfterOnDatabaseRename', '', true, true)]
    local procedure C49OnAfterOnDatabaseRename(RecRef: RecordRef; xRecRef: RecordRef)
    begin
        OnAfterOnDatabaseRename(RecRef, xRecRef);
    end;

    [EventSubscriber(ObjectType::Codeunit, 9015, 'OnAfterGetApplicationVersion', '', true, true)]
    local procedure C9015OnAfterGetApplicationVersion(var ApplicationVersion: Text[248])
    begin
        OnAfterGetApplicationVersion(ApplicationVersion);
    end;
}

