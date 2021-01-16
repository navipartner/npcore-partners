page 6014554 "NPR TouchScreen: SalesLineZoom"
{
    // NPR4.04/JDH/20150427  CASE 212229  Removed references to old Variant solution "Color Size"
    // NPR4.14/BHR/20150812 CASE 220173 Set property of page InsertAllowed=no deleteAllowed=0
    // NPR5.36/TS  /20170906  CASE 288808 Page Type set to List
    // NPR5.37/TS  /20171024  CASE 294174 Reverted to Card

    Caption = 'Touch Screen - Sales Lines';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Sale Line POS";

    layout
    {
        area(content)
        {
            group(Control6014400)
            {
                ShowCaption = false;
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shortcut Dimension 2 Code field';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field("Serial No."; "Serial No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Serial No. field';
                }
                field("Serial No. not Created"; "Serial No. not Created")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Serial No. not Created field';
                }
                field("Insurance Category"; "Insurance Category")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Insurance Category field';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field(Reference; Reference)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Dimension Set ID"; "Dimension Set ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Dimension Set ID field';
                }
                field("Discount Type"; "Discount Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Discount Type field';
                }
                field("Discount Code"; "Discount Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Discount Code field';
                }
            }
        }
    }

    actions
    {
    }
}

