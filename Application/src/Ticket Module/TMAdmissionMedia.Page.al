page 6151266 "NPR TM Admission Media"
{
    Extensible = False;

    Caption = 'Ticket Admission Media';
    InsertAllowed = false;
    PageType = CardPart;
    UsageCategory = None;
    SourceTable = "NPR TM Admission";

    layout
    {
        area(content)
        {
            group(AdmissionImage)
            {
                Caption = 'Admission Image';
                field("Guest Avatar Image"; Rec.AdmissionImage)
                {
                    ToolTip = 'Specifies the value of the Admission Image field';
                    ApplicationArea = NPRTicketAdvanced;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(GuestAvatarImage)
            {
                Caption = 'Admission Image';
                action(ImportAdmissionImage)
                {
                    Caption = 'Import Admission Image';
                    Image = Import;
                    ToolTip = 'Executes the import admission image action';
                    ApplicationArea = NPRTicketAdvanced;

                    trigger OnAction()
                    begin
                        DoImportAdmissionImage(Rec);
                    end;
                }

                action(DeleteAdmissionImage)
                {
                    Caption = 'Delete Admission Image';
                    Image = Delete;
                    ToolTip = 'Executes the delete admission image action';
                    ApplicationArea = NPRTicketAdvanced;

                    trigger OnAction()
                    begin
                        DoDeleteAdmissionImage(Rec);
                    end;
                }
            }
        }
    }

    local procedure DoImportAdmissionImage(var Admission: Record "NPR TM Admission")
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
    begin
        FileManagement.BLOBImport(TempBlob, '');
        if not TempBlob.HasValue() then
            Error('');

        TempBlob.CreateInStream(InStr);

        Clear(Admission.AdmissionImage);
        Admission.AdmissionImage.ImportStream(InStr, Admission.FieldCaption(AdmissionImage));
        Admission.Modify(true);
    end;

    local procedure DoDeleteAdmissionImage(var Admission: Record "NPR TM Admission")
    var
        DeleteImageQst: Label 'Do you want to delete %1?', Comment = '%1 = Admission Image';
    begin
        if not Confirm(DeleteImageQst, false, Admission.FieldCaption(AdmissionImage)) then
            exit;

        Clear(Admission.AdmissionImage);
        Admission.Modify(true);
    end;


}
