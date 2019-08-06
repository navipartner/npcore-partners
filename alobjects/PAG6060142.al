page 6060142 "MM Member Notification Setup"
{
    // MM1.14/TSA/20160523  CASE 240871 Reminder Service
    // MM1.29/TSA /20180506 CASE 314131 Added field for wallet services
    // MM1.29.02/TSA /20180528 CASE 317156 Refactored Default template, Added SMS Template action
    // MM1.32/TSA/20180725  CASE 323333 Transport MM1.32 - 25 July 2018
    // MM1.36/TSA /20181120 CASE 331590 Added Action "Refresh Renew Notification"
    // #362794/TSA /20190722 CASE 362794 Removed RunCmdModal(), added RunProcess() to use interop

    Caption = 'Member Notification Setup';
    PageType = List;
    SourceTable = "MM Member Notification Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                }
                field(Description; Description)
                {
                }
                field(Type; Type)
                {
                }
                field("Days Before"; "Days Before")
                {
                }
                field("Days Past"; "Days Past")
                {
                }
                field("Processing Method"; "Processing Method")
                {
                }
                field("Template Filter Value"; "Template Filter Value")
                {
                }
                field("Community Code"; "Community Code")
                {
                }
                field("Membership Code"; "Membership Code")
                {
                }
                field("Next Notification Code"; "Next Notification Code")
                {
                }
                field("Target Member Role"; "Target Member Role")
                {
                }
                field("Include NP Pass"; "Include NP Pass")
                {
                }
                field("NP Pass Server Base URL"; "NP Pass Server Base URL")
                {
                }
                field("Pass Notification Method"; "Pass Notification Method")
                {
                }
                field("Passes API"; "Passes API")
                {
                }
                field("""PUT Passes Template"".HASVALUE()"; "PUT Passes Template".HasValue())
                {
                    Caption = 'Have Template';
                    Editable = false;
                }
                field("Pass Token"; "Pass Token")
                {
                }
                field("Pass Type Code"; "Pass Type Code")
                {
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
                RunObject = Page "E-mail Templates";
                RunPageView = WHERE ("Table No." = CONST (6060139));
            }
            action("SMS Template")
            {
                Caption = 'SMS Template';
                Image = InteractionTemplate;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page "SMS Template List";
                RunPageView = WHERE ("Table No." = CONST (6060139));
            }
            action("Edit Pass Template")
            {
                Caption = 'Edit Pass Template';
                Image = Template;
                Promoted = true;
                PromotedIsBig = true;

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
                RunObject = Page "MM Membership Notification";
                RunPageLink = "Notification Trigger" = CONST (RENEWAL);
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

                trigger OnAction()
                var
                    MemberNotification: Codeunit "MM Member Notification";
                    MembershipSetup: Record "MM Membership Setup";
                begin

                    //-MM1.36 [331590]
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
                    //+MM1.36 [331590]
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
        MemberNotification: Codeunit "MM Member Notification";
    begin
        CalcFields("PUT Passes Template");
        if (not "PUT Passes Template".HasValue()) then begin
            //-+MM1.29.02 [317156] Create the default template for passes
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
        TempBlob: Record TempBlob temporary;
        outstream: OutStream;
        instream: InStream;
    begin

        if (UseDialog) then begin
            FileManagement.BLOBImport(TempBlob, '*.json');
        end else begin
            FileManagement.BLOBImport(TempBlob, Path);
        end;

        TempBlob.Blob.CreateInStream(instream);
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

        //-#362794 [362794]
        // RunCmdModal('"notepad.exe" "'+ Path + '"');
        RunProcess (Path, '', true);
        //+#362794 [362794]
    end;

    procedure RunProcess(Filename: Text;Arguments: Text;Modal: Boolean)
    var
        [RunOnClient]
        Process: DotNet npNetProcess;
        [RunOnClient]
        ProcessStartInfo: DotNet npNetProcessStartInfo;
    begin

        //-#362783 [362783]
        ProcessStartInfo := ProcessStartInfo.ProcessStartInfo(Filename,Arguments);
        Process := Process.Start(ProcessStartInfo);
        if Modal then
          Process.WaitForExit();

        //+#362783 [362783]
    end;
}

