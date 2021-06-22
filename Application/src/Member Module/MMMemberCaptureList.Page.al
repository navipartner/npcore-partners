page 6014457 "NPR MM Member Capture List"
{
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR MM Member Info Capture";
    InsertAllowed = false;
    DeleteAllowed = true;
    Editable = false;
    CardPageId = "NPR MM Member Info Capture";
    Caption = 'Members';

    layout
    {
        area(Content)
        {
            repeater(Overview)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("R_PhoneNo"; Rec."Phone No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Phone No. field';
                }
                field("R_FirstName"; Rec."First Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the First Name field';
                }
                field("R_LastName"; Rec."Last Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Name field';
                }
                field("R_Email"; Rec."E-Mail Address")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the E-Mail Address field';
                }
                field("R_ExternalCardNo"; Rec."External Card No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Card No. field';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Import Members")
            {
                Caption = 'Import Members';
                Image = ImportCodes;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ShowImportMemberAction;
                ApplicationArea = All;
                ToolTip = 'Executes the Import Members action';

                trigger OnAction()
                begin
                    ImportMembers();
                end;
            }
        }
    }


    var
        ShowImportMemberAction: Boolean;

    procedure SetShowImportAction()
    begin
        ShowImportMemberAction := true;
    end;

    local procedure ImportMembers()
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        ImportMembersCU: Codeunit "NPR MM Import Members";
    begin

        CurrPage.SetSelectionFilter(MemberInfoCapture);
        if (MemberInfoCapture.FindSet()) then begin
            repeat
                ImportMembersCU.insertMember(MemberInfoCapture."Entry No.");
            until (MemberInfoCapture.Next() = 0);
        end;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        RequiredFields: Boolean;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberInfoCapturePage: Page "NPR MM Member Info Capture";
    begin
        if (CloseAction = ACTION::LookupOK) then begin
            if (Rec."Receipt No." <> '') then begin
                Rec.Modify();
                MemberInfoCapture.SetFilter("Receipt No.", '=%1', Rec."Receipt No.");
                MemberInfoCapture.SetFilter("Line No.", '=%1', Rec."Line No.");
                RequiredFields := true;
                if (MemberInfoCapture.FindSet()) then begin
                    repeat
                        RequiredFields := MemberInfoCapturePage.HaveRequiredFields(MemberInfoCapture);
                    until (MemberInfoCapture.Next() = 0) or (not RequiredFields);
                end;
                exit(RequiredFields);
            end else
                exit(MemberInfoCapturePage.HaveRequiredFields(Rec));
        end;
    end;

}