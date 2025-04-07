page 6184896 "NPR SG TicketProfileLine"
{
    Extensible = false;

    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR SG TicketProfileLine";
    DelayedInsert = true;
    Caption = 'Speedgate Ticket Profile';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the value of the Code field.', Comment = '%';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                    NotBlank = true;
                }
                field(LineNo; Rec.LineNo)
                {
                    ToolTip = 'Specifies the value of the Line No. field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field(RuleType; Rec.RuleType)
                {
                    ToolTip = 'Specifies the value of the Rule Type field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(ItemNo; Rec.ItemNo)
                {
                    ToolTip = 'Specifies the value of the Item No. field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(AdmissionCode; Rec.AdmissionCode)
                {
                    ToolTip = 'Specifies the value of the Admission Code field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(CalendarCode; Rec.CalendarCode)
                {
                    ToolTip = 'Specifies the value of the Calendar Code field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(PermitFromTime; Rec.PermitFromTime)
                {
                    ToolTip = 'Specifies the value of the Non-Working From Time field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }

                field(PermitUntilTime; Rec.PermitUntilTime)
                {
                    ToolTip = 'Specifies the value of the Non-Working Until Time field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }

            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        ValidateRejectRule();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        ValidateRejectRule();
    end;

    local procedure ValidateRejectRule()
    var
        RequiredForRejectRule: Label 'The field %1 is required for a reject rule.';
    begin
        if (Rec.RuleType <> Rec.RuleType::REJECT) then
            exit;

        if (Rec.ItemNo = '') then
            Error(RequiredForRejectRule, Rec.FieldCaption(ItemNo));

    end;
}