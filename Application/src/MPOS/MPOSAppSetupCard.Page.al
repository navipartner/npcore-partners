page 6059968 "NPR MPOS App Setup Card"
{
    // NPR5.33/NPKNAV/20170630  CASE 267203 Transport NPR5.33 - 30 June 2017
    // NPR5.34/CLVA/20170703 CASE 280444 Upgrading MPOS functionality to transcendence
    // NPR5.36/MMV /20170926 CASE 291652 Added quickfix field 1000
    // NPR5.38/CLVA/20171011 CASE 289636 Added fields "Receipt Report ID" and "Receipt Report Caption"
    // NPR5.39/BR  /20180214 CASE 304312 Added Group "Receipts"
    // NPR5.51/JAKUBV/20190904  CASE 364011 Transport NPR5.51 - 3 September 2019
    // NPR5.54/TJ  /20200303 CASE 393290 Removed group Receipts with all the fields

    Caption = 'MPOS App Setup Card';
    SourceTable = "NPR MPOS App Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Enable; Enable)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enable field';
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Register No. field';
                }
                field("Web Service Is Published"; "Web Service Is Published")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Web Service Is Published field';
                }
                field("Custom Web Service URL"; "Custom Web Service URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Custom Web Service URL field';
                }
            }
            group(Payment)
            {
                Caption = 'Payment';
                field("Payment Gateway"; "Payment Gateway")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Gateway field';
                }
            }
            group(Admission)
            {
                Caption = 'Admission';
                field("Ticket Admission Web Url"; "Ticket Admission Web Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket Admission Web Url field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Publish Webservice")
            {
                Caption = 'Publish Webservice';
                Image = Setup;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                RunObject = Codeunit "NPR MPOS Webservice";
                ApplicationArea = All;
                ToolTip = 'Executes the Publish Webservice action';

                trigger OnAction()
                begin
                    CODEUNIT.Run(6059965);
                    if WebService.Get(WebService."Object Type"::Codeunit, 'mpos_service') then begin
                        "Receipt Web API" := GetUrl(CLIENTTYPE::SOAP);
                    end;
                end;
            }
            action("Create QR Codes")
            {
                Caption = 'Create QR Codes';
                Image = Add;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                RunObject = Page "NPR MPOS QR Code List";
                ApplicationArea = All;
                ToolTip = 'Executes the Create QR Codes action';
            }
            action(Transactions)
            {
                Caption = 'Transactions';
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Transactions action';

                trigger OnAction()
                var
                    MPOSPaymentGateway: Record "NPR MPOS Payment Gateway";
                begin

                    TestField("Payment Gateway");

                    MPOSPaymentGateway.Get("Payment Gateway");

                    case MPOSPaymentGateway.Provider of
                        MPOSPaymentGateway.Provider::ADYEN:
                            Error(NotImplimentedYetError);
                        MPOSPaymentGateway.Provider::NETS:
                            PAGE.Run(PAGE::"NPR MPOS Nets Trx List");
                    end;
                end;
            }
            action("EOD Receipts")
            {
                Caption = 'EOD Receipts';
                Image = List;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                RunObject = Page "NPR MPOS EOD Receipts";
                ApplicationArea = All;
                ToolTip = 'Executes the EOD Receipts action';
            }
        }
    }

    var
        NotImplimentedYetError: Label 'Not implimented yet';
        WebService: Record "Web Service";
}

