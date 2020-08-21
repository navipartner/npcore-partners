page 6150653 "POS Sale Line Subpage"
{
    // NPR5.36/BR  /20170808  CASE 277096 Object created
    // NPR5.37/BR  /20171016  CASE 293227 Added field "Line Discount Amount Excl. VAT"
    // NPR5.38/BR  /20171108  CASE 294747 Added Action fdf
    // NPR5.41/TS  /20180425  CASE 312786 Added Field Variant Code as Additional
    // NPR5.44/MHA /20180705  CASE 321231 Addied fields "Discount Authorised by","Reason Code"
    // NPR5.46/TS  /20180918  CASE 302819 Added Fields Bin Code,Lot No.,Return Reason Code,Discount Type and Discount Code
    // NPR5.48/TJ  /20190122  CASE 335967 Added field "Unit of Measure Code"
    // NPR5.50/MMV /20190328  CASE 300557 Refactored sales doc. handling
    // NPR5.51/MHA /20190718  CASE 362329 Added field 500 "Exclude from Posting"
    // NPR5.54/YAHA/20200218  CASE 391363 Removed Button New & Delete Line

    Caption = 'POS Sale Line Subpage';
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "POS Sales Line";
    SourceTableView = ORDER(Descending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                }
                field("Line Discount %"; "Line Discount %")
                {
                    ApplicationArea = All;
                }
                field("Line Discount Amount Excl. VAT"; "Line Discount Amount Excl. VAT")
                {
                    ApplicationArea = All;
                }
                field("Amount Excl. VAT"; "Amount Excl. VAT")
                {
                    ApplicationArea = All;
                }
                field("Amount Incl. VAT"; "Amount Incl. VAT")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                field("Discount Authorised by"; "Discount Authorised by")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Bin Code"; "Bin Code")
                {
                    ApplicationArea = All;
                    Importance = Standard;
                    Visible = false;
                }
                field("Discount Type"; "Discount Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Discount Code"; "Discount Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Return Reason Code"; "Return Reason Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(LastPostedSalesDocNo; LastPostedSalesDocNo)
                {
                    ApplicationArea = All;
                    Caption = 'Last Posted Sales Doc.';

                    trigger OnDrillDown()
                    var
                        POSEntrySalesDocLink: Record "POS Entry Sales Doc. Link";
                        RecordVariant: Variant;
                    begin
                        //-NPR5.50 [300557]
                        if TryGetLastPostedSalesDoc(POSEntrySalesDocLink) then begin
                            POSEntrySalesDocLink.GetDocumentRecord(RecordVariant);
                            PAGE.RunModal(POSEntrySalesDocLink.GetCardpageID(), RecordVariant);
                        end;
                        //+NPR5.50 [300557]
                    end;
                }
                field("Exclude from Posting"; "Exclude from Posting")
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
            action(ShowDimensions)
            {
                Caption = 'Dimensions';
                Image = Dimensions;

                trigger OnAction()
                begin
                    //-NPR5.38 [294717]
                    ShowDimensions;
                    //+NPR5.38 [294717]
                end;
            }
            action("Related Sales Documents")
            {
                Caption = 'Related Sales Documents';
                Image = CoupledOrder;

                trigger OnAction()
                var
                    POSEntrySalesDocLink: Record "POS Entry Sales Doc. Link";
                begin
                    //-NPR5.50 [300557]
                    POSEntrySalesDocLink.SetRange("POS Entry No.", "POS Entry No.");
                    POSEntrySalesDocLink.SetRange("POS Entry Reference Type", POSEntrySalesDocLink."POS Entry Reference Type"::SALESLINE);
                    POSEntrySalesDocLink.SetRange("POS Entry Reference Line No.", "Line No.");
                    PAGE.RunModal(PAGE::"POS Entry Related Sales Doc.", POSEntrySalesDocLink);
                    //+NPR5.50 [300557]
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        POSEntrySalesDocLink: Record "POS Entry Sales Doc. Link";
    begin
        //-NPR5.50 [300557]
        LastPostedSalesDocNo := '';
        if TryGetLastPostedSalesDoc(POSEntrySalesDocLink) then
            LastPostedSalesDocNo := POSEntrySalesDocLink."Sales Document No";
        //+NPR5.50 [300557]
    end;

    var
        LastPostedSalesDocNo: Code[20];

    local procedure TryGetLastPostedSalesDoc(var POSEntrySalesDocLinkOut: Record "POS Entry Sales Doc. Link"): Boolean
    begin
        //-NPR5.50 [300557]
        POSEntrySalesDocLinkOut.SetRange("POS Entry No.", "POS Entry No.");
        POSEntrySalesDocLinkOut.SetRange("POS Entry Reference Type", POSEntrySalesDocLinkOut."POS Entry Reference Type"::SALESLINE);
        POSEntrySalesDocLinkOut.SetRange("POS Entry Reference Line No.", "Line No.");
        POSEntrySalesDocLinkOut.SetFilter("Sales Document Type", '%1|%2',
                                          POSEntrySalesDocLinkOut."Sales Document Type"::POSTED_INVOICE,
                                          POSEntrySalesDocLinkOut."Sales Document Type"::POSTED_CREDIT_MEMO);
        exit(POSEntrySalesDocLinkOut.FindLast);
        //+NPR5.50 [300557]
    end;
}

