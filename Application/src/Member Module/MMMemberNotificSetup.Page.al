page 6060142 "NPR MM Member Notific. Setup"
{

    Caption = 'Member Notification Setup';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR MM Member Notific. Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Days Before"; Rec."Days Before")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Days Before field';
                }
                field("Days Past"; Rec."Days Past")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Days Past field';
                }
                field("Cancel Overdue Notif. (Days)"; Rec."Cancel Overdue Notif. (Days)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cancel Overdue Notif. (Days) field';
                }
                field("Processing Method"; Rec."Processing Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Method field';
                }
                field("Template Filter Value"; Rec."Template Filter Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Template Filter Value field';
                }
                field("Community Code"; Rec."Community Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Community Code field';
                }
                field("Membership Code"; Rec."Membership Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Code field';
                }
                field("Next Notification Code"; Rec."Next Notification Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Next Notification Code field';
                }
                field("Target Member Role"; Rec."Target Member Role")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Target Member Role field';
                }
                field("Include NP Pass"; Rec."Include NP Pass")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Include NP Pass field';
                }
                field("NP Pass Server Base URL"; Rec."NP Pass Server Base URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the NP Pass Server Base URL field';
                }
                field("Pass Notification Method"; Rec."Pass Notification Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Pass Notification Method field';
                }
                field("Passes API"; Rec."Passes API")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Passes API field';
                }
                field("""PUT Passes Template"".HASVALUE()"; Rec."PUT Passes Template".HasValue())
                {
                    ApplicationArea = All;
                    Caption = 'Have Template';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Have Template field';
                }
                field("Pass Token"; Rec."Pass Token")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Pass Token field';
                }
                field("Pass Type Code"; Rec."Pass Type Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Pass Type Code field';
                }
                field("Generate Magento PW URL"; Rec."Generate Magento PW URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Generate Magento PW URL field';
                }
                field("Fallback Magento PW URL"; Rec."Fallback Magento PW URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Fallback Magento PW URL field';
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
                PromotedOnly = true;
                PromotedIsBig = true;
                RunObject = Page "NPR E-mail Templates";
                RunPageView = WHERE("Table No." = CONST(6060139));
                ApplicationArea = All;
                ToolTip = 'Executes the E-Mail Templates action';
            }
            action(SMSTemplate)
            {
                Caption = 'SMS Template';
                Image = InteractionTemplate;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                RunObject = Page "NPR SMS Template List";
                RunPageView = WHERE("Table No." = CONST(6060139));
                ApplicationArea = All;
                ToolTip = 'Executes the SMS Template action';
            }

            action(RenewNotificationsList)
            {
                Caption = 'Renewal Notification List';
                Ellipsis = true;
                Image = Note;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = Page "NPR MM Membership Notific.";
                RunPageLink = "Notification Trigger" = CONST(RENEWAL);
                ApplicationArea = All;
                ToolTip = 'Executes the Renewal Notification List action';
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
                    Rec.CalcFields("PUT Passes Template");
                    if (not Rec."PUT Passes Template".HasValue()) then begin
                        PassData := MemberNotification.GetDefaultWalletTemplate();
                        Rec."PUT Passes Template".CreateOutStream(TemplateOutStream);
                        TemplateOutStream.Write(PassData);
                        Rec.Modify();
                        Rec.CalcFields("PUT Passes Template");
                    end;

                    TempBlob.FromRecord(Rec, Rec.FieldNo("PUT Passes Template"));
                    if (not TempBlob.HasValue()) then
                        exit;
                    Path := FileMgt.BLOBExport(TempBlob, TemporaryPath + StrSubstNo('%1 - %2.json', Rec.Code, Rec.Description), true);

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
                    FileName: Text;
                    RecRef: RecordRef;
                begin
                    FileName := FileMgt.BLOBImportWithFilter(TempBlob, IMPORT_FILE, '', 'Template Files (*.json)|*.json', 'json');

                    if (FileName = '') then
                        exit;

                    RecRef.GetTable(Rec);
                    TempBlob.ToRecordRef(RecRef, Rec.FieldNo("PUT Passes Template"));
                    RecRef.SetTable(Rec);

                    Rec.Modify(true);
                    Clear(TempBlob);

                end;
            }
            action(RefreshRenewNotification)
            {
                Caption = 'Refresh Renew Notification';
                Image = Recalculate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                ToolTip = 'Executes the Refresh Renew Notification action';

                trigger OnAction()
                var
                    MemberNotification: Codeunit "NPR MM Member Notification";
                    MembershipSetup: Record "NPR MM Membership Setup";
                begin

                    Rec.TestField(Type, Rec.Type::RENEWAL);
                    if (Rec."Membership Code" <> '') then begin
                        if (not Confirm(REFRESH_ALL_RENEW, true, Rec.FieldCaption("Membership Code"), Rec."Membership Code")) then
                            Error('');

                        MemberNotification.RefreshAllMembershipRenewalNotifications(Rec."Membership Code");

                    end else
                        if (Rec."Community Code" <> '') then begin
                            if (not Confirm(REFRESH_ALL_RENEW, true, Rec.FieldCaption("Community Code"), Rec."Community Code")) then
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
        REFRESH_ALL_RENEW: Label 'Refresh all renew notifications for %1 %2.';
        IMPORT_FILE: Label 'Import File';

}

