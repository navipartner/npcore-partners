pageextension 6014454 "NPR Purchase Invoice" extends "Purchase Invoice"
{
    layout
    {
        addlast(General)
        {
            field("NPR Prepayment"; RSPurchaseHeader."Prepayment")
            {
                ApplicationArea = NPRRSLocal;
                Caption = 'Prepayment';
                ToolTip = 'Specifies the value of the Prepayment field.';
                trigger OnValidate()
                begin
                    RSPurchaseHeader.Validate(Prepayment);
                    RSPurchaseHeader.Save();
                end;
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
                ObsoleteState = Pending;
                ObsoleteTag = '2023-06-28';
                ObsoleteReason = 'Field XML Stylesheet is not used anymore.';
                Visible = false;

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
                        LabelManagement: Codeunit "NPR Label Management";
                    begin
                        LabelManagement.ChooseLabel(Rec);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        RSPurchaseHeader.Read(Rec.SystemId);
    end;

    var
        RSPurchaseHeader: Record "NPR RS Purchase Header";
}
