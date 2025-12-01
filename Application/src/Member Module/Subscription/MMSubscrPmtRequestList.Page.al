page 6248207 "NPR MM Subscr.Pmt Request List"
{
    PageType = List;
    UsageCategory = Lists;
    SourceTable = "NPR MM Subscr. Payment Request";
    SourceTableView = sorting("Entry No.") order(descending);
    Caption = 'Subscription Payment Request List';
    Extensible = false;
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("External Membership No."; Rec."External Membership No.")
                {
                    ToolTip = 'Specifies the value of the External Membership No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(PSP; Rec.PSP)
                {
                    ToolTip = 'Specifies the value of the PSP field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies the value of the Type field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Payment E-mail"; Rec."Payment E-mail")
                {
                    ToolTip = 'Specifies the value of the Payment E-mail field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Payment Phone No."; Rec."Payment Phone No.")
                {
                    ToolTip = 'Specifies the value of the Payment Phone No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the value of the Amount field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the value of the Currency Code field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("External Transaction ID"; Rec."External Transaction ID")
                {
                    ToolTip = 'Specifies the value of the External Transaction ID field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("PSP Reference"; Rec."PSP Reference")
                {
                    ToolTip = 'Specifies the value of the PSP Reference field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Payment PSP Reference"; Rec."Payment PSP Reference")
                {
                    ToolTip = 'Specifies the value of the Payment PSP Reference field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Pay by Link ID"; Rec."Pay by Link ID")
                {
                    ToolTip = 'Specifies the value of the Pay by Link field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Result Code"; Rec."Result Code")
                {
                    ToolTip = 'Specifies the value of the Refuse Reason Code field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Rejected Reason Code"; Rec."Rejected Reason Code")
                {
                    ToolTip = 'Specifies the value of the Rejected Reason Code field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Rejected Reason Description"; Rec."Rejected Reason Description")
                {
                    ToolTip = 'Specifies the value of the Rejected Reason Description field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Process Try Count"; Rec."Process Try Count")
                {
                    ToolTip = 'Specifies the value of the Process Try Count field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Pay by Link URL"; Rec."Pay by Link URL")
                {
                    ToolTip = 'Specifies the value of the Pay by Link URL field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnDrillDown()
                    begin
                        Hyperlink(Rec."Pay by Link URL");
                    end;
                }
                field("Pay By Link Expires At"; Rec."Pay By Link Expires At")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Pay By Link Expires At field.';
                }
                field(Posted; Rec.Posted)
                {
                    ToolTip = 'Specifies whether the subscription payment request has been posted to the general ledger.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Posting Document No."; Rec."Posting Document No.")
                {
                    ToolTip = 'Specifies the document number used by the posting process for the subscription payment request.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the posting date used by the posting process for the subscription payment request.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("G/L Entry No."; Rec."G/L Entry No.")
                {
                    ToolTip = 'Specifies the entry number created in the general ledger by the posting process for the subscription payment request.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Cust. Ledger Entry No."; Rec."Cust. Ledger Entry No.")
                {
                    ToolTip = 'Specifies the entry number created in the customer ledger by the posting process for the subscription payment request.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Reversed; Rec.Reversed)
                {
                    ToolTip = 'Specifies the value of the Reversed field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Reversed by Entry No."; Rec."Reversed by Entry No.")
                {
                    ToolTip = 'Specifies the value of the Reversed by Entry No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Subscr. Request Entry No."; Rec."Subscr. Request Entry No.")
                {
                    ToolTip = 'Specifies the value of the Subscription Request Entry No. field.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Reconciled; Rec.Reconciled)
                {
                    ToolTip = 'Specifies whether the subscription payment request has been reconciled.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced, NPRRetail;
                }
                field("Reconciliation Date"; Rec."Reconciliation Date")
                {
                    ToolTip = 'Specifies the date when the subscription payment request has been reconciled.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced, NPRRetail;
                }
                field("Subscription Payment Reference"; Rec."Subscription Payment Reference")
                {
                    ToolTip = 'Specifies the payment reference shown on bank statements to identify this subscription payment.';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
        area(factboxes)
        {
            part(SubsPmtRequestFactBox; "NPR MMSubscrPmtRequest FactBox")
            {
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Caption = 'Details';
                SubPageLink = "Entry No." = field("Entry No.");
                Visible = true;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Membership)
            {
                Caption = 'Membership';
                ToolTip = 'Opens membership card.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = CustomerContact;
                Scope = Repeater;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = page "NPR MM Membership Card";
                RunPageLink = "External Membership No." = field("External Membership No.");
            }
            action(Subscription)
            {
                Caption = 'Subscription';
                ToolTip = 'Opens membership subscription details.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = DueDate;
                Scope = Repeater;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    Subscription: Record "NPR MM Subscription";
                    Membership: Record "NPR MM Membership";
                begin
                    Membership.SetRange("External Membership No.", Rec."External Membership No.");
                    if Membership.FindFirst() then begin
                        Subscription.SetRange("Membership Entry No.", Membership."Entry No.");
                        Page.Run(Page::"NPR MM Subscription Details", Subscription);
                    end;
                end;
            }
            action(SubscriptionRequests)
            {
                Caption = 'Subscription Request';
                ToolTip = 'Opens subscription requests for selected membership.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = History;
                Scope = Repeater;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = page "NPR MM Subscr. Requests";
                RunPageLink = "Entry No." = field("Subscr. Request Entry No.");
            }

            action(UserAccount)
            {
                Caption = 'User Account';
                ToolTip = 'Opens the user account for selected payment subscription request.';
                Image = User;
                Scope = Repeater;
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = page "NPR UserAccounts";
                RunPageLink = EmailAddress = field("Payment E-mail");
            }
            action(LogEntries)
            {
                Caption = 'Log Entries';
                ToolTip = 'Shows the interactions for the current subscription payment request';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = Log;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                trigger OnAction()
                begin
                    OpenLogEntries()
                end;
            }

            action(FindEntries)
            {
                Caption = 'Find Entries...';
                ToolTip = 'Find the posted entries for current subscription payment request';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Image = Navigate;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                trigger OnAction()
                begin
                    FindPostedEntries();
                end;
            }
        }
    }
    local procedure FindPostedEntries()
    var
        Navigate: Page Navigate;
    begin
        Navigate.SetDoc(Rec."Posting Date", Rec."Posting Document No.");
        Navigate.Run();
    end;

    local procedure OpenLogEntries()
    var
        SubsPayReqLogUtils: Codeunit "NPR MM Subs Pay Req Log Utils";
    begin
        SubsPayReqLogUtils.OpenLogEntries(Rec);
    end;
}