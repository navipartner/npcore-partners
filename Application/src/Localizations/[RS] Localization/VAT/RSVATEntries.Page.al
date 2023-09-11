page 6151115 "NPR RS VAT Entries"
{
    Extensible = false;
    Caption = 'RS VAT Entries';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    Permissions = TableData "VAT Entry" = m;
    SourceTable = "NPR RS VAT Entry";
    UsageCategory = History;
    ApplicationArea = NPRRSLocal;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the number of the entry, as assigned from the specified number series when the entry was created.';
                    ApplicationArea = NPRRSLocal;
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ToolTip = 'Specifies the vendor''s or customer''s trade type to link transactions made for this business partner with the appropriate general ledger account according to the general posting setup.';
                    Visible = false;
                    ApplicationArea = NPRRSLocal;
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ToolTip = 'Specifies the item''s product type to link transactions made for this item with the appropriate general ledger account according to the general posting setup.';
                    Visible = false;
                    ApplicationArea = NPRRSLocal;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ToolTip = 'Specifies the VAT specification of the involved customer or vendor to link transactions made for this record with the appropriate general ledger account according to the VAT posting setup.';
                    ApplicationArea = NPRRSLocal;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ToolTip = 'Specifies the VAT specification of the involved item or resource to link transactions made for this record with the appropriate general ledger account according to the VAT posting setup.';
                    ApplicationArea = NPRRSLocal;
                }
                field("VAT Report Mapping"; Rec."VAT Report Mapping")
                {
                    ToolTip = 'Specifies the value of the VAT Report Mapping field.';
                    ApplicationArea = NPRRSLocal;
                }
                field("VAT Reporting Date"; Rec."VAT Reporting Date")
                {
                    ToolTip = 'Specifies the VAT date on the VAT entry. This is either the date that the document was created or posted, depending on your setting on the General Ledger Setup page.';
                    Editable = IsVATDateEditable;
                    Visible = IsVATDateEnabled;
                    ApplicationArea = NPRRSLocal;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the VAT entry''s posting date.';
                    ApplicationArea = NPRRSLocal;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ToolTip = 'Specifies the date when the related document was created.';
                    Visible = false;
                    ApplicationArea = NPRRSLocal;
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the document number on the VAT entry.';
                    ApplicationArea = NPRRSLocal;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the document type that the VAT entry belongs to.';
                    ApplicationArea = NPRRSLocal;
                }
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies the type of the VAT entry.';
                    ApplicationArea = NPRRSLocal;
                }
                field(Base; Rec.Base)
                {
                    ToolTip = 'Specifies the amount that the VAT amount (the amount shown in the Amount field) is calculated from.';
                    ApplicationArea = NPRRSLocal;
                }
                field("VAT Base Full VAT"; Rec."VAT Base Full VAT")
                {
                    ToolTip = 'Specifies the value of the VAT Base Full VAT field.';
                    ApplicationArea = NPRRSLocal;
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the amount of the VAT entry in LCY.';
                    ApplicationArea = NPRRSLocal;
                }
                field("Non-Deductible VAT Amount"; Rec."Non-Deductible VAT Amount")
                {
                    ToolTip = 'Specifies the value of the Non-Deductible VAT Amount field.';
                    ApplicationArea = NPRRSLocal;
                }
                field("Non-Deductible VAT Base"; Rec."Non-Deductible VAT Base")
                {
                    ToolTip = 'Specifies the value of the Non-Deductible VAT Base field.';
                    ApplicationArea = NPRRSLocal;
                }
                field("Unrealized Amount"; Rec."Unrealized Amount")
                {
                    ToolTip = 'Specifies the unrealized VAT amount for this line if you use unrealized VAT.';
                    Visible = IsUnrealizedVATEnabled;
                    ApplicationArea = NPRRSLocal;
                }
                field("Unrealized Base"; Rec."Unrealized Base")
                {
                    ToolTip = 'Specifies the unrealized base amount if you use unrealized VAT.';
                    Visible = IsUnrealizedVATEnabled;
                    ApplicationArea = NPRRSLocal;
                }

                field("Remaining Unrealized Amount"; Rec."Remaining Unrealized Amount")
                {
                    ToolTip = 'Specifies the amount that remains unrealized in the VAT entry.';
                    Visible = IsUnrealizedVATEnabled;
                    ApplicationArea = NPRRSLocal;
                }
                field("Remaining Unrealized Base"; Rec."Remaining Unrealized Base")
                {
                    ToolTip = 'Specifies the amount of base that remains unrealized in the VAT entry.';
                    Visible = IsUnrealizedVATEnabled;
                    ApplicationArea = NPRRSLocal;
                }
                field("VAT Calculation Type"; Rec."VAT Calculation Type")
                {
                    ToolTip = 'Specifies how VAT will be calculated for purchases or sales of items with this particular combination of VAT business posting group and VAT product posting group.';
                    ApplicationArea = NPRRSLocal;
                }
                field("Bill-to/Pay-to No."; Rec."Bill-to/Pay-to No.")
                {
                    ToolTip = 'Specifies the number of the bill-to customer or pay-to vendor that the entry is linked to.';
                    ApplicationArea = NPRRSLocal;
                }
                field("VAT Registration No."; Rec."VAT Registration No.")
                {
                    ToolTip = 'Specifies the VAT registration number of the customer or vendor that the entry is linked to.';
                    Visible = false;
                    ApplicationArea = NPRRSLocal;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ToolTip = 'Specifies the country/region of the address.';
                    ApplicationArea = NPRRSLocal;
                }
                field(Prepayment; Rec.Prepayment)
                {
                    ToolTip = 'Specifies the value of the Prepayment field.';
                    ApplicationArea = NPRRSLocal;
                }
                field(Closed; Rec.Closed)
                {
                    ToolTip = 'Specifies whether the VAT entry has been closed by the Calc. and Post VAT Settlement batch job.';
                    ApplicationArea = NPRRSLocal;
                }
                field("Closed by Entry No."; Rec."Closed by Entry No.")
                {
                    ToolTip = 'Specifies the number of the VAT entry that has closed the entry, if the VAT entry was closed with the Calc. and Post VAT Settlement batch job.';
                    ApplicationArea = NPRRSLocal;
                }
                field(Reversed; Rec.Reversed)
                {
                    ToolTip = 'Specifies if the entry has been part of a reverse transaction.';
                    Visible = false;
                    ApplicationArea = NPRRSLocal;
                }
                field("Reversed by Entry No."; Rec."Reversed by Entry No.")
                {
                    ToolTip = 'Specifies the number of the correcting entry. If the field Specifies a number, the entry cannot be reversed again.';
                    Visible = false;
                    ApplicationArea = NPRRSLocal;
                }
                field("Reversed Entry No."; Rec."Reversed Entry No.")
                {
                    ToolTip = 'Specifies the number of the original entry that was undone by the reverse transaction.';
                    Visible = false;
                    ApplicationArea = NPRRSLocal;
                }
            }
        }

    }
    actions
    {
        area(processing)
        {
            action("&Navigate")
            {
                Caption = 'Find entries...';
                Image = Navigate;
                ShortCutKey = 'Ctrl+Alt+Q';
                ToolTip = 'Find entries and documents that exist for the document number and posting date on the selected document. (Formerly this action was named Navigate.)';
                ApplicationArea = NPRRSLocal;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    Navigate.SetDoc(Rec."Posting Date", Rec."Document No.");
                    Navigate.Run();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22)
        VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";
#ENDIF
    begin
        if GeneralLedgerSetup.Get() then
            IsUnrealizedVATEnabled := GeneralLedgerSetup."Unrealized VAT" or GeneralLedgerSetup."Prepayment Unrealized VAT";
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22)
        IsVATDateEditable := VATReportingDateMgt.IsVATDateModifiable();
        IsVATDateEnabled := VATReportingDateMgt.IsVATDateEnabled();
#ELSE
        IsVATDateEditable := false;
        IsVATDateEnabled := false;
#ENDIF

    end;

    var
        IsUnrealizedVATEnabled: Boolean;
        IsVATDateEditable: Boolean;
        IsVATDateEnabled: Boolean;
}
