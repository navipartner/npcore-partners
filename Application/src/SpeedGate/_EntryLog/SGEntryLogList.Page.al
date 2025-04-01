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

                field(ReferenceNumberType; Rec.ReferenceNumberType)
                {
                    ToolTip = 'Specifies the value of the Entry Type field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(SubType; _SubType)
                {
                    ToolTip = 'Specifies the value of the Subtype field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                    Caption = 'Subtype';
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
                field(AdmittedReferenceNo; Rec.AdmittedReferenceNo)
                {
                    ToolTip = 'Specifies the value of the Admitted Reference No field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(ScannerId; Rec.ScannerId)
                {
                    ToolTip = 'Specifies the value of the Scanner Id field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
                field(ScannerDescription; Rec.ScannerDescription)
                {
                    ToolTip = 'Specifies the value of the Scanner Description field.', Comment = '%';
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
                field(ApiErrorNumber; Rec.ApiErrorNumber)
                {
                    ToolTip = 'Specifies the value of the Api Error Number field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field(EntityId; Rec.EntityId)
                {
                    ToolTip = 'Specifies the value of the Entity Id field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field(ExtraEntityId; Rec.ExtraEntityId)
                {
                    ToolTip = 'Specifies the value of the Extra Entity Id field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field(ExtraEntityTableId; Rec.ExtraEntityTableId)
                {
                    ToolTip = 'Specifies the value of the Extra Entity Table Id field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field(ApiErrorMessage; Rec.ApiErrorMessage)
                {
                    ToolTip = 'Specifies the value of the Api Error Message field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field(MemberCardLogEntryNo; Rec.MemberCardLogEntryNo)
                {
                    ToolTip = 'Specifies the value of the Member Card Log Entry No field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field(ProfileLineId; Rec.ProfileLineId)
                {
                    ToolTip = 'Specifies the value of the Profile Line Id field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Scanned)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Reference No';
                ToolTip = 'Navigate to Reference No';
                Image = Navigate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                Scope = Repeater;
                trigger OnAction()
                var
                    Ticket: Record "NPR TM Ticket";
                    MemberCard: Record "NPR MM Member Card";
                    TicketRequest: Record "NPR TM Ticket Reservation Req.";
                    Wallet: Record "NPR AttractionWallet";
                    WalletPage: Page "NPR AttractionWallet";
                    DocLXCityCard: Record "NPR DocLXCityCardHistory";
                begin

                    case Rec.ReferenceNumberType of
                        Rec.ReferenceNumberType::Ticket:
                            begin
                                Ticket.Reset();
                                Ticket.SetCurrentKey("External Ticket No.");
                                Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(Rec.ReferenceNo, 1, MaxStrLen(Ticket."External Ticket No.")));
                                Page.Run(Page::"NPR TM Ticket List", Ticket);
                            end;
                        Rec.ReferenceNumberType::MEMBER_CARD:
                            begin
                                MemberCard.Reset();
                                MemberCard.SetCurrentKey("External Card No.");
                                MemberCard.SetFilter("External Card No.", '=%1', CopyStr(Rec.ReferenceNo, 1, MaxStrLen(MemberCard."External Card No.")));
                                Page.Run(Page::"NPR MM Member Card List", MemberCard);
                            end;

                        Rec.ReferenceNumberType::TICKET_REQUEST:
                            begin
                                TicketRequest.Reset();
                                TicketRequest.SetCurrentKey("Session Token ID");
                                TicketRequest.SetFilter("Session Token ID", '=%1', CopyStr(Rec.ReferenceNo, 1, MaxStrLen(TicketRequest."Session Token ID")));
                                Page.Run(Page::"NPR TM Ticket Request", TicketRequest);
                            end;
                        Rec.ReferenceNumberType::WALLET:
                            begin
                                WalletPage.SetSearch(CopyStr(Rec.ReferenceNo, 1, MaxStrLen(Wallet.ReferenceNumber)));
                                WalletPage.Run();
                            end;

                        Rec.ReferenceNumberType::DOC_LX_CITY_CARD:
                            begin
                                DocLXCityCard.Reset();
                                DocLXCityCard.SetCurrentKey(CardNumber);
                                DocLXCityCard.SetFilter(CardNumber, '=%1', CopyStr(Rec.ReferenceNo, 1, MaxStrLen(DocLXCityCard.CardNumber)));
                                Page.Run(Page::"NPR DocLXCityCardHistoryList", DocLXCityCard);
                            end;
                    end;

                end;
            }

            action(Admitted)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Admitted';
                ToolTip = 'Navigate to Admitted Ticket';
                Image = Navigate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                Scope = Repeater;

                trigger OnAction()
                var
                    Ticket: Record "NPR TM Ticket";
                begin
                    if (Rec.AdmittedReferenceNo = '') then
                        exit;

                    Ticket.Reset();
                    Ticket.SetCurrentKey("External Ticket No.");
                    Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(Rec.AdmittedReferenceNo, 1, MaxStrLen(Ticket."External Ticket No.")));
                    Page.Run(Page::"NPR TM Ticket List", Ticket);
                end;
            }
        }
    }
    var
        _ErrorMessage: Text;
        _SubType: Text;

    trigger OnAfterGetRecord()
    var
        ApiError: Enum "NPR API Error Code";
        GuestLbl: Label 'Guest';
        MemberLbl: Label 'Member Card';
        CardholderLbl: Label 'Cardholder';
        TicketLbl: Label 'Ticket';
    begin
        _ErrorMessage := Rec.ApiErrorMessage;

        if (_ErrorMessage = '') then
            if (Rec.ApiErrorNumber <> 0) then begin
                ApiError := Enum::"NPR API Error Code".FromInteger(Rec.ApiErrorNumber);
                _ErrorMessage := Format(ApiError, 0, 1)
            end;

        _SubType := '';
        case Rec.ExtraEntityTableId of
            6060135:
                _SubType := GuestLbl;
            6060131:
                _SubType := MemberLbl;
            6059785:
                case Rec.ReferenceNumberType of
                    Rec.ReferenceNumberType::MEMBER_CARD:
                        _SubType := CardholderLbl
                    else
                        _SubType := TicketLbl;
                end;
            else
                if (Rec.ReferenceNumberType = Rec.ReferenceNumberType::MEMBER_CARD) then
                    _SubType := CardholderLbl;
        end;
    end;
}