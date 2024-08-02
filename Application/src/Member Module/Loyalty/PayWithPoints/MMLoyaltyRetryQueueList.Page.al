page 6184718 "NPR MM LoyaltyRetryQueueList"
{
    PageType = List;
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
    UsageCategory = Lists;
    SourceTable = "NPR MM LoyaltyRetryQueue";
    Caption = 'Loyalty Retry Queue';
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(EntryNo; Rec.EntryNo)
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(SalesTicketNo; Rec.SalesTicketNo)
                {
                    ToolTip = 'Specifies the value of the Sales Ticket No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(FailedDateTime; Rec.FailedDateTime)
                {
                    ToolTip = 'Specifies the value of the Failed Date Time field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(NextRetryDateTime; Rec.NextRetryDateTime)
                {
                    ToolTip = 'Specifies the value of the Next Retry Date Time field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(LastError; Rec.LastError)
                {
                    ToolTip = 'Specifies the value of the Last Error field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(RetryCount; Rec.RetryCount)
                {
                    ToolTip = 'Specifies the value of the Retry Count field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(SoapAction; Rec.SoapAction)
                {
                    ToolTip = 'Specifies the value of the SOAP Action field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ReattemptRequest)
            {
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Caption = 'Reattempt Request';
                ToolTip = 'This action will reattempt the request';
                Image = PostSendTo;
                Scope = Repeater;
                Promoted = false;

                trigger OnAction()
                var
                    RetryQueueMgr: Codeunit "NPR MM LoyaltyRetryQueueMgr";
                    RetryQueue: Record "NPR MM LoyaltyRetryQueue";
                begin
                    if (not (RetryQueueMgr.RetryQueueEntry(Rec.EntryNo))) then begin
                        RetryQueue.Get(Rec.EntryNo);
                        Message(RetryQueue.LastError);
                    end;
                end;
            }
            action(ReattemptAll)
            {
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Caption = 'Reattempt All Requests';
                ToolTip = 'This action will reattempt all requests';
                Image = PostSendTo;
                Scope = Page;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    RetryQueue: Codeunit "NPR MM LoyaltyRetryQueueMgr";
                begin
                    RetryQueue.Run()
                end;
            }
        }
        area(navigation)
        {
            action(EFTRequest)
            {
                Caption = 'EFT Transaction';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                ToolTip = 'This action will open the EFT Transaction';
                Image = Transactions;
                Scope = Repeater;
                Promoted = false;
                RunObject = Page "NPR EFT Transaction Requests";
                RunPageLink = "Entry No." = FIELD(EntryNo);
            }
            action(POSEntry)
            {
                Caption = 'POS Entry';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                ToolTip = 'This action will open the POS Entry';
                Image = Sales;
                Scope = Repeater;
                Promoted = false;
                RunObject = Page "NPR POS Entry List";
                RunPageLink = SystemId = FIELD(SalesId);
            }
        }
    }
}