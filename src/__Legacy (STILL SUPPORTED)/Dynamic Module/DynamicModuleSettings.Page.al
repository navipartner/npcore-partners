page 6014500 "NPR Dynamic Module Settings"
{
    // NPR5.38/NPKNAV/20180126  CASE 294992 Transport NPR5.38 - 26 January 2018

    Caption = 'Dynamic Module Settings';
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    ShowFilter = false;
    SourceTable = "NPR Dynamic Module Setting";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Name)
                {
                    ApplicationArea = All;
                    Caption = 'Setting Name';
                    Style = Strong;
                    StyleExpr = "Setting ID" = 0;
                }
                field("Formatted Value"; "Formatted Value")
                {
                    ApplicationArea = All;
                    Caption = 'Setting Value';

                    trigger OnAssistEdit()
                    begin
                        EditSetting;
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(DoEditSetting)
            {
                Caption = 'Edit Setting';
                Image = Edit;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea=All;

                trigger OnAction()
                begin
                    EditSetting;
                end;
            }
            action(RestoreSetting)
            {
                Caption = 'Restore Setting';
                Ellipsis = true;
                Image = Restore;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea=All;

                trigger OnAction()
                begin
                    if not Confirm(ConfirmRestoreMsg) then
                        exit;
                    DynamicModuleHelper.RestoreSetting(Rec);
                    ModifiedDynamicModuleSetting := Rec;
                    if not ModifiedDynamicModuleSetting.Insert then
                        ModifiedDynamicModuleSetting.Modify;
                    CurrPage.Update;
                end;
            }
        }
    }

    trigger OnClosePage()
    begin
        if ModifiedDynamicModuleSetting.FindSet then
            repeat
                DynamicModuleSetting.Get(ModifiedDynamicModuleSetting."Module Guid", ModifiedDynamicModuleSetting."Setting ID");
                if DynamicModuleSetting."Formatted Value" <> ModifiedDynamicModuleSetting."Formatted Value" then begin
                    DynamicModuleSetting := ModifiedDynamicModuleSetting;
                    DynamicModuleSetting.Modify;
                end;
            until ModifiedDynamicModuleSetting.Next = 0;
    end;

    var
        ModifiedDynamicModuleSetting: Record "NPR Dynamic Module Setting" temporary;
        DynamicModuleSetting: Record "NPR Dynamic Module Setting";
        DynamicModuleHelper: Codeunit "NPR Dynamic Module Helper";
        ConfirmRestoreMsg: Label 'Value will be restored to default value. Do you want to continue?';

    procedure SetModuleSettings(var DynamicModuleSetting: Record "NPR Dynamic Module Setting")
    begin
        Rec.Copy(DynamicModuleSetting, true);
    end;

    local procedure EditSetting()
    var
        DynamicModuleSettingDialog: Page "NPR Dynamic Module Sett. Dlg.";
        OptionNumber: Integer;
    begin
        if Rec."Data Type" = Rec."Data Type"::Option then begin
            OptionNumber := StrMenu(Rec."Option String", "Integer Value" + 1);
            if OptionNumber = 0 then
                exit;
            ModifiedDynamicModuleSetting := Rec;
            DynamicModuleHelper.CheckSetupValue(ModifiedDynamicModuleSetting, OptionNumber - 1);
            DynamicModuleHelper.SetSetupValue(ModifiedDynamicModuleSetting, OptionNumber - 1);
            if not ModifiedDynamicModuleSetting.Insert then
                ModifiedDynamicModuleSetting.Modify;
            Rec := ModifiedDynamicModuleSetting;
        end else begin
            DynamicModuleSettingDialog.SetModuleScopeSetting(Rec);
            if DynamicModuleSettingDialog.RunModal = ACTION::OK then begin
                DynamicModuleSettingDialog.GetModuleScopeSetting(Rec);
                ModifiedDynamicModuleSetting := Rec;
                if not ModifiedDynamicModuleSetting.Insert then
                    ModifiedDynamicModuleSetting.Modify;
            end;
        end;
        CurrPage.Update;
    end;
}

