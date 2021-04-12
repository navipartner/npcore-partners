page 6060133 "NPR MM Member Card Card"
{
    UsageCategory = None;
    Caption = 'Member Card Card';
    DataCaptionExpression = Rec."External Card No.";
    InsertAllowed = false;
    SourceTable = "NPR MM Member Card";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("External Card No."; Rec."External Card No.")
                {
                    ApplicationArea = All;
                    NotBlank = true;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the External Card No. field';

                    trigger OnValidate()
                    var
                        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
                        NotFoundReasonText: Text;
                    begin

                        if ((Rec."External Card No." <> xRec."External Card No.") and (xRec."External Card No." <> '')) then
                            if (not Confirm(EXT_NO_CHANGE, false)) then
                                Error('');

                        if (MembershipManagement.GetMembershipFromExtCardNo(Rec."External Card No.", Today, NotFoundReasonText) <> 0) then
                            Error(TEXT6060000, Rec.FieldCaption("External Card No."), Rec."External Card No.");

                        Rec."External Card No. Last 4" := '';
                        if (StrLen(Rec."External Card No.") >= 4) then
                            Rec."External Card No. Last 4" := CopyStr(Rec."External Card No.", StrLen(Rec."External Card No.") - 3);

                    end;
                }
                field("External Card No. Last 4"; Rec."External Card No. Last 4")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Card No. Last 4 field';
                }
                field("Pin Code"; Rec."Pin Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Pin Code field';
                }
                field("Valid Until"; Rec."Valid Until")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Valid Until field';
                }
                field("Card Is Temporary"; Rec."Card Is Temporary")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Is Temporary field';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field("Blocked At"; Rec."Blocked At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked At field';
                }
                field("Block Reason"; Rec."Block Reason")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Block Reason field';
                }
                field("Membership Entry No."; Rec."Membership Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Membership Entry No. field';
                }
                field("Member Entry No."; Rec."Member Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Member Entry No. field';
                }
                field("Document ID"; Rec."Document ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Document ID field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if (CloseAction = ACTION::OK) then
            Rec.TestField("External Card No.");
    end;

    var
        EXT_NO_CHANGE: Label 'Please note that changing the external number requires re-printing of documents where this number is used. Do you want to continue?';
        TEXT6060000: Label 'The %1 %2 is already in use.';
}

