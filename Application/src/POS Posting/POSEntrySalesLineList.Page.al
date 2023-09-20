﻿page 6150655 "NPR POS Entry Sales Line List"
{
    Extensible = False;
    Caption = 'POS Entry Sales Line List';
    ContextSensitiveHelpPage = 'docs/retail/pos_academy/pos_entry/accounting_entries/';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    PromotedActionCategories = 'New,Process,Report,POS Entry';
    SourceTable = "NPR POS Entry Sales Line";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Date"; Rec."Entry Date")
                {

                    ToolTip = 'Specifies the value of the Entry Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {

                    ToolTip = 'Specifies the value of the Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Time"; Rec."Starting Time")
                {

                    ToolTip = 'Specifies the value of the Starting Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Ending Time"; Rec."Ending Time")
                {

                    ToolTip = 'Specifies the value of the Ending Time field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Store Code"; Rec."POS Store Code")
                {

                    ToolTip = 'Specifies the value of the POS Store Code field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Unit No."; Rec."POS Unit No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Period Register No."; Rec."POS Period Register No.")
                {

                    ToolTip = 'Specifies the value of the POS Period Register No. field';
                    ApplicationArea = NPRRetail;
                }
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
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }

                field("Description 2"; Rec."Description 2")
                {

                    ToolTip = 'Specifies the value of the Description 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Serial No."; Rec."Serial No.")
                {
                    Visible = true;
                    ToolTip = 'Specifies the value of the Serial No. field.';
                    ApplicationArea = NPRRetail;
                }
                field("Location Code"; Rec."Location Code")
                {

                    ToolTip = 'Specifies the value of the Location Code field';
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
                field("Currency Code"; Rec."Currency Code")
                {

                    ToolTip = 'Specifies the value of the Currency Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Withhold Item"; Rec."Withhold Item")
                {

                    ToolTip = 'Specifies the value of the Withhold Item field';
                    ApplicationArea = NPRRetail;
                }

                field("Benefit Item"; Rec."Benefit Item")
                {
                    ToolTip = 'Specifies the value of the Benefit Item field.';
                    ApplicationArea = NPRRetail;
                }
                field("Total Discount Code"; Rec."Total Discount Code")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Total Discount Code field.';
                    ApplicationArea = NPRRetail;
                }
                field("Total Discount Step"; Rec."Total Discount Step")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Total Discount Step field.';
                    ApplicationArea = NPRRetail;
                }
                field("Line Total Disc Amt Excl Tax"; Rec."Line Total Disc Amt Excl Tax")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line Total Discount Amount Excluding Tax field.';
                    ApplicationArea = NPRRetail;
                }
                field("Line Total Disc Amt Incl Tax"; Rec."Line Total Disc Amt Incl Tax")
                {
                    Visible = false;
                    ToolTip = 'Specifies the value of the Line Total Discount Amount Including Tax field.';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Authorised by"; Rec."Discount Authorised by")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Discount Authorised by field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {

                    ToolTip = 'Specifies the value of the POS Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Line No."; Rec."Line No.")
                {

                    ToolTip = 'Specifies the value of the Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ToolTip = 'Specifies the reason code, a supplementary source code that enables you to trace the entry.';
                    ApplicationArea = NPRRetail;
                }
                field("Dimension Set ID"; Rec."Dimension Set ID")
                {
                    ToolTip = 'Specifies the value of the Dimension Set ID field.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("POS Entry")
            {
                Caption = 'POS Entry';
                action("POS Entry Card")
                {
                    Caption = 'POS Entry Card';
                    Image = List;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    RunObject = Page "NPR POS Entry Card";
                    RunPageLink = "Entry No." = FIELD("POS Entry No.");
                    RunPageView = SORTING("Entry No.");

                    ToolTip = 'Executes the POS Entry Card action';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

