#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6185035 "NPR Inc Ecom Doc FactBox"
{
    PageType = CardPart;
    UsageCategory = None;
    SourceTable = "NPR Inc Ecom Sales Header";
    Caption = 'Incoming Ecommerce Sales Document Factbox';

    layout
    {
        area(Content)
        {
            group(processingInformation)
            {
                ShowCaption = false;
                group(General)
                {
                    Caption = 'General';
                    field("Creation Status"; Rec."Creation Status")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Creation Status field.';
                        StyleExpr = _CreationStatusStyleText;

                    }
                    field("Created Doc No"; Rec."Created Doc No.")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Created Document No. field.';
                        trigger OnDrillDown()
                        var
                            IncEcomSalesDocUtils: Codeunit "NPR Inc Ecom Sales Doc Utils";
                        begin
                            IncEcomSalesDocUtils.OpenCreatedDocumentFromEcomSalesHeader(Rec);
                        end;
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
                        ToolTip = 'Specifies the value of the Creted By User Name field.';
                    }
                    field("API Version Date"; Rec."API Version Date")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the API Version Date field.';
                    }
                    field("Requested API Version Date"; Rec."Requested API Version Date")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Requested API Version Date field.';
                    }
                }
                group("Error")
                {
                    Caption = 'Error';
                    field("Last Error Message"; Rec."Last Error Message")
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
                }
                group(Receive)
                {
                    Caption = 'Receive';
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
                    field(ReceivedByUserName; GetSystemReceivedByUserName())
                    {
                        Caption = 'Received By User Name';
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Received By User Name field.';
                    }
                }
                group(Payment)
                {
                    Caption = 'Payment';
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
                group(Sale)
                {
                    Caption = 'Sale';
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
                }
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        GetStyles(_CreationStatusStyleText, _ErrorInformationStyleText);
    end;

    local procedure GetSystemReceivedByUserName() UserName: Code[50]
    var
        User: Record User;
    begin
        User.SetLoadFields("User Name");
        if not User.Get(Rec.SystemCreatedBy) then
            exit;

        UserName := User."User Name";
    end;

    local procedure GetStyles(var CreationStatusStyleText: Text; var ErrorInformationStyleText: Text)
    var
        IncEcomSalesDocUtils: Codeunit "NPR Inc Ecom Sales Doc Utils";
    begin
        CreationStatusStyleText := IncEcomSalesDocUtils.GetIncEcomSalesHeaderCreationStatusStyle(Rec);
        ErrorInformationStyleText := IncEcomSalesDocUtils.GetIncEcomSalesHeaderErrorInformationStyle(Rec);
    end;

    var
        _CreationStatusStyleText: Text;
        _ErrorInformationStyleText: Text;
}
#endIf