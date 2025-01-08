page 6184906 "NPR SG EntryLogList"
{
    Extensible = false;

    PageType = List;
    ApplicationArea = NPRRetail;
    UsageCategory = Lists;
    SourceTable = "NPR SGEntryLog";
    Caption = 'Speedgate Entry Log List';
    SourceTableView = sorting(EntryNo) order(descending);
    Editable = false;
    PromotedActionCategories = 'New,Process,Report,Navigate';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(EntryNo; Rec.EntryNo)
                {
                    ToolTip = 'Specifies the value of the EntryNo field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field(Token; Rec.Token)
                {
                    ToolTip = 'Specifies the value of the Token field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field(ReferenceNo; Rec.ReferenceNo)
                {
                    ToolTip = 'Specifies the value of the Reference No field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(EntryStatus; Rec.EntryStatus)
                {
                    ToolTip = 'Specifies the value of the Entry Status field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                    Caption = 'Attempted At';
                }
                field(AdmittedAt; Rec.AdmittedAt)
                {
                    ToolTip = 'Specifies the value of the Admitted At field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }

                field(ReferenceNumberType; Rec.ReferenceNumberType)
                {
                    ToolTip = 'Specifies the value of the Entry Type field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(ScannerId; Rec.ScannerId)
                {
                    ToolTip = 'Specifies the value of the Scanner Id field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(AdmissionCode; Rec.AdmissionCode)
                {
                    ToolTip = 'Specifies the value of the Admission Code field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(ErrorMessage; _ErrorMessage)
                {
                    Caption = 'Error Message';
                    ToolTip = 'Specifies the value of the Api Error Number field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Tickets)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Tickets';
                ToolTip = 'Navigate to Ticket List';
                Image = Navigate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                Scope = Repeater;
                trigger OnAction()
                var
                    Ticket: Record "NPR TM Ticket";
                    TempTickets: Record "NPR TM Ticket" temporary;
                begin
                    Ticket.Reset();
                    Ticket.SetCurrentKey("External Ticket No.");
                    Ticket.SetFilter("External Ticket No.", '=%1', Rec.ReferenceNo);
                    if (Ticket.FindSet()) then
                        repeat
                            TempTickets.TransferFields(Ticket, true);
                            if (not TempTickets.Insert()) then;
                        until (Ticket.Next() = 0);

                    Page.Run(Page::"NPR TM Ticket List", TempTickets);
                end;
            }

            action(MemberCard)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Member Card';
                ToolTip = 'Navigate to Member Card List';
                Image = Navigate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                Scope = Repeater;

                trigger OnAction()
                var
                    MemberCard: Record "NPR MM Member Card";
                    TempMemberCard: Record "NPR MM Member Card" temporary;
                begin
                    MemberCard.Reset();
                    MemberCard.SetCurrentKey("External Card No.");
                    MemberCard.SetFilter("External Card No.", '=%1', Rec.ReferenceNo);
                    if (MemberCard.FindSet()) then
                        repeat
                            TempMemberCard.TransferFields(MemberCard, true);
                            if (not TempMemberCard.Insert()) then;
                        until (MemberCard.Next() = 0);

                    Page.Run(Page::"NPR MM Member Card List", TempMemberCard);
                end;
            }
        }
    }
    var
        _ErrorMessage: Text;

    trigger OnAfterGetRecord()
    var
        ApiError: Enum "NPR API Error Code";
    begin
        _ErrorMessage := '';
        if (Rec.ApiErrorNumber <> 0) then begin
            ApiError := Enum::"NPR API Error Code".FromInteger(Rec.ApiErrorNumber);
            _ErrorMessage := Format(ApiError, 0, 1)
        end;
    end;
}