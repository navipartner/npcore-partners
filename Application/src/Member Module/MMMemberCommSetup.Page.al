page 6151187 "NPR MM Member Comm. Setup"
{
    Extensible = False;

    Caption = 'Member Communication Setup';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MM Member Comm. Setup";
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Membership Code"; Rec."Membership Code")
                {
                    ToolTip = 'Specifies the value of the Membership Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Message Type"; Rec."Message Type")
                {
                    ToolTip = 'Specifies the value of the Message Type field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Preferred Method"; Rec."Preferred Method")
                {
                    ToolTip = 'Specifies the value of the Preferred Method field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Notification Engine"; Rec."Notification Engine")
                {
                    ToolTip = 'Specifies the value of the Notification Engine field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ExportSenderTemplateFile)
            {
                Caption = 'Export Sender Template File';
                ToolTip = 'Exports the default or current template used to send information to wallet.';
                Image = ExportAttachment;
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;


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
                    Rec.CalcFields("Sender Template");
                    if (not REc."Sender Template".HasValue()) then begin

                        if (Rec."Notification Engine" = Rec."Notification Engine"::M2_EMAILER) then
                            if (Rec."Message Type" = REc."Message Type"::WELCOME) then
                                PassData := MemberNotification.GetDefaultM2WelcomeEmailTemplate();

                        if (PassData = '') then
                            PassData := '// No default template defined.';

                        Rec."Sender Template".CreateOutStream(TemplateOutStream);
                        TemplateOutStream.Write(PassData);
                        Rec.Modify();
                        Rec.CalcFields("Sender Template");
                    end;

                    TempBlob.FromRecord(Rec, Rec.FieldNo("Sender Template"));
                    if (not TempBlob.HasValue()) then
                        exit;
                    TempBlob.CreateInStream(TemplateInStream);
                    FileName := StrSubstNo(FileNameLbl, Rec."Membership Code", Rec.Description);
                    DownloadFromStream(TemplateInStream, DownloadLbl, '', 'Template Files (*.json)|*.json', FileName)
                end;
            }

            action(ImportSenderTemplateFile)
            {
                Caption = 'Import Sender Template File';
                ToolTip = 'Define information sent to wallet.';
                Image = ImportCodes;
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    FileMgt: Codeunit "File Management";
                    FileName: Text;
                    RecRef: RecordRef;
                    ImportFileLbl: Label 'Import File';
                begin
                    FileName := FileMgt.BLOBImportWithFilter(TempBlob, ImportFileLbl, '', 'Template Files (*.json)|*.json', 'json');

                    if (FileName = '') then
                        exit;

                    RecRef.GetTable(Rec);
                    TempBlob.ToRecordRef(RecRef, Rec.FieldNo(Rec."Sender Template"));
                    RecRef.SetTable(Rec);

                    Rec.Modify(true);
                    Clear(TempBlob);

                end;
            }

            action(UpdateMembershipMembers)
            {
                Caption = 'Update Members';
                ToolTip = 'This action will iterate all members for the selected membership and apply the default settings non-destructively.';
                Image = ImportCodes;
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Scope = Repeater;
                Promoted = true;

                trigger OnAction()
                var
                    MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
                    Membership: Record "NPR MM Membership";
                    ApplyDefault: Label 'Apply the default communication setup to %1 memberships?';
                    MembershipCount, ProcessCount : Integer;
                    Window: Dialog;
                    MembershipUpdate: Label 'Processing #1###### of #2######', Comment = 'Do not translate the #1###### and #2###### part of the string.';
                begin
                    Membership.SetFilter("Membership Code", '=%1', Rec."Membership Code");
                    MembershipCount := Membership.Count();
                    if (not Confirm(ApplyDefault, true, MembershipCount)) then
                        exit;

                    Window.Open(MembershipUpdate);
                    Window.Update(1, ProcessCount);
                    Window.Update(2, MembershipCount);

                    repeat
                        MembershipManagement.CreateMembershipCommunicationDefaultSetup(Membership."Entry No.");
                        ProcessCount += 1;
                        if (ProcessCount mod 10 = 0) then begin
                            Commit();
                            Window.Update(1, ProcessCount);
                        end;
                    until (Membership.Next() = 0);

                    Window.Close();
                end;
            }
        }
    }
}

