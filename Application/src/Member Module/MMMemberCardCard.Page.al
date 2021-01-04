page 6060133 "NPR MM Member Card Card"
{

    Caption = 'Member Card Card';
    DataCaptionExpression = "External Card No.";
    InsertAllowed = false;
    SourceTable = "NPR MM Member Card";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("External Card No."; "External Card No.")
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

                        if (MembershipManagement.GetMembershipFromExtCardNo("External Card No.", Today, NotFoundReasonText) <> 0) then
                            Error(TEXT6060000, FieldCaption("External Card No."), "External Card No.");

                        "External Card No. Last 4" := '';
                        if (StrLen("External Card No.") >= 4) then
                            "External Card No. Last 4" := CopyStr("External Card No.", StrLen("External Card No.") - 3);

                    end;
                }
                field("External Card No. Last 4"; "External Card No. Last 4")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Card No. Last 4 field';
                }
                field("Pin Code"; "Pin Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Pin Code field';
                }
                field("Valid Until"; "Valid Until")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Valid Until field';
                }
                field("Card Is Temporary"; "Card Is Temporary")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Card Is Temporary field';
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field("Blocked At"; "Blocked At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked At field';
                }
                field("Block Reason"; "Block Reason")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Block Reason field';
                }
                field("Membership Entry No."; "Membership Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Membership Entry No. field';
                }
                field("Member Entry No."; "Member Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Member Entry No. field';
                }
                field("Document ID"; "Document ID")
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
            TestField("External Card No.");
    end;

    var
        EXT_NO_CHANGE: Label 'Please note that changing the external number requires re-printing of documents where this number is used. Do you want to continue?';
        TEXT6060000: Label 'The %1 %2 is already in use.';
}

