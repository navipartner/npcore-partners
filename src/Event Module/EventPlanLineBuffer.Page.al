page 6059832 "NPR Event Plan. Line Buffer"
{
    // NPR5.55/TJ  /20200330 CASE 397741 New object

    AutoSplitKey = true;
    Caption = 'Event Planning Line Buffer';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Event Plan. Line Buffer";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Planning Date"; "Planning Date")
                {
                    ApplicationArea = All;
                    StyleExpr = GlobalStyle;

                    trigger OnValidate()
                    begin
                        SetHighlight(true);
                    end;
                }
                field("Starting Time"; "Starting Time")
                {
                    ApplicationArea = All;
                    StyleExpr = GlobalStyle;

                    trigger OnValidate()
                    begin
                        SetHighlight(true);
                    end;
                }
                field("Ending Time"; "Ending Time")
                {
                    ApplicationArea = All;
                    StyleExpr = GlobalStyle;

                    trigger OnValidate()
                    begin
                        SetHighlight(true);
                    end;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    StyleExpr = GlobalStyle;

                    trigger OnValidate()
                    begin
                        SetHighlight(true);
                    end;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = GlobalStyle;
                }
                field("Status Checked"; "Status Checked")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Action Type"; "Action Type")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        SetHighlight(true);
                    end;
                }
                field("Status Type"; "Status Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = GlobalStyle;
                }
                field("Status Text"; "Status Text")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = GlobalStyle;
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    Rec.SetRange("Status Checked", false);
                    if Rec.FindSet then
                        repeat
                            EventPlanLineGroupingMgt.CheckCapAndTimeAvailabilityOnDemand(Rec, true);
                        until Rec.Next = 0;
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
        case "Status Type" of
            "Status Type"::Error, "Status Type"::Warning:
                GlobalStyle := 'Attention';
        end;
        CurrPage.Update(FromValidate);
    end;

    local procedure CheckStatusType(): Boolean
    var
        StatusTypeErrorCount: Integer;
    begin
        SetRange("Status Type", "Status Type"::Error);
        StatusTypeErrorCount := Count;
        SetRange("Status Type");
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
        SetRange("Action Type", "Action Type"::" ");
        ActionTypeBlankCount := Count;
        SetRange("Action Type");
        if ActionTypeBlankCount > 0 then begin
            Message(ActionTypeBlankMsg, FieldCaption("Action Type"));
            exit(false);
        end;
        exit(true);
    end;

    local procedure CheckStatusChecked(): Boolean
    var
        NotCheckedCount: Integer;
    begin
        SetRange("Status Checked", false);
        NotCheckedCount := Count;
        SetRange("Status Checked");
        if NotCheckedCount > 0 then
            exit(Confirm(StatusCheckConfirm));
        exit(true);
    end;

    local procedure FinalCheck(): Boolean
    var
        ActionTypeSkipCount: Integer;
        ActionTypeCreateCount: Integer;
        MsgToDisplay: Text;
    begin
        SetRange("Action Type", "Action Type"::Skip);
        ActionTypeSkipCount := Count;
        SetRange("Action Type", "Action Type"::Create);
        ActionTypeCreateCount := Count;
        SetRange("Action Type");
        MsgToDisplay := StrSubstNo(FinalCheckMsg, FieldCaption("Action Type"), Format("Action Type"::Create), Format(ActionTypeCreateCount));
        if ActionTypeCreateCount = 0 then begin
            MsgToDisplay := MsgToDisplay + ' ' + StrSubstNo(CantContinueMsg, FieldCaption("Action Type"), Format("Action Type"::Create));
            Message(MsgToDisplay);
            exit(false);
        end else begin
            MsgToDisplay := MsgToDisplay + ' ' + StrSubstNo(FinalConfirm);
            exit(Confirm(MsgToDisplay));
        end;
    end;
}

