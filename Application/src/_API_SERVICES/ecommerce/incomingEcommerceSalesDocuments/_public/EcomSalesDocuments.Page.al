#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6248189 "NPR Ecom Sales Documents"
{
    PageType = list;
    ApplicationArea = NPRRetail;
    UsageCategory = Lists;
    SourceTable = "NPR Ecom Sales Header";
    Editable = false;
    Caption = 'Ecommerce Sales Documents';
    SourceTableView = sorting(systemCreatedAt) order(descending);
    InsertAllowed = false;
    ModifyAllowed = false;
    CardPageId = "NPR Ecom Sales Document";
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External No."; Rec."External No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the External No. field.';

                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Document Type field.';
                }
                field("Sell-to Name"; Rec."Sell-to Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Sell-to Name field.';
                }
                field("Location Code."; Rec."Location Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Location Code field.';
                }
                field(ReceivedDate; Rec."Received Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Received Date field.';
                }
                field(ReceivedTime; Rec."Received Time")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Received Time field.';
                }
                field("Virtual Items Exist"; Rec."Virtual Items Exist")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Virtual Items Exist field.';
                }
                field("Virtual Items Proccess Status"; Rec."Virtual Items Process Status")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Virtual Item Processing Status field.';
                }
                field("Capture Processing Status"; Rec."Capture Processing Status")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Capture Processing Status field.';
                }
                field("Last Capture Error Message"; Rec."Last Capture Error Message")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Last Capture Error Message field.';
                    trigger OnDrillDown()
                    begin
                        Message(Rec."Last Capture Error Message");
                    end;
                }
                field("Voucher Processing Status"; Rec."Voucher Processing Status")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Voucher Processing Status field.';
                }
                field("Creation Status"; Rec."Creation Status")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Creation Status field.';
                    StyleExpr = _CreationStatusStyleText;
                }
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Created Date field.';
                }
                field("Created Time"; Rec."Created Time")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Created Time field.';
                }
                field("Created By User Name"; Rec."Created By User Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Created By User Name field.';

                }
                field("Error Message"; Rec."Last Error Message")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Error Message field.';
                    StyleExpr = _ErrorInformationStyleText;
                    trigger OnDrillDown()
                    begin
                        Message(Rec."Last Error Message");
                    end;
                }
                field("Error Date"; Rec."Last Error Date")
                {
                    ApplicationArea = NPRRetail;
                    StyleExpr = _ErrorInformationStyleText;
                    ToolTip = 'Specifies the value of the Last Error Date field.';
                }
                field("Error Time"; Rec."Last Error Time")
                {
                    ApplicationArea = NPRRetail;
                    StyleExpr = _ErrorInformationStyleText;
                    ToolTip = 'Specifies the value of the Last Error Time field.';
                }
                field("Error Received By User Name"; Rec."Last Error Rcvd By User Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Error Received By User Name field.';
                    StyleExpr = _ErrorInformationStyleText;
                }
                field("Process Retry Count"; Rec."Process Retry Count")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Process Retry Count field.';
                    StyleExpr = _ErrorInformationStyleText;
                }
                field("Price Excl. VAT"; Rec."Price Excl. VAT")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Price Excl. VAT field.';
                }
                field("Posting Status"; Rec."Posting Status")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Posting Status field.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Amount field.';
                }
                field("Invoiced Amount"; Rec."Invoiced Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Invoiced Amount field.';
                }
                field("Payment Amount"; Rec."Payment Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Payment Amount field.';
                }
                field("Captured Payment Amount"; Rec."Captured Payment Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Captured Payment Amount field.';
                }
                field("Invoiced Payment Amount"; Rec."Invoiced Payment Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Captured Payment Amount field.';
                }
            }
        }
        area(factboxes)
        {
            part(IncEcomDocFactBox; "NPR Ecom Doc FactBox")
            {
                Caption = 'Processing Information';
                ApplicationArea = NPRRetail;
                SubPageLink = "Entry No." = field("Entry No.");
                UpdatePropagation = Both;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = NPRRetail;
            }
        }
    }

    actions
    {
        area(Processing)
        {

            action(Process)
            {
                Caption = 'Process';
                ToolTip = 'Process the selected entry';
                ApplicationArea = NPRRetail;
                Image = NextRecord;
                trigger OnAction()
                var
                    EcomSalesDocConfirm: Codeunit "NPR Ecom Sales Doc Confirm";
                begin
                    EcomSalesDocConfirm.SetShowError(true);
                    EcomSalesDocConfirm.SetUpdateRetryCount(false);
                    EcomSalesDocConfirm.Run(Rec);
                end;
            }
            action(RelatedSalesDocuments)
            {
                Caption = 'Related Sales Documents';
                ToolTip = 'Open related sales documents';
                ApplicationArea = NPRRetail;
                Image = RelatedInformation;
                trigger OnAction()
                var
                    EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
                begin
                    EcomSalesDocUtils.OpenRelatedSalesDocumentsFromEcomDoc(Rec);
                end;
            }
        }
        area(Promoted)
        {
            group(Home)
            {
                actionref(Process_Promoted; Process) { }
                actionref(Sales_Documents; RelatedSalesDocuments) { }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        GetStyles(_CreationStatusStyleText, _ErrorInformationStyleText);
    end;

    local procedure GetStyles(var CreationStatusStyleText: Text; var ErrorInformationStyleText: Text)
    var
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
    begin
        CreationStatusStyleText := EcomSalesDocUtils.GetIncEcomSalesHeaderCreationStatusStyle(Rec);
        ErrorInformationStyleText := EcomSalesDocUtils.GetIncEcomSalesHeaderErrorInformationStyle(Rec);
    end;

    var
        _CreationStatusStyleText: Text;
        _ErrorInformationStyleText: Text;
}
#endIf