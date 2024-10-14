page 6184824 "NPR FR Audit Workshift Step"
{
    Caption = 'FR Audit Workshift Setup';
    Extensible = false;
    PageType = ListPart;
    SourceTable = "NPR FR Audit Setup";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(WorkshiftSetup)
            {
                Caption = 'Workshift Setup';

                field("Monthly Workshift Duration"; Rec."Monthly Workshift Duration")
                {
                    ToolTip = 'Specifies the monthly workshift duration.';
                    ApplicationArea = NPRRetail;
                }
                field("Yearly Workshift Duration"; Rec."Yearly Workshift Duration")
                {
                    ToolTip = 'Specifies the yearly workshift duration.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;

    internal procedure CopyRealToTemp()
    begin
        if not FRAuditSetup.Get() then
            exit;
        Rec.TransferFields(FRAuditSetup);
        if not Rec.Insert() then
            Rec.Modify();
    end;

    internal procedure CreateFRAuditWorkshiftData()
    begin
        if not Rec.Get() then
            exit;
        if not FRAuditSetup.Get() then
            FRAuditSetup.Init();
        if Rec."Monthly Workshift Duration" <> xRec."Monthly Workshift Duration" then
            FRAuditSetup."Monthly Workshift Duration" := Rec."Monthly Workshift Duration";
        if Rec."Yearly Workshift Duration" <> xRec."Yearly Workshift Duration" then
            FRAuditSetup."Yearly Workshift Duration" := Rec."Yearly Workshift Duration";
        if not FRAuditSetup.Insert() then
            FRAuditSetup.Modify();
    end;

    local procedure CheckIsDataPopulated(): Boolean
    begin
        if not Rec.Get() then
            exit(false);

        exit((Format(Rec."Monthly Workshift Duration") <> '') and (Format(Rec."Yearly Workshift Duration") <> ''));
    end;

    internal procedure IsDataPopulated(): Boolean
    begin
        exit(CheckIsDataPopulated());
    end;

    var
        FRAuditSetup: Record "NPR FR Audit Setup";
}
