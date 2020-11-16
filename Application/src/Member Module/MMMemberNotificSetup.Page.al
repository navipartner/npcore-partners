page 6060142 "NPR MM Member Notific. Setup"
{

    Caption = 'Member Notification Setup';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR MM Member Notific. Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Days Before"; "Days Before")
                {
                    ApplicationArea = All;
                }
                field("Days Past"; "Days Past")
                {
                    ApplicationArea = All;
                }
                field("Cancel Overdue Notif. (Days)"; "Cancel Overdue Notif. (Days)")
                {
                    ApplicationArea = All;
                }
                field("Processing Method"; "Processing Method")
                {
                    ApplicationArea = All;
                }
                field("Template Filter Value"; "Template Filter Value")
                {
                    ApplicationArea = All;
                }
                field("Community Code"; "Community Code")
                {
                    ApplicationArea = All;
                }
                field("Membership Code"; "Membership Code")
                {
                    ApplicationArea = All;
                }
                field("Next Notification Code"; "Next Notification Code")
                {
                    ApplicationArea = All;
                }
                field("Target Member Role"; "Target Member Role")
                {
                    ApplicationArea = All;
                }
                field("Include NP Pass"; "Include NP Pass")
                {
                    ApplicationArea = All;
                }
                field("NP Pass Server Base URL"; "NP Pass Server Base URL")
                {
                    ApplicationArea = All;
                }
                field("Pass Notification Method"; "Pass Notification Method")
                {
                    ApplicationArea = All;
                }
                field("Passes API"; "Passes API")
                {
                    ApplicationArea = All;
                }
                field("""PUT Passes Template"".HASVALUE()"; "PUT Passes Template".HasValue())
                {
                    ApplicationArea = All;
                    Caption = 'Have Template';
                    Editable = false;
                }
                field("Pass Token"; "Pass Token")
                {
                    ApplicationArea = All;
                }
                field("Pass Type Code"; "Pass Type Code")
                {
                    ApplicationArea = All;
                }
                field("Generate Magento PW URL"; "Generate Magento PW URL")
                {
                    ApplicationArea = All;
                }
                field("Fallback Magento PW URL"; "Fallback Magento PW URL")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {

        area(navigation)
        {
            action(EMailTemplates)
            {
                Caption = 'E-Mail Templates';
                Image = InteractionTemplate;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page "NPR E-mail Templates";
                RunPageView = WHERE("Table No." = CONST(6060139));
                ApplicationArea = All;
            }
            action(SMSTemplate)
            {
                Caption = 'SMS Template';
                Image = InteractionTemplate;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page "NPR SMS Template List";
                RunPageView = WHERE("Table No." = CONST(6060139));
                ApplicationArea = All;
            }

            action(RenewNotificationsList)
            {
                Caption = 'Renewal Notification List';
                Ellipsis = true;
                Image = Note;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "NPR MM Membership Notific.";
                RunPageLink = "Notification Trigger" = CONST(RENEWAL);
                ApplicationArea = All;
            }
        }
        area(processing)
        {

            action(ExportWalletTemplateFile)
            {
                Caption = 'Export Wallet Template File';
                ToolTip = 'Exports the default or current template used to send information to wallet.';
                Image = ExportAttachment;
                ApplicationArea = All;

                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    FileMgt: Codeunit "File Management";
                    MemberNotification: Codeunit "NPR MM Member Notification";
                    Path: Text;
                    PassData: Text;
                    TemplateOutStream: outstream;
                begin
                    CalcFields("PUT Passes Template");
                    if (not "PUT Passes Template".HasValue()) then begin
                        PassData := MemberNotification.GetDefaultWalletTemplate();
                        "PUT Passes Template".CreateOutStream(TemplateOutStream);
                        TemplateOutStream.Write(PassData);
                        Modify();
                        CalcFields("PUT Passes Template");
                    end;

                    TempBlob.FromRecord(Rec, FieldNo("PUT Passes Template"));
                    if (not TempBlob.HasValue()) then
                        exit;
                    Path := FileMgt.BLOBExport(TempBlob, TemporaryPath + StrSubstNo('%1 - %2.json', Code, Description), true);

                end;
            }

            action(ImportWalletTemplateFile)
            {
                Caption = 'Import Wallet Template File';
                ToolTip = 'Define information sent to wallet.';
                Image = ImportCodes;
                ApplicationArea = All;

                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    FileMgt: Codeunit "File Management";
                    Path: Text;
                    FileName: Text;
                    RecRef: RecordRef;
                begin
                    FileName := FileMgt.BLOBImportWithFilter(TempBlob, IMPORT_FILE, '', 'Template Files (*.json)|*.json', 'json');

                    if (FileName = '') then
                        exit;

                    RecRef.GetTable(Rec);
                    TempBlob.ToRecordRef(RecRef, Rec.FieldNo("PUT Passes Template"));
                    RecRef.SetTable(Rec);

                    Modify(true);
                    Clear(TempBlob);

                end;
            }
            action(RefreshRenewNotification)
            {
                Caption = 'Refresh Renew Notification';
                Image = Recalculate;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;

                trigger OnAction()
                var
                    MemberNotification: Codeunit "NPR MM Member Notification";
                    MembershipSetup: Record "NPR MM Membership Setup";
                begin

                    TestField(Type, Type::RENEWAL);
                    if ("Membership Code" <> '') then begin
                        if (not Confirm(REFRESH_ALL_RENEW, true, Rec.FieldCaption("Membership Code"), "Membership Code")) then
                            Error('');

                        MemberNotification.RefreshAllMembershipRenewalNotifications(Rec."Membership Code");

                    end else
                        if ("Community Code" <> '') then begin
                            if (not Confirm(REFRESH_ALL_RENEW, true, Rec.FieldCaption("Community Code"), "Community Code")) then
                                Error('');

                            MembershipSetup.SetFilter("Community Code", '=%1', Rec."Community Code");
                            MembershipSetup.FindSet();
                            repeat
                                MemberNotification.RefreshAllMembershipRenewalNotifications(MembershipSetup.Code);
                            until (MembershipSetup.Next() = 0);
                        end;

                end;
            }
        }
    }

    var
        FileManagement: Codeunit "File Management";
        REFRESH_ALL_RENEW: Label 'Refresh all renew notifications for %1 %2.';
        IMPORT_FILE: Label 'Import File';

}

