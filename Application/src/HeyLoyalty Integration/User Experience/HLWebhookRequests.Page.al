page 6150801 "NPR HL Webhook Requests"
{
    Extensible = false;
    Caption = 'HeyLoyalty Webhook Requests';
    PageType = List;
    SourceTable = "NPR HL Webhook Request";
    InsertAllowed = false;
    UsageCategory = History;
    ApplicationArea = NPRHeyLoyalty;
    PromotedActionCategories = 'Manage,Process,Report,Navigate';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("HL Member ID"; Rec."HL Member ID")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies HeyLoyalty member Id.';
                    Editable = false;
                }
                field("HL List ID"; Rec."HL List ID")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies HeyLoyalty list Id.';
                    Editable = false;
                }
                field("HL Reference ID"; Rec."HL Reference ID")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies HeyLoyalty reference Id.';
                    Editable = false;
                    Visible = false;
                }
                field("HL Message Type"; Rec."HL Message Type")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies HeyLoyalty message type.';
                    Editable = false;
                }
                field("HL Request Type"; Rec."HL Request Type")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies HeyLoyalty request type.';
                    Editable = false;
                }
                field("HL Queued at"; Rec."HL Queued at")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies the date time the request has been scheduled at HeyLoyalty.';
                    Visible = false;
                    Editable = false;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies the date time the request has been received in BC.';
                    Editable = false;
                }
                field("Processing Status"; Rec."Processing Status")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies the processing status of the request in BC.';
                }
                field("Processed at"; Rec."Processed at")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies the date time the request has been processed in BC.';
                    Editable = false;
                }
                field(LastErrorMessage; LastErrorMessage)
                {
                    Caption = 'Last Error Message';
                    ToolTip = 'Specifies the error message, raised by the request import process (in cases, when the process has failed).';
                    ApplicationArea = NPRHeyLoyalty;
                    Editable = false;

                    trigger OnAssistEdit()
                    begin
                        Rec.TestField("Processing Status", Rec."Processing Status"::Error);
                        Message(Rec.GetErrorMessage());
                    end;
                }
                field(SystemId; Rec.SystemId)
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies the entry SystemID (assigned by BC).';
                    Editable = false;
                    Visible = false;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies an internal entry number assigned by BC for the webhook request when it was created.';
                    Editable = false;
                }
            }
        }
        area(factboxes)
        {
            part(HLRequestData; "NPR HL Webhook Request FactBox")
            {
                ApplicationArea = NPRHeyLoyalty;
                Editable = false;
                SubPageLink = "Entry No." = field("Entry No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ShowErrorMessage)
            {
                Caption = 'Show Error';
                ToolTip = 'Shows the error message, raised by the request import process (in cases, when the process has failed).';
                Image = PrevErrorMessage;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ApplicationArea = NPRHeyLoyalty;

                trigger OnAction()
                begin
                    Rec.TestField("Processing Status", Rec."Processing Status"::Error);
                    Message(Rec.GetErrorMessage());
                end;
            }
            action(ReprocessSelectedFailedUpdates)
            {
                Caption = 'Reprocess Selected';
                ToolTip = 'Executes another attempt to process selected records on the page.';
                Image = NegativeLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ApplicationArea = NPRHeyLoyalty;

                trigger OnAction()
                var
                    HLWebhookRequest: Record "NPR HL Webhook Request";
                    HLWebhookRequestMgt: Codeunit "NPR HL Webhook Request Mgt.";
                begin
                    CurrPage.SetSelectionFilter(HLWebhookRequest);
                    HLWebhookRequestMgt.ProcessWebhookRequests(HLWebhookRequest, true);
                    CurrPage.Update(false);
                end;
            }
        }
        area(Navigation)
        {
            action(OpenMember)
            {
                Caption = 'HL Member';
                ToolTip = 'Opens related HeyLoyalty member entry in BC.';
                Image = CoupledCustomer;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedOnly = true;
                ApplicationArea = NPRHeyLoyalty;

                trigger OnAction()
                var
                    HLMember: Record "NPR HL HeyLoyalty Member";
                begin
                    Rec.TestField("HL Member ID");
                    HLMember.SetCurrentKey("HeyLoyalty Id");
                    HLMember.SetRange("HeyLoyalty Id", Rec."HL Member ID");
                    Page.Run(0, HLMember);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        LastErrorMessage := Rec.GetErrorMessage();
    end;

    var
        LastErrorMessage: Text;
}