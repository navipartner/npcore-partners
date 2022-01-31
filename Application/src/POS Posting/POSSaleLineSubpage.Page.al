page 6150653 "NPR POS Sale Line Subpage"
{
    Extensible = False;
    Caption = 'POS Sale Line Subpage';
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    ModifyAllowed = false;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR POS Entry Sales Line";
    SourceTableView = ORDER(Descending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ToolTip = 'Specifies the value of the Unit of Measure Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ToolTip = 'Specifies the value of the Location Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ToolTip = 'Specifies the value of the Unit Price field';
                    ApplicationArea = NPRRetail;
                }
                field("Line Discount %"; Rec."Line Discount %")
                {
                    ToolTip = 'Specifies the value of the Line Discount % field';
                    ApplicationArea = NPRRetail;
                }
                field("Line Discount Amount Excl. VAT"; Rec."Line Discount Amount Excl. VAT")
                {
                    ToolTip = 'Specifies the value of the Line Discount Amount Excl. VAT field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Excl. VAT"; Rec."Amount Excl. VAT")
                {
                    ToolTip = 'Specifies the value of the Amount Excl. VAT field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Incl. VAT"; Rec."Amount Incl. VAT")
                {
                    ToolTip = 'Specifies the value of the Amount Incl. VAT field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Authorised by"; Rec."Discount Authorised by")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Discount Authorised by field';
                    ApplicationArea = NPRRetail;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Reason Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    Importance = Standard;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Bin Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Type"; Rec."Discount Type")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Discount Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Code"; Rec."Discount Code")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Discount Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Lot No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Return Reason Code"; Rec."Return Reason Code")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Return Reason Code field';
                    ApplicationArea = NPRRetail;
                }
                field(LastPostedSalesDocNo; LastPostedSalesDocNo)
                {
                    Caption = 'Last Posted Sales Doc.';
                    ToolTip = 'Specifies the value of the Last Posted Sales Doc. field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    var
                        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
                        RecordVariant: Variant;
                    begin
                        if TryGetLastPostedSalesDoc(POSEntrySalesDocLink) then begin
                            POSEntrySalesDocLink.GetDocumentRecord(RecordVariant);
                            PAGE.RunModal(POSEntrySalesDocLink.GetCardpageID(), RecordVariant);
                        end;
                    end;
                }
                field("Exclude from Posting"; Rec."Exclude from Posting")
                {
                    ToolTip = 'Specifies the value of the Exclude from Posting field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ShowDimensions)
            {
                Caption = 'Dimensions';
                Image = Dimensions;

                ToolTip = 'Executes the Dimensions action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.ShowDimensions();
                end;
            }
            action("Related Sales Documents")
            {
                Caption = 'Related Sales Documents';
                Image = CoupledOrder;

                ToolTip = 'Executes the Related Sales Documents action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
                begin
                    POSEntrySalesDocLink.SetRange("POS Entry No.", Rec."POS Entry No.");
                    POSEntrySalesDocLink.SetRange("POS Entry Reference Type", POSEntrySalesDocLink."POS Entry Reference Type"::SALESLINE);
                    POSEntrySalesDocLink.SetRange("POS Entry Reference Line No.", Rec."Line No.");
                    PAGE.RunModal(PAGE::"NPR POS Entry Rel. Sales Doc.", POSEntrySalesDocLink);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
    begin
        LastPostedSalesDocNo := '';
        if TryGetLastPostedSalesDoc(POSEntrySalesDocLink) then
            LastPostedSalesDocNo := POSEntrySalesDocLink."Sales Document No";
    end;

    var
        LastPostedSalesDocNo: Code[20];

    local procedure TryGetLastPostedSalesDoc(var POSEntrySalesDocLinkOut: Record "NPR POS Entry Sales Doc. Link"): Boolean
    begin
        POSEntrySalesDocLinkOut.SetRange("POS Entry No.", Rec."POS Entry No.");
        POSEntrySalesDocLinkOut.SetRange("POS Entry Reference Type", POSEntrySalesDocLinkOut."POS Entry Reference Type"::SALESLINE);
        POSEntrySalesDocLinkOut.SetRange("POS Entry Reference Line No.", Rec."Line No.");
        POSEntrySalesDocLinkOut.SetFilter("Sales Document Type", '%1|%2',
            POSEntrySalesDocLinkOut."Sales Document Type"::POSTED_INVOICE,
            POSEntrySalesDocLinkOut."Sales Document Type"::POSTED_CREDIT_MEMO);
        exit(POSEntrySalesDocLinkOut.FindLast());
    end;
}

