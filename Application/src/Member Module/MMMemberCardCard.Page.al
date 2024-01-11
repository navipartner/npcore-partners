page 6060133 "NPR MM Member Card Card"
{
    Extensible = False;
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
                    NotBlank = true;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the External Card No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

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
#pragma warning disable AA0139
                            Rec."External Card No. Last 4" := CopyStr(Rec."External Card No.", StrLen(Rec."External Card No.") - 3);
#pragma warning restore

                    end;
                }
                field("Display Name"; Rec."Display Name")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Display Name.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    DrillDownPageId = "NPR MM Member Card";
                }
                field("Valid Until"; Rec."Valid Until")
                {
                    ToolTip = 'Specifies the value of the Valid Until field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("External Membership No."; Rec."External Membership No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the External Membership No.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    DrillDownPageId = "NPR MM Membership Card";
                }
                field("External Member No."; Rec."External Member No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the External Member No.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    DrillDownPageId = "NPR MM Member Card";
                }
            }
            group(Card)
            {
                field("External Card No. Last 4"; Rec."External Card No. Last 4")
                {
                    ToolTip = 'Specifies the value of the External Card No. Last 4 field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Pin Code"; Rec."Pin Code")
                {
                    ToolTip = 'Specifies the value of the Pin Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Card Is Temporary"; Rec."Card Is Temporary")
                {
                    ToolTip = 'Specifies the value of the Card Is Temporary field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Blocked At"; Rec."Blocked At")
                {
                    ToolTip = 'Specifies the value of the Blocked At field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Block Reason"; Rec."Block Reason")
                {
                    ToolTip = 'Specifies the value of the Block Reason field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Entry No."; Rec."Membership Entry No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Membership Entry No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Member Entry No."; Rec."Member Entry No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Member Entry No. field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Document ID"; Rec."Document ID")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Document ID field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        ConfirmDeleteCard: Label 'Member card must have a card number to be valid. Do you want to remove this card?';

    begin
        if (CloseAction = ACTION::OK) then begin
            if (Rec."External Card No." = '') then begin
                if ((DT2Date(Rec.SystemCreatedAt) = Today()) and (Time() - DT2Time(Rec.SystemCreatedAt) < 1 * 60 * 1000)) then begin
                    if (not Rec.Delete()) then;
                end else begin
                    if (Confirm(ConfirmDeleteCard, false)) then begin
                        if (not Rec.Delete()) then;
                    end else begin
                        Rec.TestField("External Card No.");
                    end;
                end;
            end;
        end;
    end;

    var
        EXT_NO_CHANGE: Label 'Please note that changing the external number requires re-printing of documents where this number is used. Do you want to continue?';
        TEXT6060000: Label 'The %1 %2 is already in use.';
}

