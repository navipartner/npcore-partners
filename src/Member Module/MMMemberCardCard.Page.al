page 6060133 "NPR MM Member Card Card"
{
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.22/TSA /20170911 CASE 284560 Added field Card Is Temporary
    // MM1.28/TSA /20180420 CASE 311030 Changed property InsertAllowed to No, to removed the "New" button available in the Member Card subpage part
    // MM1.45/TSA /20200717 CASE 415293 Added a warning when updating external number

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

                    trigger OnValidate()
                    var
                        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
                        NotFoundReasonText: Text;
                    begin

                        //-MM1.45 [415293]
                        if ((Rec."External Card No." <> xRec."External Card No.") and (xRec."External Card No." <> '')) then
                            if (not Confirm(EXT_NO_CHANGE, false)) then
                                Error('');

                        if (MembershipManagement.GetMembershipFromExtCardNo("External Card No.", Today, NotFoundReasonText) <> 0) then
                            Error(TEXT6060000, FieldCaption("External Card No."), "External Card No.");

                        "External Card No. Last 4" := '';
                        if (StrLen("External Card No.") >= 4) then
                            "External Card No. Last 4" := CopyStr("External Card No.", StrLen("External Card No.") - 3);
                        //+MM1.45 [415293]
                    end;
                }
                field("External Card No. Last 4"; "External Card No. Last 4")
                {
                    ApplicationArea = All;
                }
                field("Pin Code"; "Pin Code")
                {
                    ApplicationArea = All;
                }
                field("Valid Until"; "Valid Until")
                {
                    ApplicationArea = All;
                }
                field("Card Is Temporary"; "Card Is Temporary")
                {
                    ApplicationArea = All;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                }
                field("Blocked At"; "Blocked At")
                {
                    ApplicationArea = All;
                }
                field("Block Reason"; "Block Reason")
                {
                    ApplicationArea = All;
                }
                field("Membership Entry No."; "Membership Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Member Entry No."; "Member Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Document ID"; "Document ID")
                {
                    ApplicationArea = All;
                    Visible = false;
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

