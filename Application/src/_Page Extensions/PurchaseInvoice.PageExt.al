pageextension 6014454 "NPR Purchase Invoice" extends "Purchase Invoice"
{
    layout
    {
        addafter(Status)
        {
            field("NPR PostingDescription"; "Posting Description")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Posting Description field';
            }
        }
        addafter(Control1906949207)
        {
            part("NPR NPAttributes"; "NPR NP Attributes FactBox")
            {
                Provider = PurchLines;
                SubPageLink = "No." = FIELD("No.");
                ApplicationArea = All;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Show Imported File action';
                Image = View; 

                trigger OnAction()
                var
                    NcImportListPg: Page "NPR Nc Import List";
                begin
                    NcImportListPg.ShowFormattedDocByDocNo("Vendor Invoice No.");
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the Retail Print action';
                }
                action("NPR PriceLabel")
                {
                    Caption = 'Price Label';
                    Image = BinContent;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Price Label action';
                }
            }
        }
    }
}