page 6014467 "NPR Quantity Discount List"
{
    Extensible = False;
    // NPR5.29/TJ  /20170123 CASE 263787 Commented out code under action Dimensions-Multiple and set Visible property to FALSE
    // NPR5.30/BHR /20170223 CASE 265244 Add field Item No.
    // NPR5.55/TJ  /20200421 CASE 400524 Removed Name from action Dimension-Single to default to page name
    //                                   Removed group Dimensions and unused action Dimensions-Multiple

    Caption = 'Quantity Discount List';
    CardPageID = "NPR Quantity Discount Card";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Quantity Discount Header";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Main No."; Rec."Main No.")
                {

                    ToolTip = 'Specifies the value of the Main no. field';
                    ApplicationArea = NPRRetail;
                }
                field("Item No."; Rec."Item No.")
                {

                    ToolTip = 'Specifies the value of the Item no. field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Date"; Rec."Starting Date")
                {

                    ToolTip = 'Specifies the value of the Starting date field';
                    ApplicationArea = NPRRetail;
                }
                field("Closing Date"; Rec."Closing Date")
                {

                    ToolTip = 'Specifies the value of the Closing Date field';
                    ApplicationArea = NPRRetail;
                }
                field(Status; Rec.Status)
                {

                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {

                    Caption = 'Shortcut Dimension 1 Code';
                    ToolTip = 'Specifies the value of the Shortcut Dimension 1 Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {

                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Dimensions)
            {
                Caption = 'Dimensions';
                Image = Dimensions;
                RunObject = Page "Default Dimensions";
                RunPageLink = "Table ID" = CONST(6014439),
                              "No." = FIELD("Main No.");
                ShortCutKey = 'Shift+Ctrl+D';

                ToolTip = 'Executes the Dimensions action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

