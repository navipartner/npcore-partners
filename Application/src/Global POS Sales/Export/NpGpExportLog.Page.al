#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
page 6184949 "NPR NpGp Export Log"
{
    Extensible = False;
    Caption = 'Global POS Sales Export Log';
    PageType = List;
    SourceTable = "NPR NpGp Export Log";
    UsageCategory = History;
    ApplicationArea = NPRRetail;
    InsertAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                Editable = false;
                field("Entry No"; Rec."Entry No")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the unique identifier of this record.';
                }
                field("POS Sales Setup Code"; Rec."POS Sales Setup Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the setup code this entry was created for.';
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Entry No. of the POS Entry exported.';
                }
                field(Sent; Rec.Sent)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the POS Entry was succesfully exported.';
                }
                field(Failed; Rec.Failed)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies if the export of the POS Entry failed.';
                }
                field("Last Error Text"; Rec."Last Error Text")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the error message received when trying to export of the POS Entry.';
                }
                field("Retry Count"; Rec."Retry Count")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the how many times the export of the POS Entry have failed.';
                }
                field("Next Resend"; Rec."Next Resend")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies when the system will try to resend the POS Entry if previous try failed.';
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'Last exported';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies when the this entry was export.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Export)
            {
                Caption = 'Export';
                ToolTip = 'This action will send the selected entries to the master environemnt';
                Image = Export;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    NpGpExportLog: Record "NPR NpGp Export Log";
                    NpGpExporttoAPI: Codeunit "NPR NpGp Export to API";
                begin
                    CurrPage.SetSelectionFilter(NpGpExportLog);
                    if NpGpExportLog.FindSet() then
                        repeat
                            NpGpExporttoAPI.ExportLogEntry(NpGpExportLog."Entry No");
                        until NpGpExportLog.Next() = 0;
                end;
            }
        }
    }
}
#endif