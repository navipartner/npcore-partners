pageextension 6014454 "NPR Purchase Invoice" extends "Purchase Invoice"
{
    layout
    {
        addafter(Status)
        {
            field("NPR PostingDescription"; Rec."Posting Description")
            {

                ToolTip = 'Specifies a posting description to appear on the resulting journal lines.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter(Control1906949207)
        {
            part("NPR NPAttributes"; "NPR NP Attributes FactBox")
            {
                Provider = PurchLines;
                SubPageLink = "No." = FIELD("No.");
                ApplicationArea = NPRRetail;

            }
        }
    }
    actions
    {
        addafter(RemoveIncomingDoc)
        {
            action("NPR Show Imported File")
            {
                Caption = 'Show Imported File';

                ToolTip = 'Executes the Show Imported File action and displays imported files.';
                Image = View;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    NcImportListPg: Page "NPR Nc Import List";
                begin
                    NcImportListPg.ShowFormattedDocByDocNo(Rec."Vendor Invoice No.");
                end;
            }
        }
        addafter("P&osting")
        {
            group("NPR Print")
            {
                Caption = 'Print';
                Image = Print;
                action("NPR RetailPrint")
                {
                    Caption = 'Retail Print';
                    Ellipsis = true;
                    Image = BinContent;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;

                    ToolTip = 'Displays the Retail Journal Print page where different labels can be printed.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        LabelLibrary: Codeunit "NPR Label Library";
                    begin
                        LabelLibrary.ChooseLabel(Rec);
                    end;
                }
            }
        }
    }
}