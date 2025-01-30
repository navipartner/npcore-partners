#if not BC17
page 6184936 "NPR Spfy App Requests"
{
    Extensible = false;
    ApplicationArea = NPRShopify;
    Caption = 'Shopify App Requests';
    PageType = List;
    SourceTable = "NPR Spfy App Request";
    SourceTableView = order(descending);
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the number of the Shopify app request entry, as assigned from the specified number series when the entry was created.';
                    ApplicationArea = NPRShopify;
                }
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies the Shopify app request type.';
                    ApplicationArea = NPRShopify;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'Received at';
                    ToolTip = 'Specifies the date and time when the Shopify app request was received in Business Central.';
                    ApplicationArea = NPRShopify;
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the processing status of the Shopify app request entry in BC.';
                    ApplicationArea = NPRShopify;
                }
                field("Processed at"; Rec."Processed at")
                {
                    ToolTip = 'Specifies the date and time when the Shopify app request entry was successfully processed in BC.';
                    ApplicationArea = NPRShopify;
                }
            }
        }
        area(factboxes)
        {
            part(RequestPayload; "NPR Spfy App Request FactBox")
            {
                ApplicationArea = NPRShopify;
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
                ToolTip = 'Shows the error message raised by the Shopify app request processing (if the process has failed).';
                Image = PrevErrorMessage;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ApplicationArea = NPRShopify;

                trigger OnAction()
                begin
                    Rec.TestField(Status, Rec.Status::Error);
                    Message(Rec.GetErrorMessage());
                end;
            }
            action(ShowRelated)
            {
                Caption = 'Show Related';
                ToolTip = 'Navigates to the related record in Business Central.';
                Image = ViewSourceDocumentLine;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ApplicationArea = NPRShopify;

                trigger OnAction()
                var
                    SpfyAppRequestIHndlr: Interface "NPR Spfy App Request IHndlr";
                begin
                    SpfyAppRequestIHndlr := Rec.Type;
                    SpfyAppRequestIHndlr.NavigateToRelatedBCEntity(Rec);
                end;
            }
        }
    }
}
#endif