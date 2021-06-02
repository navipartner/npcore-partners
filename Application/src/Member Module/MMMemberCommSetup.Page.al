page 6151187 "NPR MM Member Comm. Setup"
{

    Caption = 'Member Communication Setup';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR MM Member Comm. Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Membership Code"; Rec."Membership Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Code field';
                }
                field("Message Type"; Rec."Message Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Message Type field';
                }
                field("Preferred Method"; Rec."Preferred Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Preferred Method field';
                }
                field("Notification Engine"; Rec."Notification Engine")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notification Engine field';
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
                ApplicationArea = All;

                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    FileMgt: Codeunit "File Management";
                    MemberNotification: Codeunit "NPR MM Member Notification";
                    Path: Text;
                    PassData: Text;
                    TemplateOutStream: outstream;
                    FileNameLbl: Label '%1 - %2.json', Locked = true;
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
                    Path := FileMgt.BLOBExport(TempBlob, TemporaryPath + StrSubstNo(FileNameLbl, Rec."Membership Code", Rec.Description), true);

                end;
            }

            action(ImportSenderTemplateFile)
            {
                Caption = 'Import Sender Template File';
                ToolTip = 'Define information sent to wallet.';
                Image = ImportCodes;
                ApplicationArea = All;

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

        }
    }
}

