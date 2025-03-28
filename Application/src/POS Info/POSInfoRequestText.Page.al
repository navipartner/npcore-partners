﻿page 6014456 "NPR POS Info: Request Text"
{
    Extensible = False;
    PageType = StandardDialog;
    UsageCategory = None;
    SourceTable = "NPR POS Info";
    InsertAllowed = false;
    DeleteAllowed = false;
    DataCaptionExpression = GetDataCaptionExpression();
    Caption = 'POS Info: Request Text';

    layout
    {
        area(Content)
        {
            label(AddInstructionLbl)
            {
                CaptionClass = GenerateInstructions();
                MultiLine = true;
                ShowCaption = false;
                ApplicationArea = NPRRetail;
            }
            field(UserInputString; UserInputString)
            {
                ShowCaption = false;
                ToolTip = 'Specifies additional information to be stored on the POS sale line';
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.FilterGroup(2);
        Rec.SetRecFilter();
        Rec.FilterGroup(0);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        Confirmed: Boolean;
        MustBeSpecifiedLbl: Label 'You cannot leave this field blank.';
        ConfirmRetryQst: Label 'Do you want to try again?';
    begin
        Confirmed := (UserInputString <> '') and (CloseAction = CloseAction::OK);
        if not Confirmed then begin
            if Rec."Input Mandatory" then
                Confirmed := not Confirm('%1\%2', false, MustBeSpecifiedLbl, ConfirmRetryQst)
            else
                Confirmed := CloseAction <> CloseAction::OK;
        end;
        exit(Confirmed);
    end;

    internal procedure GetUserInput(): Text
    begin
        exit(UserInputString);
    end;

# pragma warning disable AA0228
    local procedure GetDataCaptionExpression(): Text
# pragma warning restore
    var
        AddInfoRequiredLbl: Label 'We need more information';
    begin
        if Rec.Message <> '' then
            exit(Rec.Message);
        exit(AddInfoRequiredLbl);
    end;

# pragma warning disable AA0228
    local procedure GenerateInstructions(): Text
# pragma warning restore
    var
        TextForLbl: Label 'Please specify additional information for %1 %2';
    begin
        if Rec.Description <> '' then
            exit(Rec.Description);
        exit(StrSubstNo(TextForLbl, Rec.TableCaption, Rec.Code));
    end;

    var
        UserInputString: Text;
}
