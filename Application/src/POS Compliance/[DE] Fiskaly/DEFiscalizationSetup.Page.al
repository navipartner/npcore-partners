page 6184744 "NPR DE Fiscalization Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'DE Fiscalization Setup';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR DE Fiscalization Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            field("Enable DE Fiscal"; Rec."Enable DE Fiscal")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Enable DE Fiscalization field.';

                trigger OnValidate()
                begin
                    if xRec."Enable DE Fiscal" <> Rec."Enable DE Fiscal" then
                        EnabledValueChanged := true;
                end;
            }
            field("Enable UUIDv4 Check"; Rec."Enable UUIDv4 Check")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the value of the Enable UUIDv4 Check field.', Comment = '%';
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

    trigger OnClosePage()
    var
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        if EnabledValueChanged then
            ApplicationAreaMgmtFacade.RefreshExperienceTierCurrentCompany();
    end;

    var
        EnabledValueChanged: Boolean;
}