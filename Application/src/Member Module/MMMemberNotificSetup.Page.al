page 6060142 "NPR MM Member Notific. Setup"
{
    Extensible = False;

    Caption = 'Member Notification Setup';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MM Member Notific. Setup";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Days Before"; Rec."Days Before")
                {

                    ToolTip = 'Specifies the value of the Days Before field';
                    ApplicationArea = NPRRetail;
                }
                field("Days Past"; Rec."Days Past")
                {

                    ToolTip = 'Specifies the value of the Days Past field';
                    ApplicationArea = NPRRetail;
                }
                field("Cancel Overdue Notif. (Days)"; Rec."Cancel Overdue Notif. (Days)")
                {

                    ToolTip = 'Specifies the value of the Cancel Overdue Notif. (Days) field';
                    ApplicationArea = NPRRetail;
                }
                field("Processing Method"; Rec."Processing Method")
                {

                    ToolTip = 'Specifies the value of the Processing Method field';
                    ApplicationArea = NPRRetail;
                }
                field("Template Filter Value"; Rec."Template Filter Value")
                {

                    ToolTip = 'Specifies the value of the Template Filter Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Community Code"; Rec."Community Code")
                {

                    ToolTip = 'Specifies the value of the Community Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Membership Code"; Rec."Membership Code")
                {

                    ToolTip = 'Specifies the value of the Membership Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Next Notification Code"; Rec."Next Notification Code")
                {

                    ToolTip = 'Specifies the value of the Next Notification Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Target Member Role"; Rec."Target Member Role")
                {

                    ToolTip = 'Specifies the value of the Target Member Role field';
                    ApplicationArea = NPRRetail;
                }
                field("Include NP Pass"; Rec."Include NP Pass")
                {

                    ToolTip = 'Specifies the value of the Include NP Pass field';
                    ApplicationArea = NPRRetail;
                }
                field("NP Pass Server Base URL"; Rec."NP Pass Server Base URL")
                {

                    ToolTip = 'Specifies the value of the NP Pass Server Base URL field';
                    ApplicationArea = NPRRetail;
                }
                field("Pass Notification Method"; Rec."Pass Notification Method")
                {

                    ToolTip = 'Specifies the value of the Pass Notification Method field';
                    ApplicationArea = NPRRetail;
                }
                field("Passes API"; Rec."Passes API")
                {

                    ToolTip = 'Specifies the value of the Passes API field';
                    ApplicationArea = NPRRetail;
                }
                field("PUT Passes Template"; Rec."PUT Passes Template".HasValue())
                {

                    Caption = 'Have Template';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Have Template field';
                    ApplicationArea = NPRRetail;
                }
                field("Pass Token"; Rec."Pass Token")
                {

                    ToolTip = 'Specifies the value of the Pass Token field';
                    ApplicationArea = NPRRetail;
                }
                field("Pass Type Code"; Rec."Pass Type Code")
                {

                    ToolTip = 'Specifies the value of the Pass Type Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Generate Magento PW URL"; Rec."Generate Magento PW URL")
                {

                    ToolTip = 'Specifies the value of the Generate Magento PW URL field';
                    ApplicationArea = NPRRetail;
                }
                field("Fallback Magento PW URL"; Rec."Fallback Magento PW URL")
                {

                    ToolTip = 'Specifies the value of the Fallback Magento PW URL field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the E-Mail Templates action';
                ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the SMS Template action';
                ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Renewal Notification List action';
                ApplicationArea = NPRRetail;
            }
        }
        area(processing)
        {

            action(ExportWalletTemplateFile)
            {
                Caption = 'Export Wallet Template File';
                ToolTip = 'Exports the default or current template used to send information to wallet.';
                Image = ExportAttachment;
                ApplicationArea = NPRRetail;


                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    MemberNotification: Codeunit "NPR MM Member Notification";
                    PassData: Text;
                    FileName: Text;
                    TemplateOutStream: outstream;
                    TemplateInStream: InStream;
                    FileNameLbl: Label '%1 - %2.json', Locked = true;
                    DownloadLbl: Label 'Downloading template';
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

                    TempBlob.CreateInStream(TemplateInStream);
                    FileName := StrSubstNo(FileNameLbl, Rec.Code, Rec.Description);
                    DownloadFromStream(TemplateInStream, DownloadLbl, '', 'Template Files (*.json)|*.json', FileName)
                end;
            }

            action(ImportWalletTemplateFile)
            {
                Caption = 'Import Wallet Template File';
                ToolTip = 'Define information sent to wallet.';
                Image = ImportCodes;
                ApplicationArea = NPRRetail;


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

                ToolTip = 'Executes the Refresh Renew Notification action';
                ApplicationArea = NPRRetail;

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

