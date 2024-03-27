#if not BC17
page 6184561 "NPR Spfy C&C Orders"
{
    Extensible = false;
    ApplicationArea = NPRShopify;
    Caption = 'Shopify CC Orders';
    PageType = List;
    SourceTable = "NPR Spfy C&C Order";
    UsageCategory = Lists;
    InsertAllowed = false;
    PromotedActionCategories = 'Manage,Process,Report,Navigate';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Order ID"; Rec."Order ID")
                {
                    ToolTip = 'Specifies the value of the Order ID field.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                }
                field("Shopify Store Code"; Rec."Shopify Store Code")
                {
                    ToolTip = 'Specifies the value of the Shopify Store Code field.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                }
                field("Collect in Store Shopify ID"; Rec."Collect in Store Shopify ID")
                {
                    ToolTip = 'Specifies the value of the Collect in Store Shopify ID field.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                }
                field("Collect in Store Code"; Rec."Collect in Store Code")
                {
                    ToolTip = 'Specifies the value of the Shopify Store Code field.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                    Editable = false;
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ToolTip = 'Specifies the value of the Customer Name field.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                }
                field("Customer E-Mail"; Rec."Customer E-Mail")
                {
                    ToolTip = 'Specifies the value of the Customer Email field.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                }
                field("Customer Phone No."; Rec."Customer Phone No.")
                {
                    ToolTip = 'Specifies the value of the Customer Phone No. field.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the value of the Currency Code field.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.';
                    ApplicationArea = NPRShopify;
                }
                field("Received from Shopify at"; Rec."Received from Shopify at")
                {
                    ToolTip = 'Specifies the value of the Received from Shopify at field.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                }
                field("C&C Order Created at"; Rec."C&C Order Created at")
                {
                    ToolTip = 'Specifies the value of the C&C Order Created at field.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                }
                field(LastErrorMessage; LastErrorMessage)
                {
                    Caption = 'Last Error Message';
                    ToolTip = 'Specifies the error message text, if the import process failed.';
                    ApplicationArea = NPRShopify;
                    Editable = false;

                    trigger OnAssistEdit()
                    begin
                        Rec.TestField(Status, Rec.Status::Error);
                        Rec.GetErrorMessage();
                    end;
                }
            }
        }
        area(factboxes)
        {
            part(OrderLines; "NPR Spfy C&C Ord.Lines FactBox")
            {
                ApplicationArea = NPRShopify;
                Editable = false;
                SubPageLink = "Order ID" = field("Order ID");
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
                ToolTip = 'Shows the error message text, if the import process has failed for the record.';
                ApplicationArea = NPRShopify;
                Image = PrevErrorMessage;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    Rec.TestField(Status, Rec.Status::Error);
                    Message(Rec.GetErrorMessage());
                end;
            }
            action(ReprocessSelectedFailedUpdates)
            {
                Caption = 'Reprocess Selected';
                ToolTip = 'Executes another attempt to process selected records on the page.';
                ApplicationArea = NPRShopify;
                Image = NegativeLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    CCOrder: Record "NPR Spfy C&C Order";
                    SpfyCCOrderImport: Codeunit "NPR Spfy C&C Order - Import";
                begin
                    CurrPage.SetSelectionFilter(CCOrder);
                    SpfyCCOrderImport.ImportBatch(CCOrder, true);
                    CurrPage.Update(false);
                end;
            }
        }
        area(Navigation)
        {
            action(OpenMember)
            {
                Caption = 'Document';
                ToolTip = 'Open related document.';
                ApplicationArea = NPRShopify;
                Image = Documents;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedOnly = true;

                trigger OnAction()
                var
                    TempShopifyAssignedID: Record "NPR Spfy Assigned ID" temporary;
                    SpfyCCOrderHandler: Codeunit "NPR Spfy C&C Order Handler";
                begin
                    SpfyCCOrderHandler.FindRelatedDocs(Rec, false, TempShopifyAssignedID);
                    Page.RunModal(Page::"NPR Spfy Assigned IDs", TempShopifyAssignedID);
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
#endif