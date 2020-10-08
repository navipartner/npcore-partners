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
            action("E-Mail Templates")
            {
                Caption = 'E-Mail Templates';
                Image = InteractionTemplate;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page "NPR E-mail Templates";
                RunPageView = WHERE("Table No." = CONST(6060139));
                ApplicationArea = All;
            }
            action("SMS Template")
            {
                Caption = 'SMS Template';
                Image = InteractionTemplate;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page "NPR SMS Template List";
                RunPageView = WHERE("Table No." = CONST(6060139));
                ApplicationArea = All;
            }
            action("Edit Pass Template")
            {
                Caption = 'Edit Pass Template';
                Image = Template;
                Promoted = true;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    EditPassTemplate();
                end;
            }
            action("Renew Notifications List")
            {
                Caption = 'Notifications';
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
            action("Refresh Renew Notification")
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

    local procedure EditPassTemplate()
    var
        Path: Text[1024];
    begin

        Path := ExportPassTemplate(false);
        RunPassTemplateEditor(Path, FieldCaption("PUT Passes Template"));
        ImportPassTemplate(Path, false);
        FileManagement.DeleteClientFile(Path);
        CurrPage.Update(true);
    end;

    local procedure ExportPassTemplate(UseDialog: Boolean) Path: Text[1024]
    var
        outstream: OutStream;
        instream: InStream;
        PassData: Text;
        ToFile: Text;
        IsDownloaded: Boolean;
        MemberNotification: Codeunit "NPR MM Member Notification";
    begin
        CalcFields("PUT Passes Template");
        if (not "PUT Passes Template".HasValue()) then begin

            PassData := MemberNotification.GetDefaultTemplate();
            "PUT Passes Template".CreateOutStream(outstream);
            outstream.Write(PassData);
            Modify();
            CalcFields("PUT Passes Template");
        end;

        "PUT Passes Template".CreateInStream(instream);

        if (not UseDialog) then begin
            ToFile := FileManagement.ClientTempFileName('json');
        end else begin
            ToFile := 'template.json';
        end;

        IsDownloaded := DownloadFromStream(instream, 'Export', '', '', ToFile);
        if (IsDownloaded) then
            exit(ToFile);

        Error('Export failed.');
    end;

    local procedure ImportPassTemplate(Path: Text[1024]; UseDialog: Boolean)
    var
        TempBlob: Codeunit "Temp Blob";
        outstream: OutStream;
        instream: InStream;
    begin

        if (UseDialog) then begin
            FileManagement.BLOBImport(TempBlob, '*.json');
        end else begin
            FileManagement.BLOBImport(TempBlob, Path);
        end;

        TempBlob.CreateInStream(instream);
        "PUT Passes Template".CreateOutStream(outstream, TEXTENCODING::UTF8);
        CopyStream(outstream, instream);

        Modify(true);
    end;

    local procedure RunPassTemplateEditor(Path: Text[1024]; desc: Text[100])
    var
        ret: Integer;
        f: File;
        extra: Text[30];
    begin

        // RunCmdModal('"notepad.exe" "'+ Path + '"');
        RunProcess(Path, '', true);

    end;

    procedure RunProcess(Filename: Text; Arguments: Text; Modal: Boolean)
    var
        [RunOnClient]
        Process: DotNet NPRNetProcess;
        [RunOnClient]
        ProcessStartInfo: DotNet NPRNetProcessStartInfo;
    begin

        ProcessStartInfo := ProcessStartInfo.ProcessStartInfo(Filename, Arguments);
        Process := Process.Start(ProcessStartInfo);
        if Modal then
            Process.WaitForExit();

    end;
}

