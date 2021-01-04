page 6150653 "NPR POS Sale Line Subpage"
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
    UsageCategory = Administration;
    SourceTable = "NPR POS Sales Line";
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
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit of Measure Code field';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
                field("Line Discount %"; "Line Discount %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Discount % field';
                }
                field("Line Discount Amount Excl. VAT"; "Line Discount Amount Excl. VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Discount Amount Excl. VAT field';
                }
                field("Amount Excl. VAT"; "Amount Excl. VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Excl. VAT field';
                }
                field("Amount Incl. VAT"; "Amount Incl. VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Incl. VAT field';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field("Discount Authorised by"; "Discount Authorised by")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Discount Authorised by field';
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Reason Code field';
                }
                field("Bin Code"; "Bin Code")
                {
                    ApplicationArea = All;
                    Importance = Standard;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Bin Code field';
                }
                field("Discount Type"; "Discount Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Discount Type field';
                }
                field("Discount Code"; "Discount Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Discount Code field';
                }
                field("Lot No."; "Lot No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Lot No. field';
                }
                field("Return Reason Code"; "Return Reason Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Return Reason Code field';
                }
                field(LastPostedSalesDocNo; LastPostedSalesDocNo)
                {
                    ApplicationArea = All;
                    Caption = 'Last Posted Sales Doc.';
                    ToolTip = 'Specifies the value of the Last Posted Sales Doc. field';

                    trigger OnDrillDown()
                    var
                        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
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
                    ToolTip = 'Specifies the value of the Exclude from Posting field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Dimensions action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Related Sales Documents action';

                trigger OnAction()
                var
                    POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
                begin
                    //-NPR5.50 [300557]
                    POSEntrySalesDocLink.SetRange("POS Entry No.", "POS Entry No.");
                    POSEntrySalesDocLink.SetRange("POS Entry Reference Type", POSEntrySalesDocLink."POS Entry Reference Type"::SALESLINE);
                    POSEntrySalesDocLink.SetRange("POS Entry Reference Line No.", "Line No.");
                    PAGE.RunModal(PAGE::"NPR POS Entry Rel. Sales Doc.", POSEntrySalesDocLink);
                    //+NPR5.50 [300557]
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
    begin
        //-NPR5.50 [300557]
        LastPostedSalesDocNo := '';
        if TryGetLastPostedSalesDoc(POSEntrySalesDocLink) then
            LastPostedSalesDocNo := POSEntrySalesDocLink."Sales Document No";
        //+NPR5.50 [300557]
    end;

    var
        LastPostedSalesDocNo: Code[20];

    local procedure TryGetLastPostedSalesDoc(var POSEntrySalesDocLinkOut: Record "NPR POS Entry Sales Doc. Link"): Boolean
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

