codeunit 6059989 "NPR HL DLog Subscr. Mgt. Impl."
{
    Access = Internal;
    Permissions =
        tabledata "NPR Data Log Setup (Table)" = rimd,
        tabledata "NPR Data Log Subscriber" = rimd;

    var
        HLIntegrationEvents: Codeunit "NPR HL Integration Events";

    procedure CreateDataLogSetup(IntegrationArea: Enum "NPR HL Integration Area")
    var
        DataLogSetup: Record "NPR Data Log Setup (Table)";
    begin
        case IntegrationArea of
            IntegrationArea::Members:
                begin
                    AddDataLogSetupEntity(
                        IntegrationArea, Database::"NPR MM Member", DataLogSetup."Log Insertion"::Simple, DataLogSetup."Log Modification"::Changes, DataLogSetup."Log Deletion"::Detailed, DaysToDuration(7));
                    AddDataLogSetupEntity(
                        IntegrationArea, Database::"NPR MM Membership", DataLogSetup."Log Insertion"::Simple, DataLogSetup."Log Modification"::Changes, DataLogSetup."Log Deletion"::Detailed, DaysToDuration(7));
                    AddDataLogSetupEntity(
                        IntegrationArea, Database::"NPR MM Membership Role", DataLogSetup."Log Insertion"::Simple, DataLogSetup."Log Modification"::Changes, DataLogSetup."Log Deletion"::Detailed, DaysToDuration(7));
                    AddDataLogSetupEntity(
                        IntegrationArea, Database::"NPR GDPR Consent Log", DataLogSetup."Log Insertion"::Detailed, DataLogSetup."Log Modification"::" ", DataLogSetup."Log Deletion"::" ", DaysToDuration(7));
                    AddDataLogSetupEntity(
                        IntegrationArea, Database::"NPR HL Selected MCF Option", DataLogSetup."Log Insertion"::Simple, DataLogSetup."Log Modification"::Changes, DataLogSetup."Log Deletion"::Detailed, DaysToDuration(7));
                end;
        end;
        HLIntegrationEvents.OnAfterCreateDataLogSetup(IntegrationArea);
    end;

    procedure AddDataLogSetupEntity(IntegrationArea: Enum "NPR HL Integration Area"; TableId: Integer; LogInsertion: Integer; LogModification: Integer; LogDeletion: Integer; KeepLogFor: Duration)
    var
        DataLogSetup: Record "NPR Data Log Setup (Table)";
        xDataLogSetup: Record "NPR Data Log Setup (Table)";
        DataLogSubscriber: Record "NPR Data Log Subscriber";
        xDataLogSubscriber: Record "NPR Data Log Subscriber";
        HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
        LogModificationAlt: Integer;
        Handled: Boolean;
    begin
        if not HLIntegrationMgt.IsIntegratedTable(IntegrationArea, TableId) then
            exit;

        DataLogSetup.InsertNewTable(TableId, LogInsertion, LogModification, LogDeletion);
        xDataLogSetup := DataLogSetup;
        if DataLogSetup."Log Insertion" < LogInsertion then
            DataLogSetup."Log Insertion" := LogInsertion;
        if LogModification = DataLogSetup."Log Modification"::Changes then
            LogModificationAlt := DataLogSetup."Log Modification"::Detailed
        else
            LogModificationAlt := LogModification;
        if DataLogSetup."Log Modification" < LogModificationAlt then
            DataLogSetup."Log Modification" := LogModification;
        if DataLogSetup."Log Deletion" < LogDeletion then
            DataLogSetup."Log Deletion" := LogDeletion;
        if DataLogSetup."Keep Log for" < KeepLogFor then
            DataLogSetup."Keep Log for" := KeepLogFor;
        if Format(DataLogSetup) <> Format(xDataLogSetup) then
            DataLogSetup.Modify(true);

        DataLogSubscriber.AddAsSubscriber(HLIntegrationMgt.HeyLoyaltyCode(), DataLogSetup."Table ID");
        xDataLogSubscriber := DataLogSubscriber;
        HLIntegrationEvents.OnSetupDataLogSubsriberDataProcessingParams(IntegrationArea, DataLogSetup."Table ID", DataLogSubscriber, Handled);
        if not Handled then
            case IntegrationArea of
                IntegrationArea::Members:  //handled by Codeunit::"NPR HL Member Mgt."
                    begin
                        DataLogSubscriber."Direct Data Processing" := false;
                        DataLogSubscriber."Delayed Data Processing (sec)" := 5;
                    end;
            end;
        if Format(DataLogSubscriber) <> Format(xDataLogSubscriber) then
            DataLogSubscriber.Modify(true);
    end;

    procedure DaysToDuration(NoOfDays: Integer): Duration
    begin
        exit(NoOfDays * 86400000);
    end;

    procedure GetSubscriberCode(TableId: Integer; DataProcessingCodeunitId: Integer): Code[30]
    var
        DataLogSubscriber: Record "NPR Data Log Subscriber";
    begin
        DataLogSubscriber.SetFilter(Code, '<>%1', '');
        DataLogSubscriber.SetRange("Table ID", TableId);
        DataLogSubscriber.SetRange("Company Name", '');
        DataLogSubscriber.SetRange("Data Processing Codeunit ID", DataProcessingCodeunitId);
        if DataLogSubscriber.FindFirst() then
            exit(DataLogSubscriber.Code);

        exit(GetDefaultSubscriberCode());
    end;

    procedure GetDefaultSubscriberCode(): Code[30]
    var
        HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
    begin
        exit(HLIntegrationMgt.HeyLoyaltyCode());
    end;

    local procedure CheckSubscriberSetupIsConsistent(DataLogSubscriber: Record "NPR Data Log Subscriber")
    var
        HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
    begin
        if not (DataLogSubscriber."Data Processing Codeunit ID" in [Codeunit::"NPR HL Member Mgt. Impl."]) then
            exit;
        if not HLIntegrationMgt.IsInstantTaskEnqueue() then begin
            DataLogSubscriber.TestField("Direct Data Processing", false);
            DataLogSubscriber.TestField("Delayed Data Processing (sec)");
        end else
            if DataLogSubscriber."Direct Data Processing" or (DataLogSubscriber."Delayed Data Processing (sec)" <= 0) then
                if not HLIntegrationMgt.ConfirmInstantTaskEnqueue() then
                    Error('');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Data Log Subscriber", 'OnAfterValidateEvent', 'Direct Data Processing', true, false)]
    local procedure CheckSubscriber_DirectDataProcessing_OnValidate(var Rec: Record "NPR Data Log Subscriber"; var xRec: Record "NPR Data Log Subscriber")
    begin
        if (Rec."Direct Data Processing" <> xRec."Direct Data Processing") and Rec."Direct Data Processing" then
            CheckSubscriberSetupIsConsistent(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Data Log Subscriber", 'OnAfterValidateEvent', 'Delayed Data Processing (sec)', true, false)]
    local procedure CheckSubscriber_DelayedDataProcessing_OnValidate(var Rec: Record "NPR Data Log Subscriber"; var xRec: Record "NPR Data Log Subscriber")
    begin
        if (Rec."Delayed Data Processing (sec)" <> xRec."Delayed Data Processing (sec)") and (Rec."Delayed Data Processing (sec)" <= 0) then
            CheckSubscriberSetupIsConsistent(Rec);
    end;
}