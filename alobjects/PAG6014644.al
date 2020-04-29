page 6014644 "Tax Free POS Units"
{
    // NPR5.30/NPKNAV/20170310  CASE 261964 Transport NPR5.30 - 26 January 2017
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    Caption = 'Tax Free POS Units';
    PageType = List;
    SourceTable = "Tax Free POS Unit";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Unit No.";"POS Unit No.")
                {
                }
                field("Handler ID";"Handler ID")
                {
                }
                field(Mode;Mode)
                {
                }
                field("Log Level";"Log Level")
                {
                }
                field("Check POS Terminal IIN";"Check POS Terminal IIN")
                {
                }
                field("Request Timeout (ms)";"Request Timeout (ms)")
                {
                }
                field("Store Voucher Prints";"Store Voucher Prints")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Set Parameters")
            {
                Caption = 'Set Parameters';
                Image = Answers;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    TaxFreeManagement: Codeunit "Tax Free Handler Mgt.";
                begin
                    //TaxFreeManagement.SetGenericHandlerParameters(Rec);
                    TaxFreeManagement.SetParameters(Rec);
                end;
            }
            action("Test Connection")
            {
                Caption = 'Test Connection';
                Image = Process;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    TaxFreeManagement: Codeunit "Tax Free Handler Mgt.";
                begin
                    TaxFreeManagement.UnitTestConnection(Rec);
                end;
            }
            action("Auto Configure")
            {
                Caption = 'Auto Configure';
                Image = TestDatabase;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    TaxFreeManagement: Codeunit "Tax Free Handler Mgt.";
                begin
                    TaxFreeManagement.UnitAutoConfigure(Rec, false);
                end;
            }
            action("View Log")
            {
                Caption = 'View Log';
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Tax Free Requests";
                RunPageLink = "POS Unit No."=FIELD("POS Unit No.");
            }
        }
    }
}

