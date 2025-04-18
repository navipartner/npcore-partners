﻿page 6059832 "NPR Event Plan. Line Buffer"
{
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'Event Planning Line Buffer';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Event Plan. Line Buffer";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Planning Date"; Rec."Planning Date")
                {

                    StyleExpr = GlobalStyle;
                    ToolTip = 'Specifies the value of the Planning Date field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        SetHighlight(true);
                    end;
                }
                field("Starting Time"; Rec."Starting Time")
                {

                    StyleExpr = GlobalStyle;
                    ToolTip = 'Specifies the value of the Starting Time field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        SetHighlight(true);
                    end;
                }
                field("Ending Time"; Rec."Ending Time")
                {

                    StyleExpr = GlobalStyle;
                    ToolTip = 'Specifies the value of the Ending Time field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        SetHighlight(true);
                    end;
                }
                field(Quantity; Rec.Quantity)
                {

                    StyleExpr = GlobalStyle;
                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        SetHighlight(true);
                    end;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {

                    Editable = false;
                    StyleExpr = GlobalStyle;
                    ToolTip = 'Specifies the value of the Unit of Measure Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Status Checked"; Rec."Status Checked")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Status Checked field';
                    ApplicationArea = NPRRetail;
                }
                field("Action Type"; Rec."Action Type")
                {

                    ToolTip = 'Specifies the value of the Action Type field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        SetHighlight(true);
                    end;
                }
                field("Status Type"; Rec."Status Type")
                {

                    Editable = false;
                    StyleExpr = GlobalStyle;
                    ToolTip = 'Specifies the value of the Status Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Status Text"; Rec."Status Text")
                {

                    Editable = false;
                    StyleExpr = GlobalStyle;
                    ToolTip = 'Specifies the value of the Status Text field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Check Capacity/Availability")
            {
                Caption = 'Check Capacity/Availability';
                Image = ItemAvailability;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Check Capacity/Availability action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.SetRange("Status Checked", false);
                    if Rec.FindSet() then
                        repeat
                            EventPlanLineGroupingMgt.CheckCapAndTimeAvailabilityOnDemand(Rec, true);
                        until Rec.Next() = 0;
                    Rec.SetRange("Status Checked");
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetHighlight(false);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = ACTION::LookupOK then begin
            if not CheckStatusType() then
                exit(false);
            if not CheckStatusChecked() then
                exit(false);
            if not CheckActionType() then
                exit(false);
            exit(FinalCheck());
        end;
    end;

    var
        EventPlanLineGroupingMgt: Codeunit "NPR Event Plan.Line Group. Mgt";
        GlobalStyle: Text;
        StatusCheckConfirm: Label 'Status has not been checked on all lines. If you decide to continue it will be checked during line transfer. Do you want to continue?';
        ResOvercapMsg: Label 'Resource is not allowed to be overcapacitated.';
        ActionTypeBlankMsg: Label '%1 can not be blank. Please set a value in missing lines.';
        FinalCheckMsg: Label 'Only lines with %1 = %2 will be created. There are %3 of these.';
        CantContinueMsg: Label 'Please change %1 on some lines to %2 to continue.';
        FinalConfirm: Label 'Do you want to continue?';

    local procedure SetHighlight(FromValidate: Boolean)
    begin
        GlobalStyle := 'Standard';
        case Rec."Status Type" of
            Rec."Status Type"::Error, Rec."Status Type"::Warning:
                GlobalStyle := 'Attention';
        end;
        CurrPage.Update(FromValidate);
    end;

    local procedure CheckStatusType(): Boolean
    var
        StatusTypeErrorCount: Integer;
    begin
        Rec.SetRange("Status Type", Rec."Status Type"::Error);
        StatusTypeErrorCount := Rec.Count();
        Rec.SetRange("Status Type");
        if StatusTypeErrorCount > 0 then begin
            Message(ResOvercapMsg);
            exit(false);
        end;
        exit(true);
    end;

    local procedure CheckActionType(): Boolean
    var
        ActionTypeBlankCount: Integer;
    begin
        Rec.SetRange("Action Type", Rec."Action Type"::" ");
        ActionTypeBlankCount := Rec.Count();
        Rec.SetRange("Action Type");
        if ActionTypeBlankCount > 0 then begin
            Message(ActionTypeBlankMsg, Rec.FieldCaption("Action Type"));
            exit(false);
        end;
        exit(true);
    end;

    local procedure CheckStatusChecked(): Boolean
    var
        NotCheckedCount: Integer;
    begin
        Rec.SetRange("Status Checked", false);
        NotCheckedCount := Rec.Count();
        Rec.SetRange("Status Checked");
        if NotCheckedCount > 0 then
            exit(Confirm(StatusCheckConfirm));
        exit(true);
    end;

    local procedure FinalCheck(): Boolean
    var
        ActionTypeCreateCount: Integer;
        MsgToDisplay: Text;
    begin
        Rec.SetRange("Action Type", Rec."Action Type"::Skip);
        Rec.SetRange("Action Type", Rec."Action Type"::Create);
        ActionTypeCreateCount := Rec.Count();
        Rec.SetRange("Action Type");
        MsgToDisplay := StrSubstNo(FinalCheckMsg, Rec.FieldCaption("Action Type"), Format(Rec."Action Type"::Create), Format(ActionTypeCreateCount));
        if ActionTypeCreateCount = 0 then begin
            MsgToDisplay := MsgToDisplay + ' ' + StrSubstNo(CantContinueMsg, Rec.FieldCaption("Action Type"), Format(Rec."Action Type"::Create));
            Message(MsgToDisplay);
            exit(false);
        end else begin
            MsgToDisplay := MsgToDisplay + ' ' + StrSubstNo(FinalConfirm);
            exit(Confirm(MsgToDisplay));
        end;
    end;
}

