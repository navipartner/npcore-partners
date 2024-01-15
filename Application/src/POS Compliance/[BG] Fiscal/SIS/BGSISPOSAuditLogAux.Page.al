page 6151316 "NPR BG SIS POS Audit Log Aux."
{
    ApplicationArea = NPRBGSISFiscal;
    Caption = 'BG POS SIS Audit Log Aux. Info';
    Editable = false;
    Extensible = false;
    PageType = List;
    SourceTable = "NPR BG SIS POS Audit Log Aux.";
    SourceTableView = sorting("Audit Entry No.") order(descending);
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Audit Entry Type"; Rec."Audit Entry Type")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the Audit Entry Type.';
                }
                field("Audit Entry No."; Rec."Audit Entry No.")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the Audit Entry No.';
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the POS Entry No. related to this record.';

                    trigger OnDrillDown()
                    var
                        POSEntry: Record "NPR POS Entry";
                        POSEntryList: Page "NPR POS Entry List";
                    begin
                        if not (Rec."Audit Entry Type" in [Rec."Audit Entry Type"::"POS Entry"]) then
                            exit;

                        POSEntry.FilterGroup(2);
                        POSEntry.SetRange("Entry No.", Rec."POS Entry No.");
                        POSEntry.FilterGroup(0);
                        POSEntryList.SetTableView(POSEntry);
                        POSEntryList.Run();
                    end;
                }
                field("Entry Date"; Rec."Entry Date")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the Entry Date.';
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the POS store code from which the related record was created.';
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the POS unit number from which the related record was created.';
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the salesperson which created this record.';
                }
                field("Source Document No."; Rec."Source Document No.")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the Source Document No.';
                }
                field("Amount Incl. Tax"; Rec."Amount Incl. Tax")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the total amount including taxes for the transaction.';
                }
                field("Grand Receipt No."; Rec."Grand Receipt No.")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the Grand Receipt No. - receipt number.';
                }
                field("Receipt Timestamp"; Rec."Receipt Timestamp")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the time and date of the receipt creation in the format “ss,mm,hh;DD,MM,YY".';
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the Transaction Type.';
                }
                field("Extended Receipt"; Rec."Extended Receipt")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies whether the receipt from the related record is extended or not.';
                }
                field("Extended Receipt Counter"; Rec."Extended Receipt Counter")
                {
                    ApplicationArea = NPRBGSISFiscal;
                    ToolTip = 'Specifies the value of the Extended Receipt Counter field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ShowRequestContent)
            {
                ApplicationArea = NPRBGSISFiscal;
                Caption = 'Show Request Content';
                Image = Find;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Shows the request content related to the selected entry.';

                trigger OnAction()
                begin
                    Message(Rec.GetRequestText());
                end;
            }
            // TO-DO this will be finished in one of the future tasks
            // action(ShowReceiptData)
            // {
            //     ApplicationArea = NPRBGSISFiscal;
            //     Caption = 'Show Receipt Data';
            //     Image = Find;
            //     Promoted = true;
            //     PromotedCategory = Process;
            //     PromotedIsBig = true;
            //     PromotedOnly = true;
            //     ToolTip = 'Shows the receipt data.';

            //     trigger OnAction()
            //     begin
            //         Message(Rec.GetReceiptData());
            //     end;
            // }
        }
    }
}
