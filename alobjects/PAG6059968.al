page 6059968 "MPOS App Setup Card"
{
    // NPR5.33/NPKNAV/20170630  CASE 267203 Transport NPR5.33 - 30 June 2017
    // NPR5.34/CLVA/20170703 CASE 280444 Upgrading MPOS functionality to transcendence
    // NPR5.36/MMV /20170926 CASE 291652 Added quickfix field 1000
    // NPR5.38/CLVA/20171011 CASE 289636 Added fields "Receipt Report ID" and "Receipt Report Caption"
    // NPR5.39/BR  /20180214 CASE 304312 Added Group "Receipts"
    // NPR5.51/JAKUBV/20190904  CASE 364011 Transport NPR5.51 - 3 September 2019
    // NPR5.54/TJ  /20200303 CASE 393290 Removed group Receipts with all the fields

    Caption = 'MPOS App Setup Card';
    SourceTable = "MPOS App Setup";
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
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                }
                field("Web Service Is Published"; "Web Service Is Published")
                {
                    ApplicationArea = All;
                }
                field("Custom Web Service URL"; "Custom Web Service URL")
                {
                    ApplicationArea = All;
                }
            }
            group(Payment)
            {
                Caption = 'Payment';
                field("Handle EFT Print in NAV"; "Handle EFT Print in NAV")
                {
                    ApplicationArea = All;
                }
                field("Payment Gateway"; "Payment Gateway")
                {
                    ApplicationArea = All;
                }
            }
            group(Admission)
            {
                Caption = 'Admission';
                field("Ticket Admission Web Url"; "Ticket Admission Web Url")
                {
                    ApplicationArea = All;
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
                RunObject = Codeunit "MPOS Webservice";

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
                RunObject = Page "MPOS QR Code List";
            }
            action(Transactions)
            {
                Caption = 'Transactions';
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    MPOSPaymentGateway: Record "MPOS Payment Gateway";
                begin

                    TestField("Payment Gateway");

                    MPOSPaymentGateway.Get("Payment Gateway");

                    case MPOSPaymentGateway.Provider of
                        MPOSPaymentGateway.Provider::ADYEN:
                            Error(NotImplimentedYetError);
                        MPOSPaymentGateway.Provider::NETS:
                            PAGE.Run(PAGE::"MPOS Nets Transactions List");
                    end;
                end;
            }
            action("EOD Receipts")
            {
                Caption = 'EOD Receipts';
                Image = List;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                RunObject = Page "MPOS EOD Receipts";
            }
        }
    }

    var
        NotImplimentedYetError: Label 'Not implimented yet';
        WebService: Record "Web Service";
}

